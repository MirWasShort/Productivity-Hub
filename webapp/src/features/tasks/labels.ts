import type { TaskPriority, TaskStatus } from '@/api/types'

/** Etichette italiane degli enum, condivise da menu, form e dettaglio. */
export const priorityLabels: Record<TaskPriority, string> = {
  LOW: 'Bassa',
  MEDIUM: 'Media',
  HIGH: 'Alta',
}

export const statusLabels: Record<TaskStatus, string> = {
  TODO: 'Da fare',
  IN_PROGRESS: 'In corso',
  DONE: 'Completato',
}
