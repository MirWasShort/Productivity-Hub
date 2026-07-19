import { create } from 'zustand'
import { onSessionExpired } from '@/lib/auth/refresh'
import {
  clearSession,
  onSessionChangedElsewhere,
  readSession,
  writeSession,
  type Session,
} from '@/lib/auth/token-storage'
import { queryClient } from '@/lib/query-client'

interface AuthState {
  session: Session | null
  isAuthenticated: boolean
  /** Rilegge la sessione dal disco: all'avvio e quando cambia in un'altra scheda. */
  hydrate: () => void
  signIn: (session: Session) => void
  signOut: () => void
}

function applySession(session: Session | null) {
  return { session, isAuthenticated: session !== null }
}

export const useAuthStore = create<AuthState>((set, get) => ({
  ...applySession(null),

  hydrate: () => set(applySession(readSession())),

  signIn: (session) => {
    writeSession(session)
    set(applySession(session))
  },

  signOut: () => {
    // Idempotente: la sessione può finire per logout, per refresh fallito o
    // per un'altra scheda, e i tre percorsi possono sovrapporsi.
    if (!get().isAuthenticated) {
      return
    }
    clearSession()
    // Senza questo, il prossimo utente vedrebbe per un istante i task del
    // precedente: è la stessa pulizia che AuthNotifier fa in Flutter.
    queryClient.clear()
    set(applySession(null))
  },
}))

let listenersRegistered = false

/**
 * Aggancia lo store agli eventi che arrivano da fuori React: il refresh che
 * si arrende e le altre schede del browser. Chiamata una volta all'avvio;
 * idempotente, così i test possono invocarla senza accumulare ascoltatori.
 */
export function initAuth() {
  useAuthStore.getState().hydrate()

  if (listenersRegistered) {
    return
  }
  listenersRegistered = true

  onSessionExpired(() => useAuthStore.getState().signOut())

  onSessionChangedElsewhere((session) => {
    if (session) {
      useAuthStore.setState(applySession(session))
    } else {
      useAuthStore.getState().signOut()
    }
  })
}
