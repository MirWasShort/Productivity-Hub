import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { addDays, format } from 'date-fns'
import { it as itLocale } from 'date-fns/locale'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { Task } from '@/api/types'
import { visibleDays } from '@/features/calendar/calendar-view'
import { useAuthStore } from '@/lib/auth/auth-store'
import type { Session } from '@/lib/auth/token-storage'
import { useThemeStore } from '@/lib/theme/theme-store'
import { createApiMock, taskListRequests } from '@/test/api-mock'
import { renderApp } from '@/test/render-app'

const session: Session = {
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  expiresAt: Date.now() + 900_000,
  user: { id: 'u1', email: 'mario@example.com', displayName: 'Mario' },
}

function task(id: string, title: string, dueDate?: Date): Task {
  return {
    id,
    title,
    status: 'TODO',
    priority: 'MEDIUM',
    tags: [],
    dueDate: dueDate?.toISOString(),
    createdAt: '2026-07-01T08:00:00Z',
    updatedAt: '2026-07-01T08:00:00Z',
  }
}

function dayLabel(date: Date) {
  return new RegExp(`^${format(date, 'd MMMM yyyy', { locale: itLocale })}`)
}

describe('vista calendario', () => {
  let fetchMock: ReturnType<typeof createApiMock>
  const today = new Date()
  const tomorrow = addDays(today, 1)

  function mockApi(...tasks: Task[]) {
    fetchMock = createApiMock((request) =>
      new URL(request.url).pathname.endsWith('/tasks') && request.method === 'GET'
        ? { body: { items: tasks } }
        : undefined,
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
    mockApi(task('t1', 'Pagare la bolletta', today), task('t2', 'Dentista', tomorrow))
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('mostra i task del giorno selezionato, che all apertura è oggi', async () => {
    renderApp('/calendar')

    expect(await screen.findByRole('link', { name: 'Pagare la bolletta' })).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: 'Dentista' })).not.toBeInTheDocument()
  })

  it('scegliendo un altro giorno cambia la lista sotto', async () => {
    renderApp('/calendar')
    await screen.findByRole('link', { name: 'Pagare la bolletta' })

    await userEvent.click(screen.getByRole('button', { name: dayLabel(tomorrow) }))

    expect(await screen.findByRole('link', { name: 'Dentista' })).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: 'Pagare la bolletta' })).not.toBeInTheDocument()
  })

  it('i giorni con task si distinguono nell etichetta accessibile', async () => {
    renderApp('/calendar')

    const dayWithTask = await screen.findByRole('button', { name: dayLabel(today) })
    expect(dayWithTask).toHaveAccessibleName(/1 task/)
  })

  it('un giorno senza task lo dice, invece di restare vuoto', async () => {
    mockApi()
    renderApp('/calendar')

    expect(await screen.findByText('Niente in programma')).toBeInTheDocument()
  })

  it('il calendario ignora i filtri della lista: chiede tutti i task', async () => {
    renderApp('/calendar')

    // Non la prima chiamata in assoluto: la barra laterale chiede le liste.
    await waitFor(() => expect(taskListRequests(fetchMock)).not.toHaveLength(0))
    const params = new URL(taskListRequests(fetchMock)[0]!.url).searchParams
    expect(params.has('status')).toBe(false)
    expect(params.get('sortBy')).toBe('DUE_DATE')
  })

  it('il pulsante aggiungi porta all editor con la data già scelta', async () => {
    renderApp('/calendar')
    await screen.findByRole('link', { name: 'Pagare la bolletta' })

    await userEvent.click(screen.getByRole('button', { name: /Aggiungi/ }))

    expect(await screen.findByRole('heading', { name: 'Nuovo task' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: dayLabel(today) })).toBeInTheDocument()
  })

  it('si può passare a due settimane e a una settimana', async () => {
    renderApp('/calendar')
    await screen.findByRole('link', { name: 'Pagare la bolletta' })

    await userEvent.click(screen.getByRole('radio', { name: 'Settimana' }))

    // Sette celle: una settimana esatta, lunedì-domenica.
    expect(screen.getAllByRole('button', { name: /^\d+ \w+ \d{4}/ })).toHaveLength(7)
  })
})

describe('giorni visibili', () => {
  const anchor = new Date(2026, 6, 15) // mercoledì 15 luglio 2026

  it('la vista mensile copre settimane intere, lunedì-domenica', () => {
    const days = visibleDays(anchor, 'month')

    expect(days.length % 7).toBe(0)
    expect(days[0]!.getDay()).toBe(1)
    expect(days.at(-1)!.getDay()).toBe(0)
    // Include i giorni di riempimento del mese precedente e successivo.
    expect(days[0]!.getMonth()).toBe(5)
  })

  it('due settimane sono 14 giorni, una settimana 7', () => {
    expect(visibleDays(anchor, 'twoWeeks')).toHaveLength(14)
    expect(visibleDays(anchor, 'week')).toHaveLength(7)
  })
})
