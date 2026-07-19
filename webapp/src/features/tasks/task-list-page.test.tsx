import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { Task } from '@/api/types'
import TaskListPage from '@/features/tasks/task-list-page'

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  })
}

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

/**
 * Trova la richiesta con quel metodo. Non si può guardare l'ultima chiamata:
 * dopo ogni mutazione l'invalidazione fa ripartire la GET della lista, che
 * finisce per essere l'ultima arrivata.
 */
function requestWithMethod(fetchMock: ReturnType<typeof vi.fn>, method: string): Request {
  const request = fetchMock.mock.calls
    .map((call) => call[0] as Request)
    .find((candidate) => candidate.method === method)
  if (!request) {
    throw new Error(`Nessuna richiesta ${method} inviata`)
  }
  return request
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
  let fetchMock: ReturnType<typeof vi.fn>

  beforeEach(() => {
    localStorage.clear()
    fetchMock = vi.fn()
    vi.stubGlobal('fetch', fetchMock)
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('raggruppa i task per urgenza, con il conteggio accanto al titolo', async () => {
    fetchMock.mockResolvedValue(
      jsonResponse({
        items: [
          task({ id: 't1', title: 'Pagare la bolletta', dueDate: daysFromNow(-2) }),
          task({ id: 't2', title: 'Chiamare il dentista', dueDate: daysFromNow(1) }),
          task({ id: 't3', title: 'Innaffiare le piante' }),
        ],
      }),
    )

    renderPage()

    const ritardo = await screen.findByRole('heading', { name: /In ritardo/ })
    expect(within(ritardo).getByText('1')).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: /Domani/ })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: /Senza scadenza/ })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Pagare la bolletta' })).toBeInTheDocument()
  })

  it('mostra priorità, tag e scadenza in ritardo sulla card', async () => {
    fetchMock.mockResolvedValue(
      jsonResponse({
        items: [
          task({
            id: 't1',
            title: 'Pagare la bolletta',
            priority: 'HIGH',
            dueDate: daysFromNow(-2),
            tags: [{ id: 'tag-1', name: 'casa', color: '#10B981' }],
          }),
        ],
      }),
    )

    renderPage()

    expect(await screen.findByText('ALTA')).toBeInTheDocument()
    expect(screen.getByText('casa')).toBeInTheDocument()
  })

  it('spuntare la casella manda al server il task completo con il nuovo stato', async () => {
    const existing = task({ id: 't1', title: 'Comprare il latte', description: 'Intero' })
    fetchMock.mockResolvedValueOnce(jsonResponse({ items: [existing] }))
    fetchMock.mockResolvedValue(jsonResponse({ ...existing, status: 'DONE' }))

    renderPage()
    await userEvent.click(await screen.findByRole('checkbox', { name: /Completa/ }))

    const request = requestWithMethod(fetchMock, 'PUT')
    await expect(request.json()).resolves.toMatchObject({
      title: 'Comprare il latte',
      description: 'Intero',
      status: 'DONE',
      priority: 'MEDIUM',
    })
  })

  it('l aggiunta rapida crea il task col solo titolo e svuota il campo', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ items: [] }))
    fetchMock.mockResolvedValue(jsonResponse(task({ id: 't9', title: 'Nuovo task' }), 201))

    renderPage()
    const input = await screen.findByLabelText('Nuovo task')
    await userEvent.type(input, 'Nuovo task{Enter}')

    const request = requestWithMethod(fetchMock, 'POST')
    await expect(request.json()).resolves.toEqual({ title: 'Nuovo task' })
    expect(input).toHaveValue('')
  })

  it('l eliminazione chiede conferma prima di procedere', async () => {
    fetchMock.mockResolvedValueOnce(
      jsonResponse({ items: [task({ id: 't1', title: 'Da buttare' })] }),
    )
    fetchMock.mockResolvedValue(new Response(null, { status: 204 }))

    renderPage()
    await userEvent.click(await screen.findByRole('button', { name: 'Elimina "Da buttare"' }))
    expect(await screen.findByText('Eliminare questo task?')).toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: 'Elimina' }))

    expect(requestWithMethod(fetchMock, 'DELETE').url).toMatch(/\/tasks\/t1$/)
  })

  it('senza task spiega come iniziare invece di lasciare il vuoto', async () => {
    fetchMock.mockResolvedValue(jsonResponse({ items: [] }))

    renderPage()

    expect(await screen.findByText('Nessun task, per ora')).toBeInTheDocument()
  })

  it('se il caricamento fallisce lo dice, senza schermata bianca', async () => {
    fetchMock.mockResolvedValue(jsonResponse({ message: 'Errore interno' }, 500))

    renderPage()

    expect(await screen.findByRole('alert')).toHaveTextContent(/non riesco a caricare/i)
  })
})
