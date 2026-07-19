import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { TodoList } from '@/api/types'
import { useAuthStore } from '@/lib/auth/auth-store'
import type { Session } from '@/lib/auth/token-storage'
import { useThemeStore } from '@/lib/theme/theme-store'
import { renderApp } from '@/test/render-app'

const session: Session = {
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  expiresAt: Date.now() + 900_000,
  user: { id: 'u1', email: 'mario@example.com', displayName: 'Mario' },
}

const lists: TodoList[] = [
  {
    id: 'list-1',
    name: 'Casa',
    color: '#10B981',
    position: 0,
    createdAt: '2026-07-01T08:00:00Z',
    updatedAt: '2026-07-01T08:00:00Z',
  },
  {
    id: 'list-2',
    name: 'Lavoro',
    color: '#4F46E5',
    position: 1,
    createdAt: '2026-07-01T08:00:00Z',
    updatedAt: '2026-07-01T08:00:00Z',
  },
]

import { createApiMock, requestsWithMethod, taskListRequests } from '@/test/api-mock'

const listRequests = requestsWithMethod

describe('liste', () => {
  let fetchMock: ReturnType<typeof createApiMock>

  beforeEach(() => {
    localStorage.clear()
    useThemeStore.setState({ mode: 'light' })
    vi.stubGlobal(
      'matchMedia',
      vi.fn(() => ({ matches: false, addEventListener: vi.fn(), removeEventListener: vi.fn() })),
    )
    useAuthStore.getState().signIn(session)
    fetchMock = createApiMock((request) =>
      request.method === 'GET' && new URL(request.url).pathname.endsWith('/lists')
        ? { body: lists }
        : undefined,
    )
    vi.stubGlobal('fetch', fetchMock)
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('mostra le liste dell utente nella barra laterale', async () => {
    renderApp('/tasks')

    expect(await screen.findByRole('link', { name: 'Casa' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Lavoro' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Tutte le attività' })).toBeInTheDocument()
  })

  it('scegliere una lista filtra i task e cambia il titolo della pagina', async () => {
    renderApp('/tasks')

    await userEvent.click(await screen.findByRole('link', { name: 'Casa' }))

    await waitFor(() => {
      const last = taskListRequests(fetchMock).at(-1)!
      expect(new URL(last.url).searchParams.get('listId')).toBe('list-1')
    })
    expect(await screen.findByRole('heading', { name: 'Casa', level: 1 })).toBeInTheDocument()
  })

  it('aprendo un indirizzo con una lista, il filtro è già attivo', async () => {
    renderApp('/tasks?list=list-2')

    expect(await screen.findByRole('heading', { name: 'Lavoro', level: 1 })).toBeInTheDocument()
    await waitFor(() => {
      const listCall = taskListRequests(fetchMock).find((request) =>
        new URL(request.url).searchParams.has('listId'),
      )
      expect(new URL(listCall!.url).searchParams.get('listId')).toBe('list-2')
    })
  })

  it('un task aggiunto mentre una lista è selezionata le appartiene', async () => {
    renderApp('/tasks?list=list-1')
    await userEvent.type(await screen.findByLabelText('Nuovo task'), 'Stendere i panni{Enter}')

    await waitFor(() => expect(listRequests(fetchMock, 'POST')).toHaveLength(1))
    await expect(listRequests(fetchMock, 'POST')[0]!.json()).resolves.toEqual({
      title: 'Stendere i panni',
      listId: 'list-1',
    })
  })

  it('crea una lista con nome e colore scelto', async () => {
    renderApp('/tasks')

    await userEvent.click(await screen.findByRole('button', { name: /Nuova lista/ }))
    await userEvent.type(screen.getByLabelText('Nome della lista'), 'Spesa')
    await userEvent.click(screen.getByRole('button', { name: 'Colore #F59E0B' }))
    await userEvent.click(screen.getByRole('button', { name: 'Crea' }))

    await waitFor(() => expect(listRequests(fetchMock, 'POST')).toHaveLength(1))
    await expect(listRequests(fetchMock, 'POST')[0]!.json()).resolves.toEqual({
      name: 'Spesa',
      color: '#F59E0B',
    })
  })

  it('eliminare una lista chiede conferma e avvisa che i task restano', async () => {
    renderApp('/tasks')

    await userEvent.click(await screen.findByRole('button', { name: 'Elimina la lista "Casa"' }))
    expect(await screen.findByText('Eliminare la lista?')).toBeInTheDocument()
    expect(screen.getByText(/i task che le appartengono restano/i)).toBeInTheDocument()
    await userEvent.click(screen.getByRole('button', { name: 'Elimina' }))

    await waitFor(() => expect(listRequests(fetchMock, 'DELETE')).toHaveLength(1))
    expect(listRequests(fetchMock, 'DELETE')[0]!.url).toMatch(/\/lists\/list-1$/)
  })

  it('l editor del task permette di scegliere la lista', async () => {
    renderApp('/tasks/new')

    const select = await screen.findByLabelText('Lista')
    expect(within(select).getByRole('option', { name: 'Nessuna lista' })).toBeInTheDocument()
    // Le opzioni arrivano dalla query delle liste: vanno attese.
    await screen.findByRole('option', { name: 'Lavoro' })
    await userEvent.selectOptions(select, 'list-2')
    await userEvent.type(screen.getByLabelText('Titolo'), 'Preparare la riunione')
    await userEvent.click(screen.getByRole('button', { name: 'Crea' }))

    await waitFor(() => expect(listRequests(fetchMock, 'POST')).toHaveLength(1))
    await expect(listRequests(fetchMock, 'POST')[0]!.json()).resolves.toMatchObject({
      listId: 'list-2',
    })
  })
})
