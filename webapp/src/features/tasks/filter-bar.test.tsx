import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { Task } from '@/api/types'
import TaskListPage from '@/features/tasks/task-list-page'

import { createApiMock, taskListRequests } from '@/test/api-mock'

/** Risponde con questi task alla lista, e coi ripieghi a tutto il resto. */
function tasksResponse(...items: unknown[]) {
  return (request: Request) =>
    request.method === 'GET' && new URL(request.url).pathname.endsWith('/tasks')
      ? { body: { items } }
      : undefined
}

const task: Task = {
  id: 't1',
  title: 'Comprare il latte',
  status: 'TODO',
  priority: 'MEDIUM',
  tags: [],
  createdAt: '2026-07-01T08:00:00Z',
  updatedAt: '2026-07-01T08:00:00Z',
}

/** I parametri di query dell'ultima GET della lista dei task. */
function lastListParams(fetchMock: ReturnType<typeof createApiMock>): URLSearchParams {
  return new URL(taskListRequests(fetchMock).at(-1)!.url).searchParams
}

function renderPage() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter>
        <TaskListPage />
      </MemoryRouter>
    </QueryClientProvider>,
  )
}

describe('barra dei filtri', () => {
  let fetchMock: ReturnType<typeof createApiMock>

  function mockApi(handler?: Parameters<typeof createApiMock>[0]) {
    fetchMock = createApiMock(handler)
    vi.stubGlobal('fetch', fetchMock)
  }

  beforeEach(() => {
    localStorage.clear()
    mockApi(tasksResponse(task))
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('la ricerca aspetta che si smetta di scrivere prima di interrogare il backend', async () => {
    renderPage()
    await screen.findByRole('link', { name: 'Comprare il latte' })
    const callsBefore = fetchMock.mock.calls.length

    await userEvent.type(screen.getByLabelText('Cerca fra i task'), 'latte')

    // Cinque caratteri, ma il filtro cambia una volta sola.
    await waitFor(() => expect(lastListParams(fetchMock).get('search')).toBe('latte'))
    expect(fetchMock.mock.calls.length - callsBefore).toBe(1)
  })

  it('cancellare la ricerca toglie il parametro invece di mandarlo vuoto', async () => {
    renderPage()
    await userEvent.type(await screen.findByLabelText('Cerca fra i task'), 'latte')
    await waitFor(() => expect(lastListParams(fetchMock).get('search')).toBe('latte'))

    await userEvent.click(screen.getByRole('button', { name: 'Cancella la ricerca' }))

    await waitFor(() => expect(lastListParams(fetchMock).has('search')).toBe(false))
  })

  it('il chip di stato filtra, e ricliccato si spegne', async () => {
    renderPage()
    const chip = await screen.findByRole('button', { name: 'Da fare' })

    await userEvent.click(chip)
    await waitFor(() => expect(lastListParams(fetchMock).get('status')).toBe('TODO'))
    expect(chip).toHaveAttribute('aria-pressed', 'true')

    await userEvent.click(chip)
    await waitFor(() => expect(lastListParams(fetchMock).has('status')).toBe(false))
  })

  it('due chip di stato si escludono a vicenda', async () => {
    renderPage()

    await userEvent.click(await screen.findByRole('button', { name: 'Da fare' }))
    await waitFor(() => expect(lastListParams(fetchMock).get('status')).toBe('TODO'))
    await userEvent.click(screen.getByRole('button', { name: 'Completati' }))

    await waitFor(() => expect(lastListParams(fetchMock).get('status')).toBe('DONE'))
  })

  it('il menu di ordinamento cambia campo e direzione insieme', async () => {
    renderPage()

    await userEvent.click(await screen.findByRole('button', { name: /Più recenti/ }))
    await userEvent.click(screen.getByRole('menuitem', { name: 'Scadenza più vicina' }))

    await waitFor(() => {
      const params = lastListParams(fetchMock)
      expect(params.get('sortBy')).toBe('DUE_DATE')
      expect(params.get('direction')).toBe('ASC')
    })
    expect(screen.getByRole('button', { name: /Scadenza più vicina/ })).toBeInTheDocument()
  })

  it('con un ordinamento diverso le sezioni per scadenza spariscono', async () => {
    mockApi(tasksResponse({ ...task, dueDate: '2020-01-01T10:00:00Z' }))
    renderPage()
    expect(await screen.findByRole('heading', { name: /In ritardo/ })).toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: /Più recenti/ }))
    await userEvent.click(screen.getByRole('menuitem', { name: 'Titolo A-Z' }))

    await waitFor(() =>
      expect(screen.queryByRole('heading', { name: /In ritardo/ })).not.toBeInTheDocument(),
    )
    expect(screen.getByRole('link', { name: 'Comprare il latte' })).toBeInTheDocument()
  })

  it('con filtri attivi lo stato vuoto parla di filtri, non di primo task', async () => {
    mockApi(tasksResponse())
    renderPage()

    await userEvent.click(await screen.findByRole('button', { name: 'Completati' }))

    expect(await screen.findByText('Nessun risultato')).toBeInTheDocument()
  })
})
