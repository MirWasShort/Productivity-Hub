import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { Task } from '@/api/types'
import { useAuthStore } from '@/lib/auth/auth-store'
import type { Session } from '@/lib/auth/token-storage'
import { useThemeStore } from '@/lib/theme/theme-store'
import { createApiMock } from '@/test/api-mock'
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
  status: 'TODO',
  priority: 'MEDIUM',
  tags: [],
  createdAt: '2026-07-01T08:00:00Z',
  updatedAt: '2026-07-01T08:00:00Z',
}

describe('rifiniture', () => {
  let fetchMock: ReturnType<typeof createApiMock>

  function mockApi(handler?: Parameters<typeof createApiMock>[0]) {
    fetchMock = createApiMock((request) => {
      const custom = handler?.(request)
      if (custom) {
        return custom
      }
      return request.method === 'GET' && new URL(request.url).pathname.endsWith('/tasks')
        ? { body: { items: [task] } }
        : undefined
    })
    vi.stubGlobal('fetch', fetchMock)
  }

  beforeEach(() => {
    localStorage.clear()
    document.title = ''
    useThemeStore.setState({ mode: 'light' })
    vi.stubGlobal(
      'matchMedia',
      vi.fn(() => ({ matches: false, addEventListener: vi.fn(), removeEventListener: vi.fn() })),
    )
    useAuthStore.getState().signIn(session)
    mockApi()
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('il titolo della scheda dice in che pagina si è', async () => {
    renderApp('/calendar')

    await waitFor(() => expect(document.title).toBe('Calendario · Smart TODO'))
  })

  it('una mutazione fallita lo dice, invece di annullarsi in silenzio', async () => {
    mockApi((request) =>
      request.method === 'PUT' ? { body: { message: 'Task non trovato' }, status: 404 } : undefined,
    )
    renderApp('/tasks')

    await userEvent.click(await screen.findByRole('checkbox', { name: /Completa/ }))

    expect(await screen.findByText('Task non trovato')).toBeInTheDocument()
  })

  it('premere / porta il cursore nella ricerca', async () => {
    renderApp('/tasks')
    const search = await screen.findByLabelText('Cerca fra i task')

    await userEvent.keyboard('/')

    expect(search).toHaveFocus()
  })

  it('la barra non intercetta / mentre si sta scrivendo altrove', async () => {
    renderApp('/tasks')
    const quickAdd = await screen.findByLabelText('Nuovo task')

    await userEvent.type(quickAdd, 'a/b')

    expect(quickAdd).toHaveValue('a/b')
    expect(quickAdd).toHaveFocus()
  })
})
