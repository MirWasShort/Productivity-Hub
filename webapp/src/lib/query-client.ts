import { QueryClient } from '@tanstack/react-query'
import { ApiError } from '@/lib/api/errors'

/**
 * Cache condivisa da tutta l'app. Vive in un modulo, non in un componente,
 * perché anche lo store di autenticazione deve poterla svuotare al logout.
 */
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // I dati restano "freschi" mezzo minuto: evita di rifetchare a ogni
      // cambio di pagina, senza far invecchiare troppo le liste.
      staleTime: 30_000,
      retry: (failureCount, error) => {
        // Un 4xx non migliora riprovando: manca il permesso, o la risorsa.
        if (error instanceof ApiError && error.status < 500) {
          return false
        }
        return failureCount < 2
      },
    },
    mutations: { retry: false },
  },
})
