import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { Task } from '@/api/types'
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

const task: Task = {
  id: 't1',
  title: 'Comprare il latte',
  description: 'Intero, non scremato',
  status: 'IN_PROGRESS',
  priority: 'HIGH',
  dueDate: '2026-08-20T10:00:00Z',
  tags: [{ id: 'tag-1', name: 'casa', color: '#10B981' }],
  createdAt: '2026-07-01T08:00:00Z',
  updatedAt: '2026-07-01T08:00:00Z',
}

import { createApiMock, requestsWithMethod } from '@/test/api-mock'

function requestWithMethod(fetchMock: ReturnType<typeof createApiMock>, method: string): Request {
  const request = requestsWithMethod(fetchMock, method)[0]
  if (!request) {
    throw new Error(`Nessuna richiesta ${method} inviata`)
  }
  return request
}

describe('dettaglio ed editor del task', () => {
  let fetchMock: ReturnType<typeof createApiMock>

  function mockApi(handler?: Parameters<typeof createApiMock>[0]) {
    fetchMock = createApiMock(handler)
    vi.stubGlobal('fetch', fetchMock)
  }

  beforeEach(() => {
    localStorage.clear()
    useThemeStore.setState({ mode: 'light' })
    vi.stubGlobal(
      'matchMedia',
      vi.fn(() => ({ matches: false, addEventListener: vi.fn(), removeEventListener: vi.fn() })),
    )
    useAuthStore.getState().signIn(session)
    mockApi((request) =>
      new URL(request.url).pathname.includes('/tasks/') ? { body: task } : undefined,
    )
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('il dettaglio mostra stato, priorità, scadenza e tag', async () => {
    renderApp('/tasks/t1')

    expect(await screen.findByRole('heading', { name: 'Comprare il latte' })).toBeInTheDocument()
    expect(screen.getByText('In corso')).toBeInTheDocument()
    expect(screen.getByText('ALTA')).toBeInTheDocument()
    expect(screen.getByText('20 agosto 2026')).toBeInTheDocument()
    expect(screen.getByText('casa')).toBeInTheDocument()
    expect(screen.getByText('Intero, non scremato')).toBeInTheDocument()
  })

  it('un task inesistente riporta alla lista invece di mostrare un errore', async () => {
    mockApi((request) =>
      request.url.includes('/tasks/sparito')
        ? { body: { message: 'Task non trovato' }, status: 404 }
        : undefined,
    )

    renderApp('/tasks/sparito')

    expect(await screen.findByRole('heading', { name: 'I miei task' })).toBeInTheDocument()
  })

  it('l editor apre il task con i suoi valori e lo stato modificabile', async () => {
    renderApp('/tasks/t1/edit')

    expect(await screen.findByLabelText('Titolo')).toHaveValue('Comprare il latte')
    expect(screen.getByLabelText('Descrizione')).toHaveValue('Intero, non scremato')
    expect(screen.getByLabelText('Stato')).toHaveValue('IN_PROGRESS')
    expect(screen.getByLabelText('Priorità')).toHaveValue('HIGH')
    expect(screen.getByRole('button', { name: /20 agosto 2026/ })).toBeInTheDocument()
  })

  it('in creazione lo stato non si sceglie: un task nuovo è da fare', async () => {
    renderApp('/tasks/new')

    expect(await screen.findByLabelText('Titolo')).toHaveValue('')
    expect(screen.queryByLabelText('Stato')).not.toBeInTheDocument()
  })

  it('in creazione riprende il titolo passato dall aggiunta rapida', async () => {
    renderApp('/tasks/new?title=Portare%20fuori%20il%20cane')

    expect(await screen.findByLabelText('Titolo')).toHaveValue('Portare fuori il cane')
  })

  it('in creazione riprende la data scelta nel calendario', async () => {
    renderApp('/tasks/new?date=2026-09-15T00:00:00.000Z')

    expect(await screen.findByRole('button', { name: /15 settembre 2026/ })).toBeInTheDocument()
  })

  it('senza titolo non parte nessuna richiesta', async () => {
    renderApp('/tasks/new')
    await screen.findByLabelText('Titolo')

    await userEvent.click(screen.getByRole('button', { name: 'Crea' }))

    expect(await screen.findByText('Il titolo è obbligatorio')).toBeInTheDocument()
    expect(fetchMock.mock.calls.some((call) => (call[0] as Request).method === 'POST')).toBe(false)
  })

  it('salvando una modifica manda il task intero, tag e lista compresi', async () => {
    renderApp('/tasks/t1/edit')
    const title = await screen.findByLabelText('Titolo')

    await userEvent.clear(title)
    await userEvent.type(title, 'Comprare il pane')
    await userEvent.click(screen.getByRole('button', { name: 'Salva' }))

    await waitFor(() => expect(requestWithMethod(fetchMock, 'PUT')).toBeDefined())
    await expect(requestWithMethod(fetchMock, 'PUT').json()).resolves.toMatchObject({
      title: 'Comprare il pane',
      description: 'Intero, non scremato',
      status: 'IN_PROGRESS',
      priority: 'HIGH',
      tagIds: ['tag-1'],
    })
  })

  it('la descrizione svuotata viene mandata come assente, non come stringa vuota', async () => {
    renderApp('/tasks/t1/edit')
    await userEvent.clear(await screen.findByLabelText('Descrizione'))
    await userEvent.click(screen.getByRole('button', { name: 'Salva' }))

    await waitFor(() => expect(requestWithMethod(fetchMock, 'PUT')).toBeDefined())
    const body = (await requestWithMethod(fetchMock, 'PUT').json()) as Record<string, unknown>
    expect(body.description).toBeUndefined()
  })
})
