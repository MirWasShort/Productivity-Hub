import type { QueryParams } from '@/lib/api/client'
import type { SortDirection, TaskPriority, TaskSortField, TaskStatus } from '@/api/types'

/**
 * Criteri attivi nella lista dei task. `null` significa "questa dimensione non
 * è filtrata" — stessa convenzione di `TaskFilter` in Flutter, ed è anche ciò
 * che il client HTTP interpreta come "parametro da non mandare".
 *
 * Una pagina sola da 50 elementi, come nel client Flutter: la paginazione vera
 * è una funzionalità a sé, non un dettaglio da introdurre di straforo.
 */
export interface TaskFilter {
  status: TaskStatus | null
  priority: TaskPriority | null
  search: string | null
  listId: string | null
  tagId: string | null
  sortBy: TaskSortField
  direction: SortDirection
}

export const PAGE_SIZE = 50

export const defaultTaskFilter: TaskFilter = {
  status: null,
  priority: null,
  search: null,
  listId: null,
  tagId: null,
  sortBy: 'CREATED_AT',
  direction: 'DESC',
}

/** Le dimensioni a selezione singola: cliccare quella attiva la spegne. */
type ToggleableField = 'status' | 'priority' | 'tagId' | 'listId'

export function isDefaultFilter(filter: TaskFilter): boolean {
  return (
    filter.status === null &&
    filter.priority === null &&
    filter.search === null &&
    filter.listId === null &&
    filter.tagId === null &&
    filter.sortBy === 'CREATED_AT' &&
    filter.direction === 'DESC'
  )
}

export function toggleFilterValue<F extends ToggleableField>(
  filter: TaskFilter,
  field: F,
  value: NonNullable<TaskFilter[F]>,
): TaskFilter {
  return { ...filter, [field]: filter[field] === value ? null : value }
}

export function clearFilterField(filter: TaskFilter, field: keyof TaskFilter): TaskFilter {
  return { ...filter, [field]: null }
}

/** Una ricerca vuota o di soli spazi equivale a nessuna ricerca. */
export function withSearch(filter: TaskFilter, term: string): TaskFilter {
  const trimmed = term.trim()
  return { ...filter, search: trimmed === '' ? null : trimmed }
}

export function withSort(
  filter: TaskFilter,
  sortBy: TaskSortField,
  direction: SortDirection,
): TaskFilter {
  return { ...filter, sortBy, direction }
}

export function toQueryParams(filter: TaskFilter): QueryParams {
  return {
    page: 0,
    size: PAGE_SIZE,
    status: filter.status,
    priority: filter.priority,
    search: filter.search,
    listId: filter.listId,
    tagId: filter.tagId,
    sortBy: filter.sortBy,
    direction: filter.direction,
  }
}
