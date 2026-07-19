import { format } from 'date-fns'
import { it } from 'date-fns/locale'
import { ArrowLeft, Pencil, Trash2 } from 'lucide-react'
import { Link, Navigate, useNavigate, useParams } from 'react-router'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import { PriorityPill } from '@/features/tasks/components/priority-pill'
import { TagPill } from '@/features/tasks/components/tag-pill'
import { isOverdue } from '@/features/tasks/due-grouping'
import { statusLabels } from '@/features/tasks/labels'
import { useDeleteTask, useTask } from '@/features/tasks/queries'
import { ApiError } from '@/lib/api/errors'
import { cn } from '@/lib/utils'

function Row({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between border-b py-2 last:border-b-0">
      <span className="text-muted-foreground text-sm">{label}</span>
      <span className="text-sm">{children}</span>
    </div>
  )
}

export default function TaskDetailPage() {
  const { taskId } = useParams()
  const navigate = useNavigate()
  const { data: task, isPending, error } = useTask(taskId)
  const deleteTask = useDeleteTask()

  if (isPending) {
    return (
      <div className="mx-auto max-w-3xl space-y-4 p-6">
        <Skeleton className="h-8 w-2/3" />
        <Skeleton className="h-32" />
      </div>
    )
  }

  // Un task cancellato altrove (o l'id di qualcun altro) non è un errore da
  // mostrare: si torna alla lista, che è la verità.
  if (error instanceof ApiError && error.isNotFound) {
    return <Navigate to="/tasks" replace />
  }

  if (!task) {
    return (
      <p role="alert" className="text-destructive p-6 text-sm">
        Non riesco a caricare questo task.
      </p>
    )
  }

  const now = new Date()

  return (
    <div className="mx-auto max-w-3xl space-y-6 p-6">
      <div className="flex items-center gap-2">
        <Button asChild variant="ghost" size="icon" aria-label="Torna ai task">
          <Link to="/tasks">
            <ArrowLeft aria-hidden />
          </Link>
        </Button>
        <h1 className="flex-1 text-2xl font-semibold">{task.title}</h1>
        <Button asChild variant="outline" size="sm">
          <Link to={`/tasks/${task.id}/edit`}>
            <Pencil aria-hidden />
            Modifica
          </Link>
        </Button>
        <AlertDialog>
          <AlertDialogTrigger asChild>
            <Button variant="ghost" size="icon" aria-label="Elimina il task">
              <Trash2 aria-hidden />
            </Button>
          </AlertDialogTrigger>
          <AlertDialogContent>
            <AlertDialogHeader>
              <AlertDialogTitle>Eliminare questo task?</AlertDialogTitle>
              <AlertDialogDescription>
                «{task.title}» verrà eliminato definitivamente.
              </AlertDialogDescription>
            </AlertDialogHeader>
            <AlertDialogFooter>
              <AlertDialogCancel>Annulla</AlertDialogCancel>
              <AlertDialogAction
                onClick={async () => {
                  await deleteTask.mutateAsync(task.id)
                  await navigate('/tasks')
                }}
              >
                Elimina
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
      </div>

      {task.description && <p className="text-sm whitespace-pre-wrap">{task.description}</p>}

      <div className="bg-card rounded-lg border px-4">
        <Row label="Stato">{statusLabels[task.status]}</Row>
        <Row label="Priorità">
          <PriorityPill priority={task.priority} />
        </Row>
        <Row label="Scadenza">
          <span className={cn(isOverdue(task, now) && 'text-destructive font-medium')}>
            {task.dueDate
              ? format(new Date(task.dueDate), 'd MMMM yyyy', { locale: it })
              : 'Nessuna'}
          </span>
        </Row>
        <Row label="Creato">{format(new Date(task.createdAt), 'd MMMM yyyy', { locale: it })}</Row>
        {task.tags.length > 0 && (
          <Row label="Tag">
            <span className="flex flex-wrap justify-end gap-1">
              {task.tags.map((tag) => (
                <TagPill key={tag.id} tag={tag} />
              ))}
            </span>
          </Row>
        )}
      </div>
    </div>
  )
}
