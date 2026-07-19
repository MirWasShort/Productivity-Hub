import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { createMemoryRouter, RouterProvider } from 'react-router'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { routes } from '@/lib/router'
import { useThemeStore } from '@/lib/theme/theme-store'

function renderAt(path: string) {
  const router = createMemoryRouter(routes, { initialEntries: [path] })
  return render(<RouterProvider router={router} />)
}

describe('router', () => {
  beforeEach(() => {
    localStorage.clear()
    vi.stubGlobal(
      'matchMedia',
      vi.fn(() => ({ matches: false, addEventListener: vi.fn(), removeEventListener: vi.fn() })),
    )
    useThemeStore.setState({ mode: 'light' })
  })

  it('la radice porta ai task', async () => {
    renderAt('/')

    expect(await screen.findByRole('heading', { name: 'I miei task' })).toBeInTheDocument()
  })

  it('mostra le tre destinazioni principali nella navigazione', async () => {
    renderAt('/tasks')

    const nav = await screen.findByRole('navigation')
    expect(nav).toHaveTextContent('Task')
    expect(nav).toHaveTextContent('Calendario')
    expect(nav).toHaveTextContent('Dashboard')
  })

  it('naviga tra le sezioni senza ricaricare la shell', async () => {
    renderAt('/tasks')

    await userEvent.click(await screen.findByRole('link', { name: 'Calendario' }))

    expect(await screen.findByRole('heading', { name: 'Calendario' })).toBeInTheDocument()
    expect(screen.getByRole('navigation')).toBeInTheDocument()
  })

  it('login e registrazione stanno fuori dalla shell', async () => {
    renderAt('/login')

    expect(await screen.findByRole('heading', { name: 'Accedi' })).toBeInTheDocument()
    expect(screen.queryByRole('navigation')).not.toBeInTheDocument()
  })

  it('una rotta sconosciuta mostra la pagina non trovata', async () => {
    renderAt('/inesistente')

    expect(await screen.findByText(/pagina non trovata/i)).toBeInTheDocument()
  })
})
