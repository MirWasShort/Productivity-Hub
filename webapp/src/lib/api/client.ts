import type { ApiErrorBody } from '@/api/types'
import { apiUrl } from '@/lib/api/config'
import { ApiError, NetworkError } from '@/lib/api/errors'
import { ensureFreshToken, isAccessTokenStale } from '@/lib/auth/refresh'
import { readSession } from '@/lib/auth/token-storage'

export type QueryParams = Record<string, string | number | boolean | null | undefined>

export interface ApiRequestOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  body?: unknown
  params?: QueryParams
  signal?: AbortSignal
  /** Salta l'header Authorization (login, registrazione, refresh). */
  anonymous?: boolean
}

function buildUrl(path: string, params?: QueryParams): string {
  const url = apiUrl(path)
  for (const [key, value] of Object.entries(params ?? {})) {
    // `undefined` e `null` significano "filtro non attivo": non vanno in query.
    if (value !== undefined && value !== null) {
      url.searchParams.set(key, String(value))
    }
  }
  return url.toString()
}

export function buildRequest(path: string, options: ApiRequestOptions = {}): Request {
  const { method = 'GET', body, params, signal, anonymous } = options
  const headers = new Headers({ accept: 'application/json' })

  if (body !== undefined) {
    headers.set('content-type', 'application/json')
  }
  if (!anonymous) {
    const session = readSession()
    if (session) {
      headers.set('authorization', `Bearer ${session.accessToken}`)
    }
  }

  return new Request(buildUrl(path, params), {
    method,
    headers,
    body: body === undefined ? undefined : JSON.stringify(body),
    signal,
  })
}

async function readBody<T>(response: Response): Promise<T> {
  // 204 (delete) e corpi vuoti: non c'è niente da deserializzare.
  if (response.status === 204 || response.headers.get('content-length') === '0') {
    return undefined as T
  }
  const text = await response.text()
  return (text ? (JSON.parse(text) as T) : undefined) as T
}

async function readErrorBody(response: Response): Promise<ApiErrorBody | null> {
  try {
    return (await response.clone().json()) as ApiErrorBody
  } catch {
    // Proxy, gateway o pagine di errore HTML: nessun ErrorResponse da leggere.
    return null
  }
}

/** Esegue la richiesta e traduce l'esito in valore o eccezione tipizzata. */
export async function sendRequest<T>(request: Request): Promise<T> {
  let response: Response
  try {
    response = await fetch(request)
  } catch (cause) {
    throw new NetworkError(cause)
  }

  if (!response.ok) {
    throw new ApiError(response.status, await readErrorBody(response))
  }
  return readBody<T>(response)
}

/** Le rotte di autenticazione non hanno un token da rinnovare. */
function isAuthRoute(path: string): boolean {
  return path.startsWith('/auth/')
}

/**
 * Punto d'ingresso unico verso il backend, con rinnovo trasparente del token:
 * chi chiama non sa che i token esistono.
 *
 * Due momenti in cui si rinnova: *prima* di partire, se l'access token è
 * scaduto o ci manca poco (evita un giro a vuoto), e *dopo* un 401, che resta
 * possibile perché l'orologio del client può essere fuori sincrono. La
 * richiesta viene ricostruita da capo, così riparte con l'header aggiornato.
 */
export async function apiFetch<T>(path: string, options: ApiRequestOptions = {}): Promise<T> {
  const refreshable = !options.anonymous && !isAuthRoute(path)
  const session = readSession()

  if (refreshable && session && isAccessTokenStale(session)) {
    await ensureFreshToken()
  }

  try {
    return await sendRequest<T>(buildRequest(path, options))
  } catch (error) {
    // Un solo tentativo: se anche la richiesta ripetuta torna 401, il
    // problema non è il token e insistere significherebbe un ciclo infinito.
    if (!refreshable || !session || !(error instanceof ApiError) || !error.isUnauthorized) {
      throw error
    }
    await ensureFreshToken()
    return sendRequest<T>(buildRequest(path, options))
  }
}
