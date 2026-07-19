import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { AnalyticsSummary, Completions } from '@/api/types'
import { useAuthStore } from '@/lib/auth/auth-store'
import type { Session } from '@/lib/auth/token-storage'
import { useThemeStore } from '@/lib/theme/theme-store'
import { createApiMock, requestsWithMethod } from '@/test/api-mock'
import { renderApp } from '@/test/render-app'

const session: Session = {
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  expiresAt: Date.now() + 900_000,
  user: { id: 'u1', email: 'mario@example.com', displayName: 'Mario' },
}

const summary: AnalyticsSummary = {
  total: 12,
  completed: 5,
  overdue: 3,
  dueToday: 2,
  byStatus: { TODO: 4, IN_PROGRESS: 3, DONE: 5 },
  byPriority: { LOW: 2, MEDIUM: 6, HIGH: 4 },
}

const completions: Completions = {
  from: '2026-06-08',
  to: '2026-07-19',
  days: [{ date: '2026-07-14', count: 3 }],
}

describe('dashboard', () => {
  let fetchMock: ReturnType<typeof createApiMock>

  function mockApi(handler?: Parameters<typeof createApiMock>[0]) {
    fetchMock = createApiMock((request) => {
      const custom = handler?.(request)
      if (custom) {
        return custom
      }
      const { pathname } = new URL(request.url)
      if (pathname.endsWith('/analytics/summary')) {
        return { body: summary }
      }
      if (pathname.endsWith('/analytics/completions')) {
        return { body: completions }
      }
      return undefined
    })
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
    mockApi()
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('mostra i quattro numeri di riepilogo', async () => {
    renderApp('/dashboard')

    expect(await screen.findByText('Totali')).toBeInTheDocument()
    expect(screen.getByText('12')).toBeInTheDocument()
    expect(screen.getByText('Completati')).toBeInTheDocument()
    expect(screen.getByText('In ritardo')).toBeInTheDocument()
    expect(screen.getByText('3')).toBeInTheDocument()
  })

  it('la ripartizione per priorità ha etichette e percentuali, non solo colori', async () => {
    renderApp('/dashboard')

    expect(await screen.findByText('Bassa — 2 (17%)')).toBeInTheDocument()
    expect(screen.getByText('Media — 6 (50%)')).toBeInTheDocument()
    expect(screen.getByText('Alta — 4 (33%)')).toBeInTheDocument()
  })

  it('chiede sei settimane di storico al backend', async () => {
    renderApp('/dashboard')
    await screen.findByText('Totali')

    const request = requestsWithMethod(fetchMock, 'GET').find((candidate) =>
      candidate.url.includes('/analytics/completions'),
    )!
    expect(new URL(request.url).searchParams.get('days')).toBe('42')
  })

  it('senza task la ripartizione lo dice invece di disegnare un anello vuoto', async () => {
    mockApi((request) =>
      request.url.includes('/analytics/summary')
        ? {
            body: {
              ...summary,
              total: 0,
              completed: 0,
              overdue: 0,
              dueToday: 0,
              byPriority: {},
            },
          }
        : undefined,
    )
    renderApp('/dashboard')

    expect(await screen.findByText('Nessun task da ripartire.')).toBeInTheDocument()
  })

  it('il pulsante Aggiorna rilegge le statistiche', async () => {
    renderApp('/dashboard')
    await screen.findByText('Totali')
    const before = requestsWithMethod(fetchMock, 'GET').filter((request) =>
      request.url.includes('/analytics/'),
    ).length

    await userEvent.click(screen.getByRole('button', { name: /Aggiorna/ }))

    const after = requestsWithMethod(fetchMock, 'GET').filter((request) =>
      request.url.includes('/analytics/'),
    ).length
    expect(after).toBeGreaterThan(before)
  })

  it('se le statistiche non arrivano lo dice', async () => {
    mockApi((request) =>
      request.url.includes('/analytics/')
        ? { body: { message: 'Errore interno' }, status: 500 }
        : undefined,
    )
    renderApp('/dashboard')

    expect(await screen.findByRole('alert')).toHaveTextContent(/non riesco a caricare/i)
  })
})
