import type { ApiErrorBody } from '@/api/types'
import { ApiError, NetworkError } from '@/lib/api/errors'
import { readSession } from '@/lib/auth/token-storage'

/** Host del backend; il percorso `/api/v1` lo aggiunge il client. */
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8081'
const API_PREFIX = '/api/v1'

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
  const url = new URL(`${API_PREFIX}${path}`, API_BASE_URL)
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

/**
 * Punto d'ingresso unico verso il backend. In C44 si aggiunge qui il refresh
 * trasparente del token, così nessuna schermata deve occuparsene.
 */
export function apiFetch<T>(path: string, options: ApiRequestOptions = {}): Promise<T> {
  return sendRequest<T>(buildRequest(path, options))
}
