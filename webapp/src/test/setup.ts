import '@testing-library/jest-dom/vitest'
import { cleanup } from '@testing-library/react'
import { afterEach } from 'vitest'

/*
 * Node 26 espone un `localStorage` sperimentale (disattivato senza
 * --localstorage-file) che oscura quello di jsdom: nei test il global resta
 * undefined. Lo rimpiazziamo con una Storage in memoria, che è anche più
 * comoda da azzerare tra un test e l'altro.
 */
if (typeof globalThis.localStorage === 'undefined') {
  const entries = new Map<string, string>()
  const memoryStorage: Storage = {
    get length() {
      return entries.size
    },
    key: (index) => [...entries.keys()][index] ?? null,
    getItem: (key) => entries.get(key) ?? null,
    setItem: (key, value) => void entries.set(key, String(value)),
    removeItem: (key) => void entries.delete(key),
    clear: () => entries.clear(),
  }
  Object.defineProperty(globalThis, 'localStorage', { value: memoryStorage, writable: true })
  Object.defineProperty(window, 'localStorage', { value: memoryStorage, writable: true })
}

// RTL non smonta da sola tra un test e l'altro con `globals: true`.
afterEach(() => {
  cleanup()
})
