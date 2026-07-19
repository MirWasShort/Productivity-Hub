import type { ReactNode } from 'react'
import { Navigate, useLocation } from 'react-router'
import { useAuthStore } from '@/lib/auth/auth-store'

/**
 * Protegge tutto ciò che sta dentro la shell. Chi non è autenticato finisce
 * al login, con l'indirizzo richiesto conservato in `state.from` per poterlo
 * riaprire subito dopo l'accesso.
 */
export function RequireAuth({ children }: { children: ReactNode }) {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated)
  const location = useLocation()

  if (!isAuthenticated) {
    return <Navigate to="/login" replace state={{ from: location.pathname + location.search }} />
  }
  return children
}

/**
 * Il contrario: chi è già dentro non ha motivo di vedere login o
 * registrazione. È anche il punto in cui si atterra dopo un accesso riuscito —
 * appena la sessione esiste, questo redirect scatta e riporta l'utente dove
 * voleva andare. Per questo è qui, e non nel form, che si legge `state.from`:
 * altrimenti i due si contenderebbero la navigazione e vincerebbe il guard.
 */
export function RequireAnonymous({ children }: { children: ReactNode }) {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated)
  const location = useLocation()

  if (isAuthenticated) {
    const from = (location.state as { from?: string } | null)?.from
    return <Navigate to={from ?? '/tasks'} replace />
  }
  return children
}
