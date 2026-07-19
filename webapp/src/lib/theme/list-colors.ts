/**
 * Gli otto colori preimpostati per liste e tag — nessun color picker libero.
 * Stessa palette del client Flutter (`core/theme/list_colors.dart`).
 */
export const listColorSwatches = [
  '#4F46E5', // indigo
  '#0EA5E9', // sky
  '#10B981', // emerald
  '#F59E0B', // amber
  '#EF4444', // red
  '#EC4899', // pink
  '#8B5CF6', // violet
  '#64748B', // slate
] as const

/** Colore di ripiego quando il backend manda null o un formato inatteso. */
export const FALLBACK_COLOR = '#64748B'

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
