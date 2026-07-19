import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import App from '@/App'

describe('App', () => {
  it('monta e mostra il nome dell app', () => {
    render(<App />)

    expect(screen.getByRole('heading', { name: 'Smart TODO' })).toBeInTheDocument()
  })
})
