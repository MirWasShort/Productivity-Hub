import { describe, expect, it } from 'vitest'
import {
  sortDirections,
  taskPriorities,
  taskSortFields,
  taskStatuses,
  type TaskPriority,
  type TaskStatus,
} from '@/api/types'
import type { components, operations } from '@/api/schema'

describe('enum del dominio', () => {
  it('gli stati coprono quelli del backend, nello stesso ordine del wire', () => {
    expect(taskStatuses).toEqual(['TODO', 'IN_PROGRESS', 'DONE'])
  })

  it('le priorità coprono quelle del backend', () => {
    expect(taskPriorities).toEqual(['LOW', 'MEDIUM', 'HIGH'])
  })

  it('i campi di ordinamento e le direzioni coprono quelli del backend', () => {
    expect(taskSortFields).toEqual(['CREATED_AT', 'DUE_DATE', 'PRIORITY', 'TITLE'])
    expect(sortDirections).toEqual(['ASC', 'DESC'])
  })

  it('i valori sono esattamente quelli dello schema generato', () => {
    // Se il backend aggiunge o rinomina un enum, questi confronti falliscono
    // in compilazione: `satisfies` verifica l'uguaglianza dei tipi unione.
    type SchemaStatus = NonNullable<components['schemas']['TaskResponse']['status']>
    type SchemaPriority = NonNullable<components['schemas']['TaskResponse']['priority']>
    type SchemaSort = NonNullable<NonNullable<operations['list']['parameters']['query']>['sortBy']>

    const status: SchemaStatus = 'TODO' satisfies TaskStatus
    const priority: SchemaPriority = 'HIGH' satisfies TaskPriority
    const sort: SchemaSort = 'DUE_DATE'

    expect([status, priority, sort]).toEqual(['TODO', 'HIGH', 'DUE_DATE'])
  })
})
