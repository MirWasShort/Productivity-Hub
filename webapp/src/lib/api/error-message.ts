import { ApiError, NetworkError, SessionExpiredError } from '@/lib/api/errors'

/**
 * Il messaggio da mostrare all'utente per un errore qualsiasi. Le eccezioni
 * tipizzate del client hanno già un testo sensato; per tutto il resto si evita
 * di riversare a schermo il messaggio grezzo di un'eccezione.
 */
export function errorMessage(error: unknown): string {
  if (error instanceof ApiError || error instanceof NetworkError) {
    return error.message
  }
  if (error instanceof SessionExpiredError) {
    return error.message
  }
  return 'Qualcosa è andato storto. Riprova.'
}
