import { addDays, addMonths, format, isSameDay } from 'date-fns'
import { it } from 'date-fns/locale'
import { CalendarDays, ChevronLeft, ChevronRight, Plus } from 'lucide-react'
import { useMemo, useState } from 'react'
import { useNavigate } from 'react-router'
import { EmptyState } from '@/components/layout/empty-state'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group'
import { CalendarGrid } from '@/features/calendar/calendar-grid'
import {
  calendarFormatLabels,
  calendarFormats,
  type CalendarFormat,
} from '@/features/calendar/calendar-view'
import { groupTasksByDay, localDayKey, tasksOn } from '@/features/calendar/calendar-grouping'
import { useCalendarTasks } from '@/features/calendar/queries'
import { toUpdateRequest } from '@/features/tasks/api'
import { TaskCard } from '@/features/tasks/components/task-card'
import { useDeleteTask, useUpdateTask } from '@/features/tasks/queries'
import { useDocumentTitle } from '@/lib/use-document-title'

export default function CalendarPage() {
  const [anchor, setAnchor] = useState(() => new Date())
  const [selected, setSelected] = useState(() => new Date())
  const [calendarFormat, setCalendarFormat] = useState<CalendarFormat>('month')
  const { data: tasks, isPending } = useCalendarTasks()
  const updateTask = useUpdateTask()
  const deleteTask = useDeleteTask()
  const navigate = useNavigate()

  const byDay = useMemo(() => groupTasksByDay(tasks ?? []), [tasks])
  const dayTasks = useMemo(() => tasksOn(tasks ?? [], selected), [tasks, selected])
  useDocumentTitle('Calendario')
  const now = new Date()

  /** Avanti e indietro di un mese o di una/due settimane, secondo la vista. */
  function shift(direction: 1 | -1) {
    const next =
      calendarFormat === 'month'
        ? addMonths(anchor, direction)
        : addDays(anchor, direction * (calendarFormat === 'twoWeeks' ? 14 : 7))
    setAnchor(next)
    if (calendarFormat !== 'month') {
      setSelected(next)
    }
  }

  return (
    <div className="mx-auto max-w-3xl space-y-6 p-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-semibold">Calendario</h1>
        <ToggleGroup
          type="single"
          value={calendarFormat}
          onValueChange={(value) => value && setCalendarFormat(value as CalendarFormat)}
          variant="outline"
          size="sm"
        >
          {calendarFormats.map((option) => (
            <ToggleGroupItem key={option} value={option}>
              {calendarFormatLabels[option]}
            </ToggleGroupItem>
          ))}
        </ToggleGroup>
      </div>

      <div className="bg-card space-y-3 rounded-lg border p-4">
        <div className="flex items-center justify-between">
          <Button
            variant="ghost"
            size="icon"
            aria-label="Periodo precedente"
            onClick={() => shift(-1)}
          >
            <ChevronLeft aria-hidden />
          </Button>
          <p className="font-medium capitalize">{format(anchor, 'MMMM yyyy', { locale: it })}</p>
          <div className="flex items-center gap-1">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => {
                const today = new Date()
                setAnchor(today)
                setSelected(today)
              }}
            >
              Oggi
            </Button>
            <Button
              variant="ghost"
              size="icon"
              aria-label="Periodo successivo"
              onClick={() => shift(1)}
            >
              <ChevronRight aria-hidden />
            </Button>
          </div>
        </div>

        {isPending ? (
          <Skeleton className="h-64" />
        ) : (
          <CalendarGrid
            anchor={anchor}
            format={calendarFormat}
            selected={selected}
            countFor={(day) => byDay.get(localDayKey(day))?.length ?? 0}
            onSelect={setSelected}
          />
        )}
      </div>

      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <h2 className="font-medium">
            {isSameDay(selected, new Date())
              ? 'Oggi'
              : format(selected, 'EEEE d MMMM', { locale: it })}
          </h2>
          <Button
            size="sm"
            variant="outline"
            onClick={() =>
              // La data scelta viaggia nell'URL: l'editor la usa come scadenza.
              void navigate(`/tasks/new?date=${selected.toISOString()}`)
            }
          >
            <Plus aria-hidden />
            Aggiungi
          </Button>
        </div>

        {dayTasks.length === 0 ? (
          <EmptyState
            icon={CalendarDays}
            title="Niente in programma"
            description="Nessun task scade in questo giorno."
          />
        ) : (
          dayTasks.map((task) => (
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
          ))
        )}
      </div>
    </div>
  )
}
