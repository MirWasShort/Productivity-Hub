import { useQuery } from '@tanstack/react-query'
import type { Page, Task } from '@/api/types'
import { taskKeys } from '@/features/tasks/queries'
import { apiFetch } from '@/lib/api/client'

/**
 * Il calendario legge **tutti** i task, indipendentemente dai filtri della
 * lista: mostrare un mese bucato perché è attivo il chip "Da fare" sarebbe
 * disorientante. È una fetch separata, ma la sua chiave sta sotto `['tasks']`,
 * quindi ogni mutazione la invalida senza bisogno di ricordarselo (C38).
 */
export function useCalendarTasks() {
  return useQuery({
    queryKey: taskKeys.calendar(),
    queryFn: async () => {
      const page = await apiFetch<Page<Task>>('/tasks', {
        params: { page: 0, size: 200, sortBy: 'DUE_DATE', direction: 'ASC' },
      })
      return page.items
    },
  })
}
