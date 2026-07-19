import { QueryClientProvider } from '@tanstack/react-query'
import { render } from '@testing-library/react'
import { createMemoryRouter, RouterProvider } from 'react-router'
import { Toaster } from '@/components/ui/sonner'
import { createQueryClient } from '@/lib/query-client'
import { routes } from '@/lib/router'

/**
 * Monta l'app vera (rotte, guard, provider, notifiche) a un indirizzo scelto.
 * I test di flusso usano questo invece dei singoli componenti: è l'unico modo
 * per vedere le interazioni fra form, store, guard e navigazione.
 */
export function renderApp(path: string) {
  // Cache nuova per ogni test, ma con la configurazione dell'app: `retry`
  // spento è l'unica differenza, o ogni errore atteso costerebbe tre tentativi.
  const queryClient = createQueryClient()
  queryClient.setDefaultOptions({ queries: { retry: false }, mutations: { retry: false } })
  const router = createMemoryRouter(routes, { initialEntries: [path] })

  return {
    queryClient,
    ...render(
      <QueryClientProvider client={queryClient}>
        <RouterProvider router={router} />
        <Toaster />
      </QueryClientProvider>,
    ),
  }
}
