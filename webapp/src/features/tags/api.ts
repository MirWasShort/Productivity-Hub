import type { Tag, TagRequest } from '@/api/types'
import { apiFetch } from '@/lib/api/client'

export function fetchTags(): Promise<Tag[]> {
  return apiFetch<Tag[]>('/tags')
}

export function createTag(body: TagRequest): Promise<Tag> {
  return apiFetch<Tag>('/tags', { method: 'POST', body })
}

export function updateTag(tagId: string, body: TagRequest): Promise<Tag> {
  return apiFetch<Tag>(`/tags/${tagId}`, { method: 'PUT', body })
}

export function deleteTag(tagId: string): Promise<void> {
  return apiFetch<void>(`/tags/${tagId}`, { method: 'DELETE' })
}
