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

/** Il contrario: chi è già dentro non ha motivo di vedere login o registrazione. */
export function RequireAnonymous({ children }: { children: ReactNode }) {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated)

  if (isAuthenticated) {
    return <Navigate to="/tasks" replace />
  }
  return children
}
