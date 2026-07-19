import { describe, expect, it } from 'vitest'
import type { DayCount } from '@/api/types'
import { weeklyBuckets } from '@/features/dashboard/weekly-completions'

/** Mercoledì 15 luglio 2026: la settimana corrente apre lunedì 13. */
const now = new Date(2026, 6, 15, 12)

function day(date: string, count: number): DayCount {
  return { date, count }
}

describe('weeklyBuckets', () => {
  it('produce sempre sei settimane, dalla più vecchia alla più recente', () => {
    const buckets = weeklyBuckets([], now)

    expect(buckets).toHaveLength(6)
    expect(buckets.map((bucket) => bucket.label)).toEqual([
      '8/6',
      '15/6',
      '22/6',
      '29/6',
      '6/7',
      '13/7',
    ])
  })

  it('riempie di zeri le settimane senza completamenti', () => {
    const buckets = weeklyBuckets([day('2026-07-14', 3)], now)

    expect(buckets.map((bucket) => bucket.count)).toEqual([0, 0, 0, 0, 0, 3])
  })

  it('somma i giorni che cadono nella stessa settimana', () => {
    const buckets = weeklyBuckets(
      [day('2026-07-13', 2), day('2026-07-15', 1), day('2026-07-19', 4)],
      now,
    )

    expect(buckets.at(-1)?.count).toBe(7)
  })

  it('assegna i giorni al bucket giusto anche ai confini', () => {
    // Domenica 12 luglio chiude la settimana precedente; lunedì 13 apre quella corrente.
    const buckets = weeklyBuckets([day('2026-07-12', 5), day('2026-07-13', 1)], now)

    expect(buckets[4]?.count).toBe(5)
    expect(buckets[5]?.count).toBe(1)
  })

  it('scarta i giorni fuori dalla finestra delle sei settimane', () => {
    const buckets = weeklyBuckets([day('2026-05-01', 99), day('2026-06-07', 42)], now)

    expect(buckets.reduce((total, bucket) => total + bucket.count, 0)).toBe(0)
  })

  it('accetta un numero di settimane diverso', () => {
    const buckets = weeklyBuckets([], now, 3)

    expect(buckets.map((bucket) => bucket.label)).toEqual(['29/6', '6/7', '13/7'])
  })
})
