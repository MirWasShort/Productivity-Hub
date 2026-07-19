import { describe, expect, it } from 'vitest'
import {
  clearFilterField,
  defaultTaskFilter,
  isDefaultFilter,
  toQueryParams,
  toggleFilterValue,
  type TaskFilter,
} from '@/features/tasks/filters'

describe('filtro dei task', () => {
  it('il filtro di partenza è "tutto, dal più recente"', () => {
    expect(defaultTaskFilter).toEqual({
      status: null,
      priority: null,
      search: null,
      listId: null,
      tagId: null,
      sortBy: 'CREATED_AT',
      direction: 'DESC',
    })
    expect(isDefaultFilter(defaultTaskFilter)).toBe(true)
  })

  it('riconosce un filtro non di default, anche solo per l ordinamento', () => {
    expect(isDefaultFilter({ ...defaultTaskFilter, status: 'TODO' })).toBe(false)
    expect(isDefaultFilter({ ...defaultTaskFilter, sortBy: 'TITLE', direction: 'ASC' })).toBe(false)
    expect(isDefaultFilter({ ...defaultTaskFilter, search: 'latte' })).toBe(false)
  })

  it('traduce il filtro in parametri di query, omettendo le dimensioni non attive', () => {
    const filter: TaskFilter = {
      ...defaultTaskFilter,
      status: 'IN_PROGRESS',
      search: 'latte',
      sortBy: 'DUE_DATE',
      direction: 'ASC',
    }

    expect(toQueryParams(filter)).toEqual({
      page: 0,
      size: 50,
      status: 'IN_PROGRESS',
      priority: null,
      search: 'latte',
      listId: null,
      tagId: null,
      sortBy: 'DUE_DATE',
      direction: 'ASC',
    })
  })

  it('il chip attivo si spegne se ricliccato (selezione singola)', () => {
    const conStato = toggleFilterValue(defaultTaskFilter, 'status', 'TODO')
    expect(conStato.status).toBe('TODO')

    expect(toggleFilterValue(conStato, 'status', 'TODO').status).toBeNull()
    expect(toggleFilterValue(conStato, 'status', 'DONE').status).toBe('DONE')
  })

  it('vale anche per priorità e tag', () => {
    const conPriorita = toggleFilterValue(defaultTaskFilter, 'priority', 'HIGH')
    expect(toggleFilterValue(conPriorita, 'priority', 'HIGH').priority).toBeNull()

    const conTag = toggleFilterValue(defaultTaskFilter, 'tagId', 'tag-1')
    expect(conTag.tagId).toBe('tag-1')
    expect(toggleFilterValue(conTag, 'tagId', 'tag-2').tagId).toBe('tag-2')
  })

  it('una ricerca di soli spazi equivale a nessuna ricerca', () => {
    expect(clearFilterField({ ...defaultTaskFilter, search: 'latte' }, 'search').search).toBeNull()
  })
})
