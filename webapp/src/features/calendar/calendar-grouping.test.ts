import { describe, expect, it } from 'vitest'
import type { Task } from '@/api/types'
import { groupTasksByDay, localDayKey, tasksOn } from '@/features/calendar/calendar-grouping'

function task(id: string, dueDate?: Date): Task {
  return {
    id,
    title: `Task ${id}`,
    status: 'TODO',
    priority: 'MEDIUM',
    tags: [],
    dueDate: dueDate?.toISOString(),
    createdAt: '2026-07-01T08:00:00Z',
    updatedAt: '2026-07-01T08:00:00Z',
  }
}

/** Data locale: è così che la vede l'utente, ed è ciò che conta sul calendario. */
function localDate(year: number, month: number, day: number, hour = 12) {
  return new Date(year, month - 1, day, hour)
}

describe('raggruppamento del calendario', () => {
  it('usa il giorno locale come chiave, non l istante', () => {
    expect(localDayKey(localDate(2026, 7, 5, 23))).toBe('2026-07-05')
    expect(localDayKey(localDate(2026, 12, 31, 0))).toBe('2026-12-31')
  })

  it('mette insieme i task dello stesso giorno, a qualunque ora', () => {
    const byDay = groupTasksByDay([
      task('a', localDate(2026, 7, 5, 8)),
      task('b', localDate(2026, 7, 5, 22)),
      task('c', localDate(2026, 7, 6, 9)),
    ])

    expect(byDay.get('2026-07-05')?.map((t) => t.id)).toEqual(['a', 'b'])
    expect(byDay.get('2026-07-06')?.map((t) => t.id)).toEqual(['c'])
  })

  it('tiene fuori i task senza scadenza: non hanno un posto sul calendario', () => {
    const byDay = groupTasksByDay([task('a'), task('b', localDate(2026, 7, 5))])

    expect([...byDay.values()].flat().map((t) => t.id)).toEqual(['b'])
  })

  it('funziona a cavallo di mese e di anno', () => {
    const byDay = groupTasksByDay([
      task('fine-mese', localDate(2026, 7, 31, 23)),
      task('inizio-mese', localDate(2026, 8, 1, 0)),
      task('capodanno', localDate(2027, 1, 1, 0)),
    ])

    expect(byDay.get('2026-07-31')?.map((t) => t.id)).toEqual(['fine-mese'])
    expect(byDay.get('2026-08-01')?.map((t) => t.id)).toEqual(['inizio-mese'])
    expect(byDay.get('2027-01-01')?.map((t) => t.id)).toEqual(['capodanno'])
  })

  it('tasksOn seleziona il giorno indicato, ignorando l ora', () => {
    const tasks = [
      task('a', localDate(2026, 7, 5, 8)),
      task('b', localDate(2026, 7, 5, 20)),
      task('c', localDate(2026, 7, 6)),
      task('senza-data'),
    ]

    expect(tasksOn(tasks, localDate(2026, 7, 5, 3)).map((t) => t.id)).toEqual(['a', 'b'])
    expect(tasksOn(tasks, localDate(2026, 7, 7)).map((t) => t.id)).toEqual([])
  })
})
