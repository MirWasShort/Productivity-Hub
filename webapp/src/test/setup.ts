import '@testing-library/jest-dom/vitest'
import { cleanup } from '@testing-library/react'
import { afterEach } from 'vitest'

// RTL non smonta da sola tra un test e l'altro con `globals: true`.
afterEach(() => {
  cleanup()
})
