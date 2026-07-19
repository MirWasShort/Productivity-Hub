import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import App from '@/App'
import { useThemeStore } from '@/lib/theme/theme-store'

describe('App', () => {
  beforeEach(() => {
    localStorage.clear()
    document.documentElement.classList.remove('dark')
    vi.stubGlobal(
      'matchMedia',
      vi.fn(() => ({ matches: false, addEventListener: vi.fn(), removeEventListener: vi.fn() })),
    )
    useThemeStore.setState({ mode: 'system' })
  })

  it('monta e mostra il nome dell app', () => {
    render(<App />)

    expect(screen.getByRole('heading', { name: 'Smart TODO' })).toBeInTheDocument()
  })

  it('il toggle passa al tema scuro', async () => {
    render(<App />)

    await userEvent.click(screen.getByRole('button', { name: 'Passa al tema scuro' }))

    expect(document.documentElement.classList.contains('dark')).toBe(true)
    expect(screen.getByRole('button', { name: 'Passa al tema chiaro' })).toBeInTheDocument()
  })
})
