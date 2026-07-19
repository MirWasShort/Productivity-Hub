import { beforeEach, describe, expect, it, vi } from 'vitest'
import {
  AUTH_STORAGE_KEY,
  clearSession,
  onSessionChangedElsewhere,
  readSession,
  writeSession,
  type Session,
} from '@/lib/auth/token-storage'

const session: Session = {
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  expiresAt: 1_800_000_000_000,
  user: { id: 'u1', email: 'mario@example.com', displayName: 'Mario' },
}

describe('token storage', () => {
  beforeEach(() => {
    localStorage.clear()
  })

  it('senza nulla salvato non c è sessione', () => {
    expect(readSession()).toBeNull()
  })

  it('salva e rilegge la sessione', () => {
    writeSession(session)

    expect(readSession()).toEqual(session)
  })

  it('cancella la sessione', () => {
    writeSession(session)

    clearSession()

    expect(readSession()).toBeNull()
    expect(localStorage.getItem(AUTH_STORAGE_KEY)).toBeNull()
  })

  it('ignora un contenuto corrotto invece di far esplodere l app', () => {
    localStorage.setItem(AUTH_STORAGE_KEY, '{non-json')

    expect(readSession()).toBeNull()
  })

  it('ignora un oggetto senza i campi attesi', () => {
    localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify({ accessToken: 'solo-questo' }))

    expect(readSession()).toBeNull()
  })

  it('avvisa quando un altra scheda cambia la sessione', () => {
    const listener = vi.fn()
    onSessionChangedElsewhere(listener)

    window.dispatchEvent(
      new StorageEvent('storage', { key: AUTH_STORAGE_KEY, newValue: JSON.stringify(session) }),
    )
    window.dispatchEvent(new StorageEvent('storage', { key: AUTH_STORAGE_KEY, newValue: null }))
    window.dispatchEvent(new StorageEvent('storage', { key: 'ph.theme', newValue: 'dark' }))

    expect(listener).toHaveBeenCalledTimes(2)
    expect(listener).toHaveBeenNthCalledWith(1, session)
    expect(listener).toHaveBeenNthCalledWith(2, null)
  })
})
