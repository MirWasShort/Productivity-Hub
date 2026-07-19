import { format } from 'date-fns'
import { it } from 'date-fns/locale'
import { AlertTriangle, CalendarDays, Trash2 } from 'lucide-react'
import { Link } from 'react-router'
import type { Task } from '@/api/types'
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
import { Checkbox } from '@/components/ui/checkbox'
import { PriorityPill } from '@/features/tasks/components/priority-pill'
import { TagPill } from '@/features/tasks/components/tag-pill'
import { isOverdue } from '@/features/tasks/due-grouping'
import { cn } from '@/lib/utils'

interface TaskCardProps {
  task: Task
  now: Date
  onToggleDone: (task: Task) => void
  onDelete: (task: Task) => void
}

export function TaskCard({ task, now, onToggleDone, onDelete }: TaskCardProps) {
  const done = task.status === 'DONE'
  const late = isOverdue(task, now)

  return (
    <article className="group bg-card hover:border-primary/40 flex items-start gap-3 rounded-lg border p-3 transition-colors">
      <Checkbox
        checked={done}
        onCheckedChange={() => onToggleDone(task)}
        className="mt-0.5 rounded-full"
        aria-label={done ? `Segna "${task.title}" da fare` : `Completa "${task.title}"`}
      />

      <div className="min-w-0 flex-1">
        <Link
          to={`/tasks/${task.id}`}
          className={cn(
            'font-medium hover:underline',
            done && 'text-muted-foreground line-through',
          )}
        >
          {task.title}
        </Link>

        {task.description && (
          <p className="text-muted-foreground truncate text-sm">{task.description}</p>
        )}

        <div className="mt-1 flex flex-wrap items-center gap-2">
          {task.dueDate && (
            <span
              className={cn(
                'flex items-center gap-1 text-xs',
                late ? 'text-destructive font-medium' : 'text-muted-foreground',
              )}
            >
              {late ? (
                <AlertTriangle className="size-3" aria-hidden />
              ) : (
                <CalendarDays className="size-3" aria-hidden />
              )}
              {format(new Date(task.dueDate), 'd MMM yyyy', { locale: it })}
            </span>
          )}
          {task.tags.map((tag) => (
            <TagPill key={tag.id} tag={tag} />
          ))}
        </div>
      </div>

      <div className="flex shrink-0 items-center gap-2">
        <PriorityPill priority={task.priority} />
        {/* Sul telefono si scorre la card per eliminarla; qui il gesto
            equivalente è un pulsante che compare al passaggio del mouse —
            ma resta raggiungibile da tastiera grazie a focus-visible. */}
        <AlertDialog>
          <AlertDialogTrigger asChild>
            <Button
              variant="ghost"
              size="icon-sm"
              className="text-muted-foreground hover:text-destructive opacity-0 transition-opacity group-hover:opacity-100 focus-visible:opacity-100"
              aria-label={`Elimina "${task.title}"`}
            >
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
              <AlertDialogAction onClick={() => onDelete(task)}>Elimina</AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
      </div>
    </article>
  )
}
