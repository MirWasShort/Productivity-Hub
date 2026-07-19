import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import type { ListRequest } from '@/api/types'
import { createList, deleteList, fetchLists, updateList } from '@/features/lists/api'
import { taskKeys } from '@/features/tasks/queries'

export const listKeys = { all: ['lists'] as const }

export function useLists() {
  return useQuery({ queryKey: listKeys.all, queryFn: fetchLists })
}

export function useCreateList() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: (body: ListRequest) => createList(body),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: listKeys.all }),
  })
}

export function useUpdateList() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: ({ listId, body }: { listId: string; body: ListRequest }) =>
      updateList(listId, body),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: listKeys.all }),
  })
}

export function useDeleteList() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: (listId: string) => deleteList(listId),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: listKeys.all })
      // Il backend scollega i task dalla lista eliminata (ON DELETE SET NULL):
      // anche i task vanno riletti, o mostrerebbero una lista che non esiste.
      void queryClient.invalidateQueries({ queryKey: taskKeys.all })
    },
  })
}
