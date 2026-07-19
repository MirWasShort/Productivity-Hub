import { vi } from 'vitest'

export interface MockedResponse {
  body: unknown
  status?: number
}

/**
 * Finto backend per i test.
 *
 * Serve un instradamento per percorso, non una risposta unica: da quando la
 * barra laterale carica le liste, ogni pagina fa più chiamate diverse, e un
 * mock che risponde sempre la stessa cosa manderebbe una lista di task dove il
 * codice si aspetta un array di liste.
 *
 * L'handler può restituire `undefined` per lasciar rispondere il ripiego:
 * elenco vuoto per liste e tag, pagina vuota per i task.
 */
export function createApiMock(handler?: (request: Request) => MockedResponse | undefined) {
  return vi.fn((request: Request) => {
    const { pathname } = new URL(request.url)
    const custom = handler?.(request)
    const fallback: MockedResponse = {
      body: pathname.endsWith('/lists') || pathname.endsWith('/tags') ? [] : { items: [] },
    }
    const { body, status = 200 } = custom ?? fallback

    // Una `Response` nuova a ogni chiamata: il corpo si consuma leggendolo.
    return Promise.resolve(
      new Response(JSON.stringify(body), {
        status,
        headers: { 'content-type': 'application/json' },
      }),
    )
  })
}

/** Le richieste inviate con quel metodo, in ordine di invio. */
export function requestsWithMethod(
  fetchMock: ReturnType<typeof createApiMock>,
  method: string,
): Request[] {
  return fetchMock.mock.calls
    .map((call) => call[0] as Request)
    .filter((request) => request.method === method)
}

/** Solo le GET della lista dei task (escluse liste, tag e dettagli). */
export function taskListRequests(fetchMock: ReturnType<typeof createApiMock>): Request[] {
  return requestsWithMethod(fetchMock, 'GET').filter((request) =>
    new URL(request.url).pathname.endsWith('/tasks'),
  )
}
