import type { Task } from '@/api/types'

/**
 * Port di `calendar_grouping.dart`.
 *
 * La chiave è il **giorno locale** in formato `YYYY-MM-DD`, non l'istante:
 * un task che scade alle 23:30 UTC può cadere il giorno dopo in Italia, e sul
 * calendario deve comparire dove l'utente se lo aspetta. In JavaScript le date
 * non si possono usare come chiavi di mappa (due `Date` uguali sono oggetti
 * diversi), quindi si passa per la stringa.
 */
export function localDayKey(date: Date): string {
  const year = date.getFullYear()
  const month = `${date.getMonth() + 1}`.padStart(2, '0')
  const day = `${date.getDate()}`.padStart(2, '0')
  return `${year}-${month}-${day}`
}

/** Task raggruppati per giorno locale di scadenza; quelli senza data restano fuori. */
export function groupTasksByDay(tasks: Task[]): Map<string, Task[]> {
  const byDay = new Map<string, Task[]>()

  for (const task of tasks) {
    if (!task.dueDate) {
      // Un task senza scadenza non ha un posto sul calendario.
      continue
    }
    const key = localDayKey(new Date(task.dueDate))
    const bucket = byDay.get(key)
    if (bucket) {
      bucket.push(task)
    } else {
      byDay.set(key, [task])
    }
  }
  return byDay
}

/** I task che scadono nello stesso giorno locale di `day`. */
export function tasksOn(tasks: Task[], day: Date): Task[] {
  const target = localDayKey(day)
  return tasks.filter((task) => task.dueDate && localDayKey(new Date(task.dueDate)) === target)
}
