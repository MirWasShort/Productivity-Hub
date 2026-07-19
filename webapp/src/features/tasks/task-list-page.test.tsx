import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { Task } from '@/api/types'
import TaskListPage from '@/features/tasks/task-list-page'
import { createApiMock, requestsWithMethod } from '@/test/api-mock'

function task(overrides: Partial<Task> & { id: string; title: string }): Task {
  return {
    status: 'TODO',
    priority: 'MEDIUM',
    tags: [],
    createdAt: '2026-07-01T08:00:00Z',
    updatedAt: '2026-07-01T08:00:00Z',
    ...overrides,
  }
}

function daysFromNow(days: number): string {
  const date = new Date()
  date.setDate(date.getDate() + days)
  return date.toISOString()
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

describe('pagina dei task', () => {
  let fetchMock: ReturnType<typeof createApiMock>

  /** Il finto backend, con le risposte specifiche del test. */
  function mockApi(handler?: Parameters<typeof createApiMock>[0]) {
    fetchMock = createApiMock(handler)
    vi.stubGlobal('fetch', fetchMock)
  }

  /**
   * Non si può guardare l'ultima chiamata: dopo ogni mutazione l'invalidazione
   * fa ripartire la GET della lista, che arriva per ultima.
   */
  function requestWithMethod(method: string): Request {
    const request = requestsWithMethod(fetchMock, method)[0]
    if (!request) {
      throw new Error(`Nessuna richiesta ${method} inviata`)
    }
    return request
  }

  function tasksResponse(...items: Task[]) {
    return (request: Request) =>
      request.method === 'GET' && new URL(request.url).pathname.endsWith('/tasks')
        ? { body: { items } }
        : undefined
  }

  beforeEach(() => {
    localStorage.clear()
    mockApi()
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('raggruppa i task per urgenza, con il conteggio accanto al titolo', async () => {
    mockApi(
      tasksResponse(
        task({ id: 't1', title: 'Pagare la bolletta', dueDate: daysFromNow(-2) }),
        task({ id: 't2', title: 'Chiamare il dentista', dueDate: daysFromNow(1) }),
        task({ id: 't3', title: 'Innaffiare le piante' }),
      ),
    )

    renderPage()

    const ritardo = await screen.findByRole('heading', { name: /In ritardo/ })
    expect(within(ritardo).getByText('1')).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: /Domani/ })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: /Senza scadenza/ })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Pagare la bolletta' })).toBeInTheDocument()
  })

  it('mostra priorità, tag e scadenza in ritardo sulla card', async () => {
    mockApi(
      tasksResponse(
        task({
          id: 't1',
          title: 'Pagare la bolletta',
          priority: 'HIGH',
          dueDate: daysFromNow(-2),
          tags: [{ id: 'tag-1', name: 'casa', color: '#10B981' }],
        }),
      ),
    )

    renderPage()

    expect(await screen.findByText('ALTA')).toBeInTheDocument()
    expect(screen.getByText('casa')).toBeInTheDocument()
  })

  it('spuntare la casella manda al server il task completo con il nuovo stato', async () => {
    const existing = task({ id: 't1', title: 'Comprare il latte', description: 'Intero' })
    mockApi((request) =>
      request.method === 'PUT'
        ? { body: { ...existing, status: 'DONE' } }
        : tasksResponse(existing)(request),
    )

    renderPage()
    await userEvent.click(await screen.findByRole('checkbox', { name: /Completa/ }))

    await expect(requestWithMethod('PUT').json()).resolves.toMatchObject({
      title: 'Comprare il latte',
      description: 'Intero',
      status: 'DONE',
      priority: 'MEDIUM',
    })
  })

  it('l aggiunta rapida crea il task col solo titolo e svuota il campo', async () => {
    mockApi((request) =>
      request.method === 'POST'
        ? { body: task({ id: 't9', title: 'Nuovo task' }), status: 201 }
        : undefined,
    )

    renderPage()
    const input = await screen.findByLabelText('Nuovo task')
    await userEvent.type(input, 'Nuovo task{Enter}')

    await expect(requestWithMethod('POST').json()).resolves.toEqual({ title: 'Nuovo task' })
    expect(input).toHaveValue('')
  })

  it('l eliminazione chiede conferma prima di procedere', async () => {
    mockApi(tasksResponse(task({ id: 't1', title: 'Da buttare' })))

    renderPage()
    await userEvent.click(await screen.findByRole('button', { name: 'Elimina "Da buttare"' }))
    expect(await screen.findByText('Eliminare questo task?')).toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: 'Elimina' }))

    expect(requestWithMethod('DELETE').url).toMatch(/\/tasks\/t1$/)
  })

  it('senza task spiega come iniziare invece di lasciare il vuoto', async () => {
    renderPage()

    expect(await screen.findByText('Nessun task, per ora')).toBeInTheDocument()
  })

  it('se il caricamento fallisce lo dice, senza schermata bianca', async () => {
    mockApi((request) =>
      new URL(request.url).pathname.endsWith('/tasks')
        ? { body: { message: 'Errore interno' }, status: 500 }
        : undefined,
    )

    renderPage()

    expect(await screen.findByRole('alert')).toHaveTextContent(/non riesco a caricare/i)
  })
})
