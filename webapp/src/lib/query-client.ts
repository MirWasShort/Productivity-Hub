import { MutationCache, QueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { errorMessage } from '@/lib/api/error-message'
import { ApiError, SessionExpiredError } from '@/lib/api/errors'

/**
 * Costruisce una cache configurata come quella dell'app. È una factory perché
 * i test ne vogliono una pulita per ogni caso, ma con **le stesse regole**:
 * una configurazione che vive solo in produzione non sarebbe testata.
 */
export function createQueryClient() {
  return new QueryClient({
    /*
     * Una mutazione fallita annulla l'aggiornamento ottimistico: senza avviso,
     * l'utente vedrebbe la spunta tornare indietro da sola senza sapere perché.
     * La sessione scaduta è l'unica eccezione: manda già al login, e un avviso
     * in più sarebbe rumore.
     */
    mutationCache: new MutationCache({
      onError: (error) => {
        if (!(error instanceof SessionExpiredError)) {
          toast.error(errorMessage(error))
        }
      },
    }),
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
}

/**
 * La cache dell'app. Vive in un modulo, non in un componente, perché anche lo
 * store di autenticazione deve poterla svuotare al logout.
 */
export const queryClient = createQueryClient()
