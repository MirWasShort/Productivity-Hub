import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { act, renderHook, waitFor } from '@testing-library/react'
import type { ReactNode } from 'react'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { Task } from '@/api/types'
import { toUpdateRequest } from '@/features/tasks/api'
import { defaultTaskFilter } from '@/features/tasks/filters'
import { taskKeys, useDeleteTask, useTasks, useUpdateTask } from '@/features/tasks/queries'

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  })
}

const task: Task = {
  id: 't1',
  title: 'Comprare il latte',
  status: 'TODO',
  priority: 'MEDIUM',
  tags: [{ id: 'tag-1', name: 'casa', color: '#10B981' }],
  createdAt: '2026-07-19T08:00:00Z',
  updatedAt: '2026-07-19T08:00:00Z',
}

let queryClient: QueryClient

function wrapper({ children }: { children: ReactNode }) {
  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
}

describe('query dei task', () => {
  let fetchMock: ReturnType<typeof vi.fn>

  beforeEach(() => {
    localStorage.clear()
    queryClient = new QueryClient({
      defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
    })
    fetchMock = vi.fn()
    vi.stubGlobal('fetch', fetchMock)
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('legge la lista dalla busta paginata del backend', async () => {
    fetchMock.mockResolvedValue(jsonResponse({ items: [task], page: 0, totalElements: 1 }))

    const { result } = renderHook(() => useTasks(defaultTaskFilter), { wrapper })

    await waitFor(() => expect(result.current.data).toEqual([task]))
    const url = new URL((fetchMock.mock.calls[0]![0] as Request).url)
    expect(url.searchParams.get('sortBy')).toBe('CREATED_AT')
    expect(url.searchParams.has('status')).toBe(false)
  })

  it('spuntare un task lo aggiorna subito, prima della risposta', async () => {
    queryClient.setQueryData(taskKeys.list(defaultTaskFilter), [task])
    let resolveUpdate: (value: Response) => void = () => {}
    fetchMock.mockReturnValue(
      new Promise<Response>((resolve) => {
        resolveUpdate = resolve
      }),
    )

    const { result } = renderHook(() => useUpdateTask(), { wrapper })
    act(() => {
      result.current.mutate({ taskId: 't1', body: toUpdateRequest(task, { status: 'DONE' }) })
    })

    await waitFor(() =>
      expect(queryClient.getQueryData<Task[]>(taskKeys.list(defaultTaskFilter))?.[0]?.status).toBe(
        'DONE',
      ),
    )
    resolveUpdate(jsonResponse({ ...task, status: 'DONE' }))
  })

  it('se il server rifiuta, la spunta torna indietro', async () => {
    queryClient.setQueryData(taskKeys.list(defaultTaskFilter), [task])
    fetchMock.mockResolvedValue(jsonResponse({ message: 'Non trovato' }, 404))

    const { result } = renderHook(() => useUpdateTask(), { wrapper })
    act(() => {
      result.current.mutate({ taskId: 't1', body: toUpdateRequest(task, { status: 'DONE' }) })
    })

    await waitFor(() => expect(result.current.isError).toBe(true))
    expect(queryClient.getQueryData<Task[]>(taskKeys.list(defaultTaskFilter))?.[0]?.status).toBe(
      'TODO',
    )
  })

  it('la cancellazione toglie subito il task e lo rimette se fallisce', async () => {
    queryClient.setQueryData(taskKeys.list(defaultTaskFilter), [task])
    fetchMock.mockResolvedValue(jsonResponse({ message: 'Non trovato' }, 404))

    const { result } = renderHook(() => useDeleteTask(), { wrapper })
    act(() => {
      result.current.mutate('t1')
    })

    await waitFor(() => expect(result.current.isError).toBe(true))
    expect(queryClient.getQueryData<Task[]>(taskKeys.list(defaultTaskFilter))).toEqual([task])
  })

  it('aggiorna anche la cache del dettaglio, che è un task singolo e non una lista', async () => {
    // Regressione: l'aggiornamento ottimistico chiamava `.map()` su tutto ciò
    // che stava sotto `['tasks']`, dettaglio compreso. Con la pagina di
    // dettaglio aperta, `onMutate` esplodeva e il salvataggio non partiva.
    queryClient.setQueryData(taskKeys.detail('t1'), task)
    fetchMock.mockImplementation(() => Promise.resolve(jsonResponse({ ...task, status: 'DONE' })))

    const { result } = renderHook(() => useUpdateTask(), { wrapper })
    act(() => {
      result.current.mutate({ taskId: 't1', body: toUpdateRequest(task, { status: 'DONE' }) })
    })

    await waitFor(() => expect(result.current.isSuccess).toBe(true))
    expect(queryClient.getQueryData<Task>(taskKeys.detail('t1'))?.status).toBe('DONE')
  })

  it('ogni mutazione riuscita invalida anche calendario e analytics', async () => {
    queryClient.setQueryData(taskKeys.list(defaultTaskFilter), [task])
    queryClient.setQueryData(taskKeys.calendar(), [task])
    queryClient.setQueryData(['analytics', 'summary'], { total: 1 })
    const invalidate = vi.spyOn(queryClient, 'invalidateQueries')
    fetchMock.mockResolvedValue(jsonResponse({ ...task, status: 'DONE' }))

    const { result } = renderHook(() => useUpdateTask(), { wrapper })
    act(() => {
      result.current.mutate({ taskId: 't1', body: toUpdateRequest(task, { status: 'DONE' }) })
    })

    await waitFor(() => expect(result.current.isSuccess).toBe(true))
    const invalidatedKeys = invalidate.mock.calls.map((call) => call[0]?.queryKey)
    expect(invalidatedKeys).toContainEqual(taskKeys.all)
    expect(invalidatedKeys).toContainEqual(['analytics'])
  })
})

describe('toUpdateRequest', () => {
  it('rimanda tutti i campi, perché la PUT sostituisce il task intero', () => {
    expect(toUpdateRequest(task, { status: 'DONE' })).toEqual({
      title: 'Comprare il latte',
      description: undefined,
      status: 'DONE',
      priority: 'MEDIUM',
      dueDate: undefined,
      listId: undefined,
      tagIds: ['tag-1'],
    })
  })
})
