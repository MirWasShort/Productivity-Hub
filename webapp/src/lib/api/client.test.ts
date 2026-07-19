import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { apiFetch } from '@/lib/api/client'
import { ApiError, NetworkError } from '@/lib/api/errors'
import { clearSession, writeSession } from '@/lib/auth/token-storage'

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  })
}

function lastRequest(fetchMock: ReturnType<typeof vi.fn>): Request {
  return fetchMock.mock.calls.at(-1)![0] as Request
}

describe('apiFetch', () => {
  let fetchMock: ReturnType<typeof vi.fn>

  beforeEach(() => {
    localStorage.clear()
    fetchMock = vi.fn()
    vi.stubGlobal('fetch', fetchMock)
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('compone l URL sotto /api/v1 e restituisce il corpo JSON', async () => {
    fetchMock.mockResolvedValue(jsonResponse({ id: 't1' }))

    const result = await apiFetch<{ id: string }>('/tasks/t1')

    expect(lastRequest(fetchMock).url).toBe('http://localhost:8081/api/v1/tasks/t1')
    expect(result).toEqual({ id: 't1' })
  })

  it('serializza i parametri di query saltando quelli non valorizzati', async () => {
    fetchMock.mockResolvedValue(jsonResponse({ items: [] }))

    await apiFetch('/tasks', {
      params: { status: 'TODO', search: undefined, page: 0, tagId: null },
    })

    const url = new URL(lastRequest(fetchMock).url)
    expect(url.pathname).toBe('/api/v1/tasks')
    expect(url.searchParams.get('status')).toBe('TODO')
    expect(url.searchParams.get('page')).toBe('0')
    expect(url.searchParams.has('search')).toBe(false)
    expect(url.searchParams.has('tagId')).toBe(false)
  })

  it('allega il token quando c è una sessione', async () => {
    writeSession({
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
      expiresAt: Date.now() + 60_000,
      user: { id: 'u1', email: 'a@b.it', displayName: 'A' },
    })
    fetchMock.mockResolvedValue(jsonResponse({}))

    await apiFetch('/tasks')

    expect(lastRequest(fetchMock).headers.get('authorization')).toBe('Bearer access-1')
  })

  it('non allega nulla senza sessione', async () => {
    clearSession()
    fetchMock.mockResolvedValue(jsonResponse({}))

    await apiFetch('/tasks')

    expect(lastRequest(fetchMock).headers.get('authorization')).toBeNull()
  })

  it('invia il corpo come JSON', async () => {
    fetchMock.mockResolvedValue(jsonResponse({ id: 't1' }, 201))

    await apiFetch('/tasks', { method: 'POST', body: { title: 'Comprare il latte' } })

    const request = lastRequest(fetchMock)
    expect(request.method).toBe('POST')
    expect(request.headers.get('content-type')).toBe('application/json')
    await expect(request.json()).resolves.toEqual({ title: 'Comprare il latte' })
  })

  it('gestisce il 204 senza corpo', async () => {
    fetchMock.mockResolvedValue(new Response(null, { status: 204 }))

    await expect(apiFetch('/tasks/t1', { method: 'DELETE' })).resolves.toBeUndefined()
  })

  it('trasforma un errore del backend in ApiError con messaggio e fieldErrors', async () => {
    fetchMock.mockResolvedValue(
      jsonResponse(
        {
          status: 400,
          error: 'Bad Request',
          message: 'Validazione fallita',
          fieldErrors: { title: 'non può essere vuoto' },
        },
        400,
      ),
    )

    const error = await apiFetch('/tasks', { method: 'POST', body: {} }).catch((e: unknown) => e)

    expect(error).toBeInstanceOf(ApiError)
    expect((error as ApiError).status).toBe(400)
    expect((error as ApiError).message).toBe('Validazione fallita')
    expect((error as ApiError).fieldErrors).toEqual({ title: 'non può essere vuoto' })
  })

  it('usa un messaggio di ripiego se il corpo di errore non è leggibile', async () => {
    fetchMock.mockResolvedValue(new Response('<html>502</html>', { status: 502 }))

    const error = (await apiFetch('/tasks').catch((e: unknown) => e)) as ApiError

    expect(error).toBeInstanceOf(ApiError)
    expect(error.status).toBe(502)
    expect(error.message).toMatch(/qualcosa è andato storto/i)
  })

  it('distingue la rete assente da un errore del server', async () => {
    fetchMock.mockRejectedValue(new TypeError('Failed to fetch'))

    const error = (await apiFetch('/tasks').catch((e: unknown) => e)) as NetworkError

    expect(error).toBeInstanceOf(NetworkError)
    expect(error.message).toMatch(/connessione/i)
  })

  it('riconosce i codici di stato utili alle schermate', async () => {
    fetchMock.mockResolvedValue(jsonResponse({ message: 'Email già registrata' }, 409))

    const error = (await apiFetch('/auth/register', { method: 'POST' }).catch(
      (e: unknown) => e,
    )) as ApiError

    expect(error.isConflict).toBe(true)
    expect(error.isUnauthorized).toBe(false)
    expect(error.isNotFound).toBe(false)
  })
})
