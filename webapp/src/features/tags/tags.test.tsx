import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { Tag } from '@/api/types'
import { useAuthStore } from '@/lib/auth/auth-store'
import type { Session } from '@/lib/auth/token-storage'
import { useThemeStore } from '@/lib/theme/theme-store'
import { createApiMock, requestsWithMethod, taskListRequests } from '@/test/api-mock'
import { renderApp } from '@/test/render-app'

const session: Session = {
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  expiresAt: Date.now() + 900_000,
  user: { id: 'u1', email: 'mario@example.com', displayName: 'Mario' },
}

const tags: Tag[] = [
  { id: 'tag-1', name: 'casa', color: '#10B981' },
  { id: 'tag-2', name: 'urgente', color: '#EF4444' },
]

describe('tag', () => {
  let fetchMock: ReturnType<typeof createApiMock>

  function mockApi(handler?: Parameters<typeof createApiMock>[0]) {
    fetchMock = createApiMock(
      (request) =>
        handler?.(request) ??
        (request.method === 'GET' && new URL(request.url).pathname.endsWith('/tags')
          ? { body: tags }
          : undefined),
    )
    vi.stubGlobal('fetch', fetchMock)
  }

  beforeEach(() => {
    localStorage.clear()
    useThemeStore.setState({ mode: 'light' })
    vi.stubGlobal(
      'matchMedia',
      vi.fn(() => ({ matches: false, addEventListener: vi.fn(), removeEventListener: vi.fn() })),
    )
    useAuthStore.getState().signIn(session)
    mockApi()
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('elenca i tag esistenti nella pagina di gestione', async () => {
    renderApp('/tags')

    expect(await screen.findByText('casa')).toBeInTheDocument()
    expect(screen.getByText('urgente')).toBeInTheDocument()
  })

  it('crea un tag con nome e colore', async () => {
    renderApp('/tags')

    await userEvent.click(await screen.findByRole('button', { name: /Nuovo tag/ }))
    await userEvent.type(screen.getByLabelText('Nome del tag'), 'spesa')
    await userEvent.click(screen.getByRole('button', { name: 'Colore #0EA5E9' }))
    await userEvent.click(screen.getByRole('button', { name: 'Crea' }))

    await waitFor(() => expect(requestsWithMethod(fetchMock, 'POST')).toHaveLength(1))
    await expect(requestsWithMethod(fetchMock, 'POST')[0]!.json()).resolves.toEqual({
      name: 'spesa',
      color: '#0EA5E9',
    })
  })

  it('un nome già usato viene segnalato nel dialogo, non altrove', async () => {
    mockApi((request) =>
      request.method === 'POST'
        ? { body: { message: 'Tag già esistente' }, status: 409 }
        : undefined,
    )
    renderApp('/tags')

    await userEvent.click(await screen.findByRole('button', { name: /Nuovo tag/ }))
    await userEvent.type(screen.getByLabelText('Nome del tag'), 'casa')
    await userEvent.click(screen.getByRole('button', { name: 'Crea' }))

    expect(await screen.findByRole('alert')).toHaveTextContent(/esiste già un tag/i)
  })

  it('rinominare un tag manda nome e colore aggiornati', async () => {
    renderApp('/tags')

    await userEvent.click(await screen.findByRole('button', { name: 'Rinomina "casa"' }))
    const input = screen.getByLabelText('Nome del tag')
    await userEvent.clear(input)
    await userEvent.type(input, 'domestico')
    await userEvent.click(screen.getByRole('button', { name: 'Salva' }))

    await waitFor(() => expect(requestsWithMethod(fetchMock, 'PUT')).toHaveLength(1))
    const request = requestsWithMethod(fetchMock, 'PUT')[0]!
    expect(request.url).toMatch(/\/tags\/tag-1$/)
    await expect(request.json()).resolves.toMatchObject({ name: 'domestico' })
  })

  it('eliminare un tag avvisa che sparirà dai task che lo usano', async () => {
    renderApp('/tags')

    await userEvent.click(await screen.findByRole('button', { name: 'Elimina "urgente"' }))
    expect(await screen.findByText('Eliminare il tag?')).toBeInTheDocument()
    expect(screen.getByText(/verrà rimosso da tutti i task/i)).toBeInTheDocument()
    await userEvent.click(screen.getByRole('button', { name: 'Elimina' }))

    await waitFor(() => expect(requestsWithMethod(fetchMock, 'DELETE')).toHaveLength(1))
    expect(requestsWithMethod(fetchMock, 'DELETE')[0]!.url).toMatch(/\/tags\/tag-2$/)
  })

  it('ogni tag diventa un chip che filtra la lista', async () => {
    renderApp('/tasks')

    await userEvent.click(await screen.findByRole('button', { name: 'urgente' }))

    await waitFor(() =>
      expect(new URL(taskListRequests(fetchMock).at(-1)!.url).searchParams.get('tagId')).toBe(
        'tag-2',
      ),
    )
  })

  it('nell editor i tag si scelgono a più a più', async () => {
    renderApp('/tasks/new')

    await userEvent.click(await screen.findByRole('button', { name: 'casa' }))
    await userEvent.click(screen.getByRole('button', { name: 'urgente' }))
    await userEvent.type(screen.getByLabelText('Titolo'), 'Portare fuori il cane')
    await userEvent.click(screen.getByRole('button', { name: 'Crea' }))

    await waitFor(() => expect(requestsWithMethod(fetchMock, 'POST')).toHaveLength(1))
    await expect(requestsWithMethod(fetchMock, 'POST')[0]!.json()).resolves.toMatchObject({
      tagIds: ['tag-1', 'tag-2'],
    })
  })
})
