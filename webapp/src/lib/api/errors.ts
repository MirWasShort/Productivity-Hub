import type { ApiErrorBody } from '@/api/types'

/** Messaggio mostrato quando il backend non ne fornisce uno leggibile. */
export const GENERIC_ERROR_MESSAGE = 'Qualcosa è andato storto. Riprova.'

/**
 * Errore con una risposta HTTP dietro. Il backend usa sempre lo stesso corpo
 * (`ErrorResponse`), quindi qui si estraggono messaggio e `fieldErrors` una
 * volta sola, invece che in ogni schermata.
 */
export class ApiError extends Error {
  readonly status: number
  readonly body: ApiErrorBody | null

  constructor(status: number, body: ApiErrorBody | null) {
    super(body?.message?.trim() || GENERIC_ERROR_MESSAGE)
    this.name = 'ApiError'
    this.status = status
    this.body = body
  }

  /** Errori per campo di una 400 di validazione, pronti per il form. */
  get fieldErrors(): Record<string, string> | undefined {
    return this.body?.fieldErrors
  }

  get isUnauthorized(): boolean {
    return this.status === 401
  }

  get isNotFound(): boolean {
    return this.status === 404
  }

  get isConflict(): boolean {
    return this.status === 409
  }
}

/** La richiesta non è mai arrivata al server (offline, DNS, CORS, timeout). */
export class NetworkError extends Error {
  constructor(cause?: unknown) {
    super('Nessuna connessione: controlla la rete e riprova.')
    this.name = 'NetworkError'
    this.cause = cause
  }
}

/** Il refresh è fallito: la sessione è finita e va rifatto il login. */
export class SessionExpiredError extends Error {
  constructor() {
    super('Sessione scaduta: accedi di nuovo.')
    this.name = 'SessionExpiredError'
  }
}
