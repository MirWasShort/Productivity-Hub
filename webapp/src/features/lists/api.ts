import type { ListRequest, TodoList } from '@/api/types'
import { apiFetch } from '@/lib/api/client'

export function fetchLists(): Promise<TodoList[]> {
  return apiFetch<TodoList[]>('/lists')
}

export function createList(body: ListRequest): Promise<TodoList> {
  return apiFetch<TodoList>('/lists', { method: 'POST', body })
}

export function updateList(listId: string, body: ListRequest): Promise<TodoList> {
  return apiFetch<TodoList>(`/lists/${listId}`, { method: 'PUT', body })
}

export function deleteList(listId: string): Promise<void> {
  return apiFetch<void>(`/lists/${listId}`, { method: 'DELETE' })
}
