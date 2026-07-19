import { useEffect } from 'react'

const SUFFIX = 'Smart TODO'

/**
 * Titolo della scheda. Sul web è parte della navigazione: distingue le schede
 * aperte, finisce nella cronologia e nei preferiti. Un'app che lascia lo stesso
 * titolo ovunque rende inutilizzabili tutte e tre le cose.
 */
export function useDocumentTitle(title?: string) {
  useEffect(() => {
    document.title = title ? `${title} · ${SUFFIX}` : SUFFIX
  }, [title])
}
