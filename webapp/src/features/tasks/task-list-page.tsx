import { CheckCircle2, SearchX } from 'lucide-react'
import type { Task } from '@/api/types'
import { useMemo, useState } from 'react'
import { useSearchParams } from 'react-router'
import { EmptyState } from '@/components/layout/empty-state'
import { Skeleton } from '@/components/ui/skeleton'
import { toUpdateRequest } from '@/features/tasks/api'
import { FilterBar } from '@/features/tasks/components/filter-bar'
import { QuickAdd } from '@/features/tasks/components/quick-add'
import { TaskCard } from '@/features/tasks/components/task-card'
import { groupByDue } from '@/features/tasks/due-grouping'
import { defaultTaskFilter, isDefaultFilter } from '@/features/tasks/filters'
import { useLists } from '@/features/lists/queries'
import { useCreateTask, useDeleteTask, useTasks, useUpdateTask } from '@/features/tasks/queries'

export default function TaskListPage() {
  const [searchParams] = useSearchParams()
  const { data: lists } = useLists()
  const [filter, setFilter] = useState(defaultTaskFilter)

  /*
   * La lista selezionata arriva dall'URL, non dallo stato locale: è la barra
   * laterale a sceglierla, e vive fuori da questa pagina. Passando per
   * l'indirizzo, il collegamento fra le due parti è la navigazione stessa —
   * niente stato globale, e l'URL resta condivisibile.
   */
  const selectedListId = searchParams.get('list')
  const activeFilter = useMemo(
    () => ({ ...filter, listId: selectedListId }),
    [filter, selectedListId],
  )
  const selectedList = lists?.find((list) => list.id === selectedListId)
  const { data: tasks, isPending, isError } = useTasks(activeFilter)
  const createTask = useCreateTask()
  const updateTask = useUpdateTask()
  const deleteTask = useDeleteTask()

  /*
   * Un unico "adesso" per tutta la lista: se ogni card leggesse l'orologio da
   * sé, due card potrebbero classificare la stessa scadenza in modo diverso.
   * Si ricalcola quando arrivano dati nuovi — non a ogni render, o le sezioni
   * cambierebbero sotto le mani dell'utente a metà interazione.
   */
  // oxlint-disable-next-line react-hooks/exhaustive-deps -- `tasks` è la sveglia, non un ingrediente
  const now = useMemo(() => new Date(), [tasks])
  // Le sezioni per scadenza valgono solo con l'ordinamento predefinito: se
  // l'utente ha chiesto "titolo A-Z", l'urgenza non è più il criterio.
  const sections = useMemo(
    () => (isDefaultFilter(activeFilter) ? groupByDue(tasks ?? [], now) : []),
    [tasks, now, activeFilter],
  )
  const isEmpty = tasks?.length === 0

  function handleToggleDone(target: Task) {
    updateTask.mutate({
      taskId: target.id,
      body: toUpdateRequest(target, { status: target.status === 'DONE' ? 'TODO' : 'DONE' }),
    })
  }

  return (
    <div className="mx-auto max-w-3xl space-y-6 p-6">
      <h1 className="text-2xl font-semibold">{selectedList?.name ?? 'I miei task'}</h1>

      <QuickAdd
        pending={createTask.isPending}
        onAdd={(title) => createTask.mutateAsync({ title, listId: selectedListId ?? undefined })}
      />

      <FilterBar filter={filter} onChange={setFilter} />

      {isPending && (
        <div className="space-y-2">
          <Skeleton className="h-16 rounded-lg" />
          <Skeleton className="h-16 rounded-lg" />
          <Skeleton className="h-16 rounded-lg" />
        </div>
      )}

      {isError && (
        <p role="alert" className="text-destructive text-sm">
          Non riesco a caricare i task. Controlla la connessione e riprova.
        </p>
      )}

      {isEmpty &&
        (isDefaultFilter(activeFilter) ? (
          <EmptyState
            icon={CheckCircle2}
            title="Nessun task, per ora"
            description="Aggiungi il primo qui sopra: bastano un titolo e Invio."
          />
        ) : (
          <EmptyState
            icon={SearchX}
            title="Nessun risultato"
            description="Nessun task corrisponde ai filtri attivi."
          />
        ))}

      {!isDefaultFilter(activeFilter) && tasks && tasks.length > 0 && (
        <div className="space-y-2">
          {tasks.map((task) => (
            <TaskCard
              key={task.id}
              task={task}
              now={now}
              onToggleDone={handleToggleDone}
              onDelete={(target) => deleteTask.mutate(target.id)}
            />
          ))}
        </div>
      )}

      {sections.map((section) => (
        <section key={section.group} className="space-y-2">
          <h2 className="flex items-center gap-2 text-sm font-semibold">
            <span className={section.group === 'overdue' ? 'text-destructive' : 'text-primary'}>
              {section.label}
            </span>
            <span className="bg-muted text-muted-foreground rounded-sm px-1.5 py-0.5 text-xs">
              {section.tasks.length}
            </span>
          </h2>
          <div className="space-y-2">
            {section.tasks.map((task) => (
              <TaskCard
                key={task.id}
                task={task}
                now={now}
                onToggleDone={handleToggleDone}
                onDelete={(target) => deleteTask.mutate(target.id)}
              />
            ))}
          </div>
        </section>
      ))}
    </div>
  )
}
