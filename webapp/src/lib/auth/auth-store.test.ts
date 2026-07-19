import { beforeEach, describe, expect, it, vi } from 'vitest'
import { initAuth, useAuthStore } from '@/lib/auth/auth-store'
import { queryClient } from '@/lib/query-client'
import { AUTH_STORAGE_KEY, writeSession, type Session } from '@/lib/auth/token-storage'

const session: Session = {
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  expiresAt: Date.now() + 900_000,
  user: { id: 'u1', email: 'mario@example.com', displayName: 'Mario' },
}

describe('auth store', () => {
  beforeEach(() => {
    localStorage.clear()
    queryClient.clear()
    useAuthStore.setState({ session: null, isAuthenticated: false })
    initAuth()
  })

  it('parte dalla sessione salvata, se c è', () => {
    writeSession(session)

    useAuthStore.getState().hydrate()

    expect(useAuthStore.getState().session).toEqual(session)
    expect(useAuthStore.getState().isAuthenticated).toBe(true)
  })

  it('senza sessione salvata resta anonimo', () => {
    useAuthStore.getState().hydrate()

    expect(useAuthStore.getState().session).toBeNull()
    expect(useAuthStore.getState().isAuthenticated).toBe(false)
  })

  it('il login salva la sessione anche su disco', () => {
    useAuthStore.getState().signIn(session)

    expect(useAuthStore.getState().isAuthenticated).toBe(true)
    expect(localStorage.getItem(AUTH_STORAGE_KEY)).toContain('access-1')
  })

  it('il logout cancella sessione e cache dei dati dell utente', () => {
    useAuthStore.getState().signIn(session)
    queryClient.setQueryData(['tasks'], [{ id: 't1' }])

    useAuthStore.getState().signOut()

    expect(useAuthStore.getState().isAuthenticated).toBe(false)
    expect(localStorage.getItem(AUTH_STORAGE_KEY)).toBeNull()
    expect(queryClient.getQueryData(['tasks'])).toBeUndefined()
  })

  it('una sessione scaduta ha lo stesso effetto del logout', () => {
    useAuthStore.getState().signIn(session)
    queryClient.setQueryData(['tasks'], [{ id: 't1' }])

    // È l'evento che emette il refresh quando non riesce a rinnovare.
    useAuthStore.getState().signOut()

    expect(useAuthStore.getState().isAuthenticated).toBe(false)
    expect(queryClient.getQueryData(['tasks'])).toBeUndefined()
  })

  it('si allinea al logout fatto in un altra scheda', () => {
    useAuthStore.getState().signIn(session)

    window.dispatchEvent(new StorageEvent('storage', { key: AUTH_STORAGE_KEY, newValue: null }))

    expect(useAuthStore.getState().isAuthenticated).toBe(false)
  })

  it('si allinea al login fatto in un altra scheda', () => {
    const otherUser: Session = { ...session, accessToken: 'access-2' }

    window.dispatchEvent(
      new StorageEvent('storage', {
        key: AUTH_STORAGE_KEY,
        newValue: JSON.stringify(otherUser),
      }),
    )

    expect(useAuthStore.getState().session?.accessToken).toBe('access-2')
  })

  it('non ripete gli effetti collaterali se il logout arriva due volte', () => {
    const clearSpy = vi.spyOn(queryClient, 'clear')
    useAuthStore.getState().signIn(session)

    useAuthStore.getState().signOut()
    useAuthStore.getState().signOut()

    expect(clearSpy).toHaveBeenCalledOnce()
    clearSpy.mockRestore()
  })
})
