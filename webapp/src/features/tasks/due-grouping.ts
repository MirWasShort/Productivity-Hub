import { differenceInCalendarDays } from 'date-fns'
import type { Task } from '@/api/types'

/**
 * Port di `due_grouping.dart`. Funzione pura con il tempo iniettato: è
 * l'unico modo per testare "oggi" senza aspettare domani.
 *
 * I completati collassano sempre in una sezione a parte, qualunque sia la
 * loro scadenza: il raggruppamento per urgenza riguarda ciò che resta da fare.
 */
export const dueGroups = [
  'overdue',
  'today',
  'tomorrow',
  'thisWeek',
  'later',
  'noDate',
  'completed',
] as const

export type DueGroup = (typeof dueGroups)[number]

export const dueGroupLabels: Record<DueGroup, string> = {
  overdue: 'In ritardo',
  today: 'Oggi',
  tomorrow: 'Domani',
  thisWeek: 'Questa settimana',
  later: 'Più avanti',
  noDate: 'Senza scadenza',
  completed: 'Completati',
}

export interface DueSection {
  group: DueGroup
  label: string
  tasks: Task[]
}

/**
 * La regola unica di "in ritardo", condivisa da raggruppamento, evidenziazione
 * nella card e — concettualmente — dalle analytics del backend: scaduto e non
 * completato.
 */
export function isOverdue(task: Task, now: Date): boolean {
  return task.status !== 'DONE' && task.dueDate !== undefined && new Date(task.dueDate) < now
}

function classify(task: Task, now: Date): DueGroup {
  if (task.status === 'DONE') {
    return 'completed'
  }
  if (task.dueDate === undefined) {
    return 'noDate'
  }

  const due = new Date(task.dueDate)
  if (due < now) {
    return 'overdue'
  }

  // Differenza in giorni di *calendario* locale: le 23:00 di oggi e le 01:00
  // di domani distano due ore ma un giorno, ed è il giorno che conta.
  const daysAhead = differenceInCalendarDays(due, now)
  if (daysAhead === 0) {
    return 'today'
  }
  if (daysAhead === 1) {
    return 'tomorrow'
  }
  return daysAhead <= 6 ? 'thisWeek' : 'later'
}

/** Raggruppa in sezioni ordinate per urgenza; le sezioni vuote non compaiono. */
export function groupByDue(tasks: Task[], now: Date): DueSection[] {
  const buckets = new Map<DueGroup, Task[]>()

  for (const task of tasks) {
    const group = classify(task, now)
    const bucket = buckets.get(group)
    if (bucket) {
      bucket.push(task)
    } else {
      buckets.set(group, [task])
    }
  }

  return dueGroups
    .filter((group) => buckets.has(group))
    .map((group) => ({ group, label: dueGroupLabels[group], tasks: buckets.get(group)! }))
}
