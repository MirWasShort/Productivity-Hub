import type { Tag } from '@/api/types'
import { normalizeHex, withAlpha } from '@/lib/theme/list-colors'

/**
 * Pillola del tag nel colore scelto dall'utente: sfondo al 15% e bordo al 50%,
 * come in Flutter. I colori sono dati, non classi, quindi vanno inline.
 */
export function TagPill({ tag }: { tag: Tag }) {
  const color = normalizeHex(tag.color)

  return (
    <span
      className="rounded-sm border px-1.5 py-0.5 text-xs"
      style={{
        color,
        backgroundColor: withAlpha(color, 0.15),
        borderColor: withAlpha(color, 0.5),
      }}
    >
      {tag.name}
    </span>
  )
}
