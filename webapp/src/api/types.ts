import type { components, operations } from '@/api/schema'

type Schemas = components['schemas']
type ListQuery = NonNullable<operations['list']['parameters']['query']>

/**
 * Tipi di dominio della webapp.
 *
 * Perché non usiamo direttamente `components['schemas']`: springdoc genera
 * ogni campo di risposta come opzionale (`id?: string`), perché in Java tutto
 * è nullable finché non lo si annota. Usarli così costringerebbe a un `?? ''`
 * a ogni accesso, anche su campi che il backend valorizza sempre.
 *
 * Qui dichiariamo la forma che ci aspettiamo davvero, distinguendo i campi
 * *veramente* nullable (`description`, `dueDate`, `listId`, `color`) da quelli
 * garantiti. I blocchi `AssertCompatible` in fondo verificano in compilazione
 * che questi tipi restino un sottoinsieme dello schema generato: se il backend
 * rinomina un campo o cambia un enum, `npm run typecheck` fallisce.
 */

export const taskStatuses = ['TODO', 'IN_PROGRESS', 'DONE'] as const
export type TaskStatus = (typeof taskStatuses)[number]

export const taskPriorities = ['LOW', 'MEDIUM', 'HIGH'] as const
export type TaskPriority = (typeof taskPriorities)[number]

export const taskSortFields = ['CREATED_AT', 'DUE_DATE', 'PRIORITY', 'TITLE'] as const
export type TaskSortField = (typeof taskSortFields)[number]

export const sortDirections = ['ASC', 'DESC'] as const
export type SortDirection = (typeof sortDirections)[number]

export interface Tag {
  id: string
  name: string
  /** `#RRGGBB` oppure assente: il backend lo consente. */
  color?: string
}

export interface TodoList {
  id: string
  name: string
  color?: string
  position: number
  createdAt: string
  updatedAt: string
}

export interface Task {
  id: string
  title: string
  description?: string
  status: TaskStatus
  priority: TaskPriority
  /** ISO-8601 UTC. */
  dueDate?: string
  listId?: string
  tags: Tag[]
  createdAt: string
  updatedAt: string
}

export interface User {
  id: string
  email: string
  displayName: string
}

export interface AuthResponse {
  accessToken: string
  refreshToken: string
  /** Durata dell'access token, in secondi. */
  expiresIn: number
  user: User
}

export interface Page<T> {
  items: T[]
  page: number
  size: number
  totalElements: number
  totalPages: number
}

export interface AnalyticsSummary {
  total: number
  completed: number
  overdue: number
  dueToday: number
  byStatus: Partial<Record<TaskStatus, number>>
  byPriority: Partial<Record<TaskPriority, number>>
}

/** `date` è un giorno locale `YYYY-MM-DD`, non un istante. */
export interface DayCount {
  date: string
  count: number
}

export interface Completions {
  from: string
  to: string
  days: DayCount[]
}

/* Corpi di richiesta: qui lo schema generato è già preciso (i campi
   obbligatori sono annotati con @NotNull/@NotBlank lato Java). */
export type LoginRequest = Schemas['LoginRequest']
export type RegisterRequest = Schemas['RegisterRequest']
export type RefreshRequest = Schemas['RefreshRequest']
export type CreateTaskRequest = Schemas['CreateTaskRequest']
export type UpdateTaskRequest = Schemas['UpdateTaskRequest']
export type ListRequest = Schemas['ListRequest']
export type TagRequest = Schemas['TagRequest']

/** Parametri accettati da `GET /api/v1/tasks`. */
export type TaskQueryParams = ListQuery

/** Corpo di errore uniforme del backend (`ErrorResponse`). */
export interface ApiErrorBody {
  timestamp?: string
  status?: number
  error?: string
  message?: string
  path?: string
  fieldErrors?: Record<string, string>
}

/*
 * Ponte con lo schema generato. Servono due controlli distinti, perché
 * springdoc marca tutto come opzionale:
 *
 * - `AssertAssignable` verifica che i nostri tipi siano compatibili con lo
 *   schema (un enum che cambia valori qui fallisce);
 * - `AssertNoUnknownKeys` verifica che ogni campo che usiamo esista davvero
 *   nello schema — senza, un campo rinominato lato backend passerebbe
 *   inosservato, dato che un campo opzionale mancante non rompe nulla.
 */
type AssertAssignable<Schema, Domain extends Schema> = Domain
type AssertNever<T extends never> = T

export type _TagMatches = AssertAssignable<Schemas['TagResponse'], Tag>
export type _TagKeys = AssertNever<Exclude<keyof Tag, keyof Schemas['TagResponse']>>
export type _ListMatches = AssertAssignable<Schemas['ListResponse'], TodoList>
export type _ListKeys = AssertNever<Exclude<keyof TodoList, keyof Schemas['ListResponse']>>
export type _TaskMatches = AssertAssignable<Schemas['TaskResponse'], Task>
export type _TaskKeys = AssertNever<Exclude<keyof Task, keyof Schemas['TaskResponse']>>
export type _UserMatches = AssertAssignable<Schemas['UserDto'], User>
export type _UserKeys = AssertNever<Exclude<keyof User, keyof Schemas['UserDto']>>
export type _AuthMatches = AssertAssignable<Schemas['AuthResponse'], AuthResponse>
export type _AuthKeys = AssertNever<Exclude<keyof AuthResponse, keyof Schemas['AuthResponse']>>
export type _PageMatches = AssertAssignable<Schemas['PageResponseTaskResponse'], Page<Task>>
export type _PageKeys = AssertNever<
  Exclude<keyof Page<Task>, keyof Schemas['PageResponseTaskResponse']>
>
export type _SummaryMatches = AssertAssignable<Schemas['AnalyticsSummaryView'], AnalyticsSummary>
export type _SummaryKeys = AssertNever<
  Exclude<keyof AnalyticsSummary, keyof Schemas['AnalyticsSummaryView']>
>
export type _CompletionsMatches = AssertAssignable<Schemas['CompletionsView'], Completions>
export type _CompletionsKeys = AssertNever<
  Exclude<keyof Completions, keyof Schemas['CompletionsView']>
>
export type _ErrorKeys = AssertNever<Exclude<keyof ApiErrorBody, keyof Schemas['ErrorResponse']>>
