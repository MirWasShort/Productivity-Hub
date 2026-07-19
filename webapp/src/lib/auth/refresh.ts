import type { AuthResponse } from '@/api/types'
import { apiUrl } from '@/lib/api/config'
import { SessionExpiredError } from '@/lib/api/errors'
import { clearSession, readSession, writeSession, type Session } from '@/lib/auth/token-storage'

/** Margine con cui consideriamo "già scaduto" un access token ancora valido. */
const EXPIRY_SKEW_MS = 30_000

/**
 * Il refresh in corso, condiviso da tutte le richieste che lo aspettano.
 *
 * È il pezzo che non si può sbagliare: il backend **ruota** i refresh token e
 * li invalida al primo uso (`AuthService.refresh`). Due richieste che vanno in
 * 401 insieme e chiamano il refresh ciascuna per conto suo brucerebbero il
 * token due volte: la seconda troverebbe un token già revocato e butterebbe
 * fuori l'utente. Condividere la promessa fa sì che la chiamata di rete sia
 * una sola, e che entrambe ricevano la stessa coppia nuova.
 */
let inflightRefresh: Promise<Session> | null = null

type SessionExpiredListener = () => void
const expiredListeners = new Set<SessionExpiredListener>()

/** Registra un ascoltatore per la fine della sessione; restituisce come annullarlo. */
export function onSessionExpired(listener: SessionExpiredListener): () => void {
  expiredListeners.add(listener)
  return () => expiredListeners.delete(listener)
}

function sessionEnded(): SessionExpiredError {
  clearSession()
  for (const listener of expiredListeners) {
    listener()
  }
  return new SessionExpiredError()
}

/** True se l'access token è scaduto o sta per scadere. */
export function isAccessTokenStale(session: Session, now = Date.now()): boolean {
  return session.expiresAt - EXPIRY_SKEW_MS <= now
}

function toSession(auth: AuthResponse): Session {
  return {
    accessToken: auth.accessToken,
    refreshToken: auth.refreshToken,
    expiresAt: Date.now() + auth.expiresIn * 1000,
    user: auth.user,
  }
}

async function requestNewPair(refreshToken: string): Promise<Session> {
  // Richiesta "nuda": niente Authorization (l'access token è scaduto) e
  // nessun aggancio al refresh, per non ricorrere all'infinito.
  const response = await fetch(
    new Request(apiUrl('/auth/refresh'), {
      method: 'POST',
      headers: { 'content-type': 'application/json', accept: 'application/json' },
      body: JSON.stringify({ refreshToken }),
    }),
  ).catch(() => null)

  if (!response?.ok) {
    throw sessionEnded()
  }

  const session = toSession((await response.json()) as AuthResponse)
  writeSession(session)
  return session
}

/**
 * Restituisce una sessione con un access token valido, rinnovandolo se serve.
 * Chiamate concorrenti condividono lo stesso refresh.
 */
export function ensureFreshToken(): Promise<Session> {
  inflightRefresh ??= (() => {
    const session = readSession()
    if (!session) {
      return Promise.reject(sessionEnded())
    }
    return requestNewPair(session.refreshToken)
  })().finally(() => {
    inflightRefresh = null
  })

  return inflightRefresh
}
