import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import type { TagRequest } from '@/api/types'
import { createTag, deleteTag, fetchTags, updateTag } from '@/features/tags/api'
import { taskKeys } from '@/features/tasks/queries'

export const tagKeys = { all: ['tags'] as const }

export function useTags() {
  return useQuery({ queryKey: tagKeys.all, queryFn: fetchTags })
}

/** I tag sono incorporati nei task: cambiarli o eliminarli tocca anche quelli. */
function useTagMutation<TVariables>(mutationFn: (variables: TVariables) => Promise<unknown>) {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn,
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: tagKeys.all })
      void queryClient.invalidateQueries({ queryKey: taskKeys.all })
    },
  })
}

export function useCreateTag() {
  return useTagMutation((body: TagRequest) => createTag(body))
}

export function useUpdateTag() {
  return useTagMutation(({ tagId, body }: { tagId: string; body: TagRequest }) =>
    updateTag(tagId, body),
  )
}

export function useDeleteTag() {
  return useTagMutation((tagId: string) => deleteTag(tagId))
}
