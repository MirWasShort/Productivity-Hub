import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { useAuthStore } from '@/lib/auth/auth-store'
import type { Session } from '@/lib/auth/token-storage'
import { renderApp } from '@/test/render-app'
import { useThemeStore } from '@/lib/theme/theme-store'

const session: Session = {
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  expiresAt: Date.now() + 900_000,
  user: { id: 'u1', email: 'mario@example.com', displayName: 'Mario' },
}

function signIn() {
  useAuthStore.getState().signIn(session)
}

describe('router', () => {
  beforeEach(() => {
    localStorage.clear()
    vi.stubGlobal(
      'matchMedia',
      vi.fn(() => ({ matches: false, addEventListener: vi.fn(), removeEventListener: vi.fn() })),
    )
    useThemeStore.setState({ mode: 'light' })
    useAuthStore.setState({ session: null, isAuthenticated: false })
    // La lista dei task chiama il backend appena montata.
    vi.stubGlobal(
      'fetch',
      vi.fn(() =>
        Promise.resolve(
          new Response(JSON.stringify({ items: [] }), {
            headers: { 'content-type': 'application/json' },
          }),
        ),
      ),
    )
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('la radice porta ai task', async () => {
    signIn()
    renderApp('/')

    expect(await screen.findByRole('heading', { name: 'I miei task' })).toBeInTheDocument()
  })

  it('mostra le tre destinazioni principali nella navigazione', async () => {
    signIn()
    renderApp('/tasks')

    const nav = await screen.findByRole('navigation')
    expect(nav).toHaveTextContent('Task')
    expect(nav).toHaveTextContent('Calendario')
    expect(nav).toHaveTextContent('Dashboard')
  })

  it('naviga tra le sezioni senza ricaricare la shell', async () => {
    signIn()
    renderApp('/tasks')

    await userEvent.click(await screen.findByRole('link', { name: 'Calendario' }))

    expect(await screen.findByRole('heading', { name: 'Calendario' })).toBeInTheDocument()
    expect(screen.getByRole('navigation')).toBeInTheDocument()
  })

  it('login e registrazione stanno fuori dalla shell', async () => {
    renderApp('/login')

    expect(await screen.findByRole('heading', { name: 'Accedi' })).toBeInTheDocument()
    expect(screen.queryByRole('navigation')).not.toBeInTheDocument()
  })

  it('una rotta sconosciuta mostra la pagina non trovata', async () => {
    signIn()
    renderApp('/inesistente')

    expect(await screen.findByText(/pagina non trovata/i)).toBeInTheDocument()
  })

  describe('guard di sessione', () => {
    it('senza sessione una rotta protetta manda al login', async () => {
      renderApp('/tasks')

      expect(await screen.findByRole('heading', { name: 'Accedi' })).toBeInTheDocument()
    })

    it('con sessione il login rimanda ai task', async () => {
      signIn()
      renderApp('/login')

      expect(await screen.findByRole('heading', { name: 'I miei task' })).toBeInTheDocument()
    })

    it('il logout riporta al login anche se si è già dentro', async () => {
      signIn()
      renderApp('/tasks')
      expect(await screen.findByRole('heading', { name: 'I miei task' })).toBeInTheDocument()

      useAuthStore.getState().signOut()

      expect(await screen.findByRole('heading', { name: 'Accedi' })).toBeInTheDocument()
    })
  })
})
