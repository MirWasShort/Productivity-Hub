import type { CreateTaskRequest, Page, Task, UpdateTaskRequest } from '@/api/types'
import { apiFetch } from '@/lib/api/client'
import { toQueryParams, type TaskFilter } from '@/features/tasks/filters'

export async function fetchTasks(filter: TaskFilter): Promise<Task[]> {
  const page = await apiFetch<Page<Task>>('/tasks', { params: toQueryParams(filter) })
  return page.items
}

export function fetchTask(taskId: string): Promise<Task> {
  return apiFetch<Task>(`/tasks/${taskId}`)
}

export function createTask(body: CreateTaskRequest): Promise<Task> {
  return apiFetch<Task>('/tasks', { method: 'POST', body })
}

export function updateTask(taskId: string, body: UpdateTaskRequest): Promise<Task> {
  return apiFetch<Task>(`/tasks/${taskId}`, { method: 'PUT', body })
}

export function deleteTask(taskId: string): Promise<void> {
  return apiFetch<void>(`/tasks/${taskId}`, { method: 'DELETE' })
}

/**
 * `PUT /tasks/:id` sostituisce il task per intero: title, status e priority
 * sono obbligatori. Per cambiare un solo campo bisogna quindi rimandare tutto
 * il resto invariato, altrimenti si azzera silenziosamente.
 */
export function toUpdateRequest(task: Task, changes: Partial<UpdateTaskRequest> = {}) {
  return {
    title: task.title,
    description: task.description,
    status: task.status,
    priority: task.priority,
    dueDate: task.dueDate,
    listId: task.listId,
    tagIds: task.tags.map((tag) => tag.id),
    ...changes,
  } satisfies UpdateTaskRequest
}
