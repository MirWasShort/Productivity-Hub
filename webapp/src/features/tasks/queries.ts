import { useMutation, useQuery, useQueryClient, type QueryClient } from '@tanstack/react-query'
import type { CreateTaskRequest, Task, UpdateTaskRequest } from '@/api/types'
import { createTask, deleteTask, fetchTask, fetchTasks, updateTask } from '@/features/tasks/api'
import type { TaskFilter } from '@/features/tasks/filters'

/**
 * Chiavi di cache. Tutto ciò che riguarda i task sta sotto `['tasks']`, così
 * una sola invalidazione con quel prefisso copre anche la fetch separata del
 * calendario — la lezione di C38, dove il calendario restava indietro perché
 * nessuno lo invalidava.
 */
export const taskKeys = {
  all: ['tasks'] as const,
  list: (filter: TaskFilter) => ['tasks', 'list', filter] as const,
  detail: (taskId: string) => ['tasks', 'detail', taskId] as const,
  calendar: () => ['tasks', 'calendar'] as const,
}

const analyticsKey = ['analytics'] as const

/** Sotto il prefisso `['tasks']` convivono liste e singoli task. */
type TaskCache = Task[] | Task | undefined

function updateCached(cached: TaskCache, taskId: string, apply: (task: Task) => Task): TaskCache {
  if (Array.isArray(cached)) {
    return cached.map((task) => (task.id === taskId ? apply(task) : task))
  }
  if (cached && cached.id === taskId) {
    return apply(cached)
  }
  return cached
}

/** I numeri della dashboard derivano dai task: cambiano insieme a loro. */
function invalidateTaskData(queryClient: QueryClient) {
  void queryClient.invalidateQueries({ queryKey: taskKeys.all })
  void queryClient.invalidateQueries({ queryKey: analyticsKey })
}

export function useTasks(filter: TaskFilter) {
  return useQuery({
    queryKey: taskKeys.list(filter),
    queryFn: () => fetchTasks(filter),
    // Il filtro fa parte della chiave: cambiarlo è una query diversa, e
    // `placeholderData` evita che la lista sparisca mentre arriva la nuova.
    placeholderData: (previous) => previous,
  })
}

export function useTask(taskId: string | undefined) {
  return useQuery({
    queryKey: taskKeys.detail(taskId ?? ''),
    queryFn: () => fetchTask(taskId!),
    enabled: taskId !== undefined,
  })
}

export function useCreateTask() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: (body: CreateTaskRequest) => createTask(body),
    onSuccess: () => invalidateTaskData(queryClient),
  })
}

export function useUpdateTask() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: ({ taskId, body }: { taskId: string; body: UpdateTaskRequest }) =>
      updateTask(taskId, body),
    /*
     * Aggiornamento ottimistico: spuntare una casella deve rispondere subito,
     * non dopo il giro di rete. Si salva lo stato precedente per poterlo
     * rimettere se il server rifiuta.
     */
    onMutate: async ({ taskId, body }) => {
      await queryClient.cancelQueries({ queryKey: taskKeys.all })
      const snapshot = queryClient.getQueriesData<TaskCache>({ queryKey: taskKeys.all })

      // Sotto `['tasks']` non ci sono solo liste: `['tasks','detail',id]`
      // contiene un singolo task. Aggiornarle con la stessa funzione senza
      // distinguere le due forme farebbe fallire `onMutate`, e la mutazione
      // non partirebbe nemmeno.
      queryClient.setQueriesData<TaskCache>({ queryKey: taskKeys.all }, (cached) =>
        updateCached(cached, taskId, (task) => ({ ...task, ...body, tags: task.tags })),
      )
      return { snapshot }
    },
    onError: (_error, _variables, context) => {
      for (const [key, data] of context?.snapshot ?? []) {
        queryClient.setQueryData(key, data)
      }
    },
    onSettled: () => invalidateTaskData(queryClient),
  })
}

export function useDeleteTask() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: (taskId: string) => deleteTask(taskId),
    onMutate: async (taskId) => {
      await queryClient.cancelQueries({ queryKey: taskKeys.all })
      const snapshot = queryClient.getQueriesData<TaskCache>({ queryKey: taskKeys.all })

      queryClient.setQueriesData<TaskCache>({ queryKey: taskKeys.all }, (cached) =>
        Array.isArray(cached) ? cached.filter((task) => task.id !== taskId) : cached,
      )
      return { snapshot }
    },
    onError: (_error, _variables, context) => {
      for (const [key, data] of context?.snapshot ?? []) {
        queryClient.setQueryData(key, data)
      }
    },
    onSettled: () => invalidateTaskData(queryClient),
  })
}
