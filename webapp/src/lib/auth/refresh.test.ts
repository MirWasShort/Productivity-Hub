import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { apiFetch } from '@/lib/api/client'
import { ApiError, SessionExpiredError } from '@/lib/api/errors'
import { onSessionExpired } from '@/lib/auth/refresh'
import { readSession, writeSession, type Session } from '@/lib/auth/token-storage'

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  })
}

function authHeaders(fetchMock: ReturnType<typeof vi.fn>): (string | null)[] {
  return fetchMock.mock.calls.map((call) => (call[0] as Request).headers.get('authorization'))
}

function refreshCalls(fetchMock: ReturnType<typeof vi.fn>): Request[] {
  return fetchMock.mock.calls
    .map((call) => call[0] as Request)
    .filter((request) => request.url.endsWith('/auth/refresh'))
}

const validSession: Session = {
  accessToken: 'vecchio-access',
  refreshToken: 'vecchio-refresh',
  expiresAt: Date.now() + 10 * 60_000,
  user: { id: 'u1', email: 'mario@example.com', displayName: 'Mario' },
}

/** Risposta del backend a un refresh andato a buon fine (token ruotati). */
const rotatedPair = {
  accessToken: 'nuovo-access',
  refreshToken: 'nuovo-refresh',
  expiresIn: 900,
  user: validSession.user,
}

describe('refresh trasparente', () => {
  let fetchMock: ReturnType<typeof vi.fn>

  beforeEach(() => {
    localStorage.clear()
    writeSession(validSession)
    fetchMock = vi.fn()
    vi.stubGlobal('fetch', fetchMock)
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('su 401 rinnova il token e ripete la richiesta', async () => {
    fetchMock
      .mockResolvedValueOnce(jsonResponse({ message: 'Token scaduto' }, 401))
      .mockResolvedValueOnce(jsonResponse(rotatedPair))
      .mockResolvedValueOnce(jsonResponse({ items: [{ id: 't1' }] }))

    const result = await apiFetch<{ items: { id: string }[] }>('/tasks')

    expect(result.items).toEqual([{ id: 't1' }])
    expect(authHeaders(fetchMock)).toEqual([
      'Bearer vecchio-access',
      null, // il refresh non manda l'access token scaduto
      'Bearer nuovo-access',
    ])
  })

  it('salva la coppia ruotata: il vecchio refresh token è ormai bruciato', async () => {
    fetchMock
      .mockResolvedValueOnce(jsonResponse({}, 401))
      .mockResolvedValueOnce(jsonResponse(rotatedPair))
      .mockResolvedValueOnce(jsonResponse({}))

    await apiFetch('/tasks')

    const session = readSession()
    expect(session?.accessToken).toBe('nuovo-access')
    expect(session?.refreshToken).toBe('nuovo-refresh')
    expect(session?.expiresAt).toBeGreaterThan(Date.now())
  })

  it('con due 401 in parallelo esegue un solo refresh e ripete entrambe', async () => {
    let releaseRefresh: (value: Response) => void = () => {}
    const pendingRefresh = new Promise<Response>((resolve) => {
      releaseRefresh = resolve
    })

    fetchMock.mockImplementation((request: Request) => {
      if (request.url.endsWith('/auth/refresh')) {
        return pendingRefresh
      }
      return Promise.resolve(
        request.headers.get('authorization') === 'Bearer nuovo-access'
          ? jsonResponse({ ok: request.url })
          : jsonResponse({ message: 'Token scaduto' }, 401),
      )
    })

    const both = Promise.all([apiFetch('/tasks'), apiFetch('/lists')])
    await vi.waitFor(() => expect(refreshCalls(fetchMock)).toHaveLength(1))
    releaseRefresh(jsonResponse(rotatedPair))

    await expect(both).resolves.toEqual([
      { ok: 'http://localhost:8081/api/v1/tasks' },
      { ok: 'http://localhost:8081/api/v1/lists' },
    ])
    expect(refreshCalls(fetchMock)).toHaveLength(1)
  })

  it('se il refresh fallisce chiude la sessione e avvisa', async () => {
    const expired = vi.fn()
    const unsubscribe = onSessionExpired(expired)
    fetchMock
      .mockResolvedValueOnce(jsonResponse({}, 401))
      .mockResolvedValueOnce(jsonResponse({ message: 'Refresh token non valido' }, 401))

    await expect(apiFetch('/tasks')).rejects.toBeInstanceOf(SessionExpiredError)

    expect(readSession()).toBeNull()
    expect(expired).toHaveBeenCalledOnce()
    unsubscribe()
  })

  it('senza sessione un 401 resta un 401, senza tentare refresh', async () => {
    localStorage.clear()
    fetchMock.mockResolvedValue(jsonResponse({ message: 'Non autorizzato' }, 401))

    await expect(apiFetch('/tasks')).rejects.toBeInstanceOf(ApiError)

    expect(refreshCalls(fetchMock)).toHaveLength(0)
  })

  it('sulle rotte di autenticazione non tenta il refresh', async () => {
    fetchMock.mockResolvedValue(jsonResponse({ message: 'Credenziali non valide' }, 401))

    await expect(
      apiFetch('/auth/login', { method: 'POST', body: {}, anonymous: true }),
    ).rejects.toBeInstanceOf(ApiError)

    expect(refreshCalls(fetchMock)).toHaveLength(0)
  })

  it('ripete la richiesta una sola volta: un secondo 401 propaga', async () => {
    fetchMock
      .mockResolvedValueOnce(jsonResponse({}, 401))
      .mockResolvedValueOnce(jsonResponse(rotatedPair))
      .mockResolvedValueOnce(jsonResponse({ message: 'Ancora 401' }, 401))

    await expect(apiFetch('/tasks')).rejects.toBeInstanceOf(ApiError)

    expect(refreshCalls(fetchMock)).toHaveLength(1)
  })

  it('rinnova in anticipo il token quasi scaduto, senza aspettare il 401', async () => {
    writeSession({ ...validSession, expiresAt: Date.now() + 5_000 })
    fetchMock
      .mockResolvedValueOnce(jsonResponse(rotatedPair))
      .mockResolvedValueOnce(jsonResponse({ items: [] }))

    await apiFetch('/tasks')

    expect(refreshCalls(fetchMock)).toHaveLength(1)
    expect(authHeaders(fetchMock)).toEqual([null, 'Bearer nuovo-access'])
  })
})
