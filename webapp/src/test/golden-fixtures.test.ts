import { describe, expect, it } from 'vitest'
import type { DayCount, Task, TaskStatus } from '@/api/types'
import { groupTasksByDay, localDayKey } from '@/features/calendar/calendar-grouping'
import { weeklyBuckets } from '@/features/dashboard/weekly-completions'
import { groupByDue } from '@/features/tasks/due-grouping'
import calendarFixture from '../../../fixtures/calendar-grouping.json'
import dueFixture from '../../../fixtures/due-grouping.json'
import weeklyFixture from '../../../fixtures/weekly-completions.json'

/*
 * Gli stessi casi verificati dalla suite Dart
 * (`frontend/test/domain/golden_fixtures_test.dart`). Sono la prova che le due
 * implementazioni del dominio coincidono davvero, invece di somigliarsi.
 * Le date nelle fixture sono senza fuso: entrambi i linguaggi le leggono come
 * ora locale, quindi l'esito non dipende dal fuso di chi esegue i test.
 */

function taskFrom(raw: { id: string; status?: string | null; dueDate?: string | null }): Task {
  return {
    id: raw.id,
    title: raw.id,
    status: ((raw.status as TaskStatus | undefined) ?? 'TODO') as TaskStatus,
    priority: 'MEDIUM',
    tags: [],
    dueDate: raw.dueDate ?? undefined,
    createdAt: '2026-01-01T00:00:00',
    updatedAt: '2026-01-01T00:00:00',
  }
}

describe('golden fixture: due grouping', () => {
  for (const testCase of dueFixture.cases) {
    it(testCase.name, () => {
      const sections = groupByDue(testCase.tasks.map(taskFrom), new Date(testCase.now))

      expect(
        sections.map((section) => ({
          group: section.group,
          taskIds: section.tasks.map((task) => task.id),
        })),
      ).toEqual(testCase.expected)
    })
  }
})

describe('golden fixture: weekly completions', () => {
  for (const testCase of weeklyFixture.cases) {
    it(testCase.name, () => {
      const buckets = weeklyBuckets(
        testCase.days as DayCount[],
        new Date(testCase.now),
        testCase.weeks,
      )

      expect(buckets).toEqual(testCase.expected)
    })
  }
})

describe('golden fixture: calendar grouping', () => {
  for (const testCase of calendarFixture.cases) {
    it(testCase.name, () => {
      const byDay = groupTasksByDay(testCase.tasks.map(taskFrom))

      const actual = Object.fromEntries(
        [...byDay.entries()].map(([day, tasks]) => [day, tasks.map((task) => task.id)]),
      )
      expect(actual).toEqual(testCase.expectedByDay)
      // La chiave prodotta dal port deve essere il giorno locale, come in Dart.
      for (const key of Object.keys(actual)) {
        expect(localDayKey(new Date(`${key}T12:00:00`))).toBe(key)
      }
    })
  }
})
