import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { useAuthStore } from '@/lib/auth/auth-store'
import { queryClient } from '@/lib/query-client'
import { renderApp } from '@/test/render-app'
import { useThemeStore } from '@/lib/theme/theme-store'

import { createApiMock } from '@/test/api-mock'

/** Risponde alle rotte di autenticazione; al resto pensa il ripiego. */
function authResponds(body: unknown, status = 200) {
  return (request: Request) => (request.url.includes('/auth/') ? { body, status } : undefined)
}

const authResponse = {
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  expiresIn: 900,
  user: { id: 'u1', email: 'mario@example.com', displayName: 'Mario' },
}

describe('schermate di autenticazione', () => {
  let fetchMock: ReturnType<typeof createApiMock>

  beforeEach(() => {
    localStorage.clear()
    queryClient.clear()
    useAuthStore.setState({ session: null, isAuthenticated: false })
    useThemeStore.setState({ mode: 'light' })
    vi.stubGlobal(
      'matchMedia',
      vi.fn(() => ({ matches: false, addEventListener: vi.fn(), removeEventListener: vi.fn() })),
    )
    fetchMock = createApiMock()
    vi.stubGlobal('fetch', fetchMock)
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  describe('login', () => {
    it('non chiama il backend se l email non è valida', async () => {
      renderApp('/login')

      await userEvent.type(screen.getByLabelText('Email'), 'non-una-email')
      await userEvent.type(screen.getByLabelText('Password'), 'segretissima')
      await userEvent.click(screen.getByRole('button', { name: 'Accedi' }))

      expect(await screen.findByText(/indirizzo email valido/i)).toBeInTheDocument()
      expect(fetchMock).not.toHaveBeenCalled()
    })

    it('con credenziali valide apre la sessione e porta ai task', async () => {
      fetchMock = createApiMock(authResponds(authResponse))
      vi.stubGlobal('fetch', fetchMock)
      renderApp('/login')

      await userEvent.type(screen.getByLabelText('Email'), 'mario@example.com')
      await userEvent.type(screen.getByLabelText('Password'), 'segretissima')
      await userEvent.click(screen.getByRole('button', { name: 'Accedi' }))

      expect(await screen.findByRole('heading', { name: 'I miei task' })).toBeInTheDocument()
      expect(useAuthStore.getState().session?.accessToken).toBe('access-1')
    })

    it('mostra il messaggio del backend se le credenziali sono sbagliate', async () => {
      fetchMock = createApiMock(authResponds({ message: 'Credenziali non valide' }, 401))
      vi.stubGlobal('fetch', fetchMock)
      renderApp('/login')

      await userEvent.type(screen.getByLabelText('Email'), 'mario@example.com')
      await userEvent.type(screen.getByLabelText('Password'), 'sbagliata')
      await userEvent.click(screen.getByRole('button', { name: 'Accedi' }))

      expect(await screen.findByText('Credenziali non valide')).toBeInTheDocument()
      expect(useAuthStore.getState().isAuthenticated).toBe(false)
    })

    it('dopo il login torna alla pagina che si voleva aprire', async () => {
      fetchMock = createApiMock(authResponds(authResponse))
      vi.stubGlobal('fetch', fetchMock)
      renderApp('/dashboard')

      expect(await screen.findByRole('heading', { name: 'Accedi' })).toBeInTheDocument()
      await userEvent.type(screen.getByLabelText('Email'), 'mario@example.com')
      await userEvent.type(screen.getByLabelText('Password'), 'segretissima')
      await userEvent.click(screen.getByRole('button', { name: 'Accedi' }))

      expect(await screen.findByRole('heading', { name: 'Dashboard' })).toBeInTheDocument()
    })
  })

  describe('registrazione', () => {
    it('segnala le password che non coincidono senza chiamare il backend', async () => {
      renderApp('/register')

      await userEvent.type(screen.getByLabelText('Nome'), 'Mario')
      await userEvent.type(screen.getByLabelText('Email'), 'mario@example.com')
      await userEvent.type(screen.getByLabelText('Password'), 'segretissima')
      await userEvent.type(screen.getByLabelText('Conferma password'), 'altrocheddio')
      await userEvent.click(screen.getByRole('button', { name: 'Crea account' }))

      expect(await screen.findByText(/non coincidono/i)).toBeInTheDocument()
      expect(fetchMock).not.toHaveBeenCalled()
    })

    it('rifiuta una password troppo corta prima di partire', async () => {
      renderApp('/register')

      await userEvent.type(screen.getByLabelText('Nome'), 'Mario')
      await userEvent.type(screen.getByLabelText('Email'), 'mario@example.com')
      await userEvent.type(screen.getByLabelText('Password'), 'corta')
      await userEvent.type(screen.getByLabelText('Conferma password'), 'corta')
      await userEvent.click(screen.getByRole('button', { name: 'Crea account' }))

      expect(await screen.findByText(/almeno 8 caratteri/i)).toBeInTheDocument()
      expect(fetchMock).not.toHaveBeenCalled()
    })

    it('mostra sul campo email il conflitto restituito dal backend', async () => {
      fetchMock = createApiMock(authResponds({ message: 'Email già registrata' }, 409))
      vi.stubGlobal('fetch', fetchMock)
      renderApp('/register')

      await userEvent.type(screen.getByLabelText('Nome'), 'Mario')
      await userEvent.type(screen.getByLabelText('Email'), 'mario@example.com')
      await userEvent.type(screen.getByLabelText('Password'), 'segretissima')
      await userEvent.type(screen.getByLabelText('Conferma password'), 'segretissima')
      await userEvent.click(screen.getByRole('button', { name: 'Crea account' }))

      expect(await screen.findByText('Email già registrata')).toBeInTheDocument()
    })

    it('a registrazione riuscita si è già dentro', async () => {
      fetchMock = createApiMock(authResponds(authResponse, 201))
      vi.stubGlobal('fetch', fetchMock)
      renderApp('/register')

      await userEvent.type(screen.getByLabelText('Nome'), 'Mario')
      await userEvent.type(screen.getByLabelText('Email'), 'mario@example.com')
      await userEvent.type(screen.getByLabelText('Password'), 'segretissima')
      await userEvent.type(screen.getByLabelText('Conferma password'), 'segretissima')
      await userEvent.click(screen.getByRole('button', { name: 'Crea account' }))

      expect(await screen.findByRole('heading', { name: 'I miei task' })).toBeInTheDocument()
    })
  })
})
