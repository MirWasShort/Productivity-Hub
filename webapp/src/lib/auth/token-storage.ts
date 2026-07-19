import type { User } from '@/api/types'

/**
 * La sessione vive in `localStorage`. Il backend non offre cookie
 * (`allowCredentials` è false e non esiste un endpoint di logout), quindi il
 * token deve essere leggibile da JavaScript: è lo stesso compromesso del
 * client Flutter, che li tiene in `flutter_secure_storage`.
 * Contropartita accettata: un XSS leggerebbe la sessione. Le difese sono a
 * monte — niente HTML iniettato, dipendenze sotto controllo, CSP al deploy.
 */
export interface Session {
  accessToken: string
  refreshToken: string
  /** Istante di scadenza dell'access token, in millisecondi epoch. */
  expiresAt: number
  user: User
}

export const AUTH_STORAGE_KEY = 'ph.auth.v1'

function parseSession(raw: string | null): Session | null {
  if (!raw) {
    return null
  }
  try {
    const parsed: unknown = JSON.parse(raw)
    if (
      typeof parsed === 'object' &&
      parsed !== null &&
      'accessToken' in parsed &&
      'refreshToken' in parsed &&
      'expiresAt' in parsed &&
      'user' in parsed
    ) {
      return parsed as Session
    }
    return null
  } catch {
    // Contenuto manomesso o scritto da una versione precedente: trattalo come
    // "nessuna sessione" invece di propagare l'eccezione.
    return null
  }
}

export function readSession(): Session | null {
  return parseSession(localStorage.getItem(AUTH_STORAGE_KEY))
}

export function writeSession(session: Session): void {
  localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(session))
}

export function clearSession(): void {
  localStorage.removeItem(AUTH_STORAGE_KEY)
}

/**
 * L'evento `storage` scatta solo nelle *altre* schede: è il modo per
 * accorgersi che l'utente ha fatto login o logout altrove e allinearsi.
 */
export function onSessionChangedElsewhere(listener: (session: Session | null) => void): () => void {
  const handler = (event: StorageEvent) => {
    if (event.key === AUTH_STORAGE_KEY) {
      listener(parseSession(event.newValue))
    }
  }
  window.addEventListener('storage', handler)
  return () => window.removeEventListener('storage', handler)
}
