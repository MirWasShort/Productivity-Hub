import tokens from '../../../../tokens/tokens.json'

/**
 * Gli otto colori preimpostati per liste e tag — nessun color picker libero.
 * Vengono da `tokens/tokens.json`, lo stesso file da cui il client Flutter
 * genera i suoi: la palette è una sola per entrambe le app.
 */
export const listColorSwatches: readonly string[] = tokens.listSwatches

/** Colore di ripiego quando il backend manda null o un formato inatteso. */
export const FALLBACK_COLOR: string = tokens.fallbackColor

const HEX_PATTERN = /^#[0-9A-Fa-f]{6}$/

/** Restituisce l'hex se è un `#RRGGBB` valido, altrimenti lo slate di ripiego. */
export function normalizeHex(hex: string | null | undefined): string {
  return hex && HEX_PATTERN.test(hex) ? hex : FALLBACK_COLOR
}

/**
 * Aggiunge il canale alfa in notazione `#RRGGBBAA`, come fa Flutter con
 * `withValues(alpha:)`. Usato per gli sfondi tenui delle pillole tag.
 */
export function withAlpha(hex: string | null | undefined, alpha: number): string {
  const channel = Math.round(Math.min(Math.max(alpha, 0), 1) * 255)
  return `${normalizeHex(hex)}${channel.toString(16).padStart(2, '0').toUpperCase()}`
}
