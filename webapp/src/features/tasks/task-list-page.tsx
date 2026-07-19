import { CheckCircle2, SearchX } from 'lucide-react'
import { useMemo, useState } from 'react'
import { EmptyState } from '@/components/layout/empty-state'
import { Skeleton } from '@/components/ui/skeleton'
import { toUpdateRequest } from '@/features/tasks/api'
import { QuickAdd } from '@/features/tasks/components/quick-add'
import { TaskCard } from '@/features/tasks/components/task-card'
import { groupByDue } from '@/features/tasks/due-grouping'
import { defaultTaskFilter, isDefaultFilter } from '@/features/tasks/filters'
import { useCreateTask, useDeleteTask, useTasks, useUpdateTask } from '@/features/tasks/queries'

export default function TaskListPage() {
  // La barra dei filtri che pilota questo stato arriva nel commit successivo.
  const [filter] = useState(defaultTaskFilter)
  const { data: tasks, isPending, isError } = useTasks(filter)
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
    () => (isDefaultFilter(filter) ? groupByDue(tasks ?? [], now) : []),
    [tasks, now, filter],
  )
  const isEmpty = tasks?.length === 0

  return (
    <div className="mx-auto max-w-3xl space-y-6 p-6">
      <h1 className="text-2xl font-semibold">I miei task</h1>

      <QuickAdd
        pending={createTask.isPending}
        onAdd={(title) => createTask.mutateAsync({ title })}
      />

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
        (isDefaultFilter(filter) ? (
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
                onToggleDone={(target) =>
                  updateTask.mutate({
                    taskId: target.id,
                    body: toUpdateRequest(target, {
                      status: target.status === 'DONE' ? 'TODO' : 'DONE',
                    }),
                  })
                }
                onDelete={(target) => deleteTask.mutate(target.id)}
              />
            ))}
          </div>
        </section>
      ))}
    </div>
  )
}
