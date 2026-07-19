import { addDays, format, parseISO, startOfWeek } from 'date-fns'
import type { DayCount } from '@/api/types'

export interface WeekBucket {
  /** Etichetta del lunedì di apertura, es. `15/6`. */
  label: string
  count: number
}

/**
 * Port di `weekly_completions.dart`. Aggrega i conteggi giornalieri nelle
 * ultime `weeks` settimane (dalla più vecchia alla più recente), riempiendo di
 * zeri quelle senza completamenti.
 *
 * Il backend manda 42 giorni: 42 barre sono illeggibili, sei raccontano la
 * storia. L'aggregazione è qui e non nel backend perché il taglio delle
 * settimane dipende dal fuso di chi guarda.
 */
export function weeklyBuckets(completions: DayCount[], now: Date, weeks = 6): WeekBucket[] {
  // Lunedì della settimana corrente: è l'ancora da cui si torna indietro.
  const thisWeekStart = startOfWeek(now, { weekStartsOn: 1 })
  const starts = Array.from({ length: weeks }, (_, index) =>
    addDays(thisWeekStart, -7 * (weeks - 1 - index)),
  )
  const counts = new Array<number>(weeks).fill(0)

  for (const day of completions) {
    // `parseISO` su `YYYY-MM-DD` dà la mezzanotte *locale*: è il giorno come
    // lo intende chi guarda, coerente con il taglio delle settimane.
    const date = parseISO(day.date)
    const index = starts.findIndex(
      (start, position) =>
        date >= start && (position === weeks - 1 || date < starts[position + 1]!),
    )
    if (index !== -1) {
      counts[index] = (counts[index] ?? 0) + day.count
    }
  }

  return starts.map((start, index) => ({
    label: format(start, 'd/M'),
    count: counts[index]!,
  }))
}
