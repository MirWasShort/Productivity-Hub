import { describe, expect, it } from 'vitest'
import type { Task, TaskStatus } from '@/api/types'
import { dueGroupLabels, groupByDue, isOverdue, type DueGroup } from '@/features/tasks/due-grouping'

/** Mercoledì 15 luglio 2026, ore 12:00 locali. */
const now = new Date(2026, 6, 15, 12, 0, 0)

function task(overrides: Partial<Task> & { id: string }): Task {
  return {
    title: 'Un task',
    status: 'TODO',
    priority: 'MEDIUM',
    tags: [],
    createdAt: '2026-07-01T08:00:00Z',
    updatedAt: '2026-07-01T08:00:00Z',
    ...overrides,
  }
}

/** Data locale con offset in giorni e ora scelta, serializzata come manda il backend. */
function dueIn(days: number, hour = 12): string {
  const date = new Date(2026, 6, 15 + days, hour, 0, 0)
  return date.toISOString()
}

function groupOf(overrides: Partial<Task>): DueGroup | undefined {
  const sections = groupByDue([task({ id: 't1', ...overrides })], now)
  return sections[0]?.group
}

describe('groupByDue', () => {
  it('mette in "In ritardo" ciò che è scaduto e non è fatto', () => {
    expect(groupOf({ dueDate: dueIn(-1) })).toBe('overdue')
    // Stessa giornata di oggi, ma un'ora già passata: è comunque in ritardo.
    expect(groupOf({ dueDate: dueIn(0, 9) })).toBe('overdue')
  })

  it('distingue oggi, domani e questa settimana', () => {
    expect(groupOf({ dueDate: dueIn(0, 18) })).toBe('today')
    expect(groupOf({ dueDate: dueIn(1) })).toBe('tomorrow')
    expect(groupOf({ dueDate: dueIn(2) })).toBe('thisWeek')
    expect(groupOf({ dueDate: dueIn(6) })).toBe('thisWeek')
  })

  it('oltre i sei giorni è "Più avanti"', () => {
    expect(groupOf({ dueDate: dueIn(7) })).toBe('later')
    expect(groupOf({ dueDate: dueIn(365) })).toBe('later')
  })

  it('senza scadenza finisce in "Senza scadenza"', () => {
    expect(groupOf({})).toBe('noDate')
  })

  it('i completati collassano tutti insieme, qualunque sia la scadenza', () => {
    const statuses: TaskStatus[] = ['DONE']
    for (const status of statuses) {
      expect(groupOf({ status, dueDate: dueIn(-10) })).toBe('completed')
      expect(groupOf({ status, dueDate: dueIn(0) })).toBe('completed')
      expect(groupOf({ status })).toBe('completed')
    }
  })

  it('un task in corso e scaduto resta in ritardo', () => {
    expect(groupOf({ status: 'IN_PROGRESS', dueDate: dueIn(-2) })).toBe('overdue')
  })

  it('restituisce le sezioni nell ordine di urgenza, saltando quelle vuote', () => {
    const sections = groupByDue(
      [
        task({ id: 'senza-data' }),
        task({ id: 'fatto', status: 'DONE' }),
        task({ id: 'domani', dueDate: dueIn(1) }),
        task({ id: 'ritardo', dueDate: dueIn(-3) }),
        task({ id: 'oggi', dueDate: dueIn(0, 20) }),
      ],
      now,
    )

    expect(sections.map((section) => section.group)).toEqual([
      'overdue',
      'today',
      'tomorrow',
      'noDate',
      'completed',
    ])
    expect(sections.map((section) => section.label)).toEqual([
      'In ritardo',
      'Oggi',
      'Domani',
      'Senza scadenza',
      'Completati',
    ])
  })

  it('conserva l ordine dei task dentro ogni sezione', () => {
    const sections = groupByDue(
      [
        task({ id: 'primo', dueDate: dueIn(3) }),
        task({ id: 'secondo', dueDate: dueIn(4) }),
        task({ id: 'terzo', dueDate: dueIn(2) }),
      ],
      now,
    )

    expect(sections[0]?.tasks.map((t) => t.id)).toEqual(['primo', 'secondo', 'terzo'])
  })

  it('senza task non produce sezioni', () => {
    expect(groupByDue([], now)).toEqual([])
  })

  it('ha un etichetta per ogni gruppo', () => {
    expect(Object.values(dueGroupLabels)).toHaveLength(7)
  })
})

describe('isOverdue', () => {
  it('è in ritardo solo ciò che ha una scadenza passata e non è completato', () => {
    expect(isOverdue(task({ id: 't', dueDate: dueIn(-1) }), now)).toBe(true)
    expect(isOverdue(task({ id: 't', dueDate: dueIn(1) }), now)).toBe(false)
    expect(isOverdue(task({ id: 't' }), now)).toBe(false)
    expect(isOverdue(task({ id: 't', status: 'DONE', dueDate: dueIn(-1) }), now)).toBe(false)
  })
})
