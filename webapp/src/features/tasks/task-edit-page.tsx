import { zodResolver } from '@hookform/resolvers/zod'
import { ArrowLeft } from 'lucide-react'
import { useMemo } from 'react'
import { useForm } from 'react-hook-form'
import { Link, useNavigate, useParams, useSearchParams } from 'react-router'
import { z } from 'zod'
import { taskPriorities, taskStatuses } from '@/api/types'
import { Button } from '@/components/ui/button'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { NativeSelect } from '@/components/ui/native-select'
import { Skeleton } from '@/components/ui/skeleton'
import { Textarea } from '@/components/ui/textarea'
import { DueDatePicker } from '@/features/tasks/components/due-date-picker'
import { priorityLabels, statusLabels } from '@/features/tasks/labels'
import { useCreateTask, useTask, useUpdateTask } from '@/features/tasks/queries'

/** Gli stessi limiti del backend (`CreateTaskRequest`). */
const taskSchema = z.object({
  title: z.string().trim().min(1, 'Il titolo è obbligatorio').max(200, 'Titolo troppo lungo'),
  description: z.string().max(10000, 'Descrizione troppo lunga'),
  status: z.enum(taskStatuses),
  priority: z.enum(taskPriorities),
  dueDate: z.date().optional(),
})

type TaskValues = z.infer<typeof taskSchema>

export default function TaskEditPage() {
  const { taskId } = useParams()
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const isEditing = taskId !== undefined
  const { data: task, isPending } = useTask(taskId)
  const createTask = useCreateTask()
  const updateTask = useUpdateTask()

  /*
   * I valori iniziali vanno memoizzati: `values` fa ripartire un reset del
   * form ogni volta che l'oggetto cambia, e `new Date(...)` ne produce uno
   * diverso a ogni render. Senza memo il form si resetta di continuo e
   * l'invio non arriva mai in fondo.
   *
   * In creazione i valori arrivano dalla query string: il titolo scritto
   * nell'aggiunta rapida e il giorno scelto nel calendario.
   */
  const titleParam = searchParams.get('title')
  const dateParam = searchParams.get('date')
  const values = useMemo<TaskValues>(
    () =>
      task
        ? {
            title: task.title,
            description: task.description ?? '',
            status: task.status,
            priority: task.priority,
            dueDate: task.dueDate ? new Date(task.dueDate) : undefined,
          }
        : {
            title: titleParam ?? '',
            description: '',
            status: 'TODO',
            priority: 'MEDIUM',
            dueDate: dateParam ? new Date(dateParam) : undefined,
          },
    [task, titleParam, dateParam],
  )

  const form = useForm<TaskValues>({ resolver: zodResolver(taskSchema), values })

  async function onSubmit(values: TaskValues) {
    const body = {
      title: values.title,
      description: values.description === '' ? undefined : values.description,
      priority: values.priority,
      // Il backend vuole un istante UTC; il picker dà una data locale.
      dueDate: values.dueDate?.toISOString(),
    }

    if (isEditing && task) {
      await updateTask.mutateAsync({
        taskId: task.id,
        body: {
          ...body,
          status: values.status,
          listId: task.listId,
          tagIds: task.tags.map((t) => t.id),
        },
      })
      await navigate(`/tasks/${task.id}`)
      return
    }
    await createTask.mutateAsync(body)
    await navigate('/tasks')
  }

  if (isEditing && isPending) {
    return (
      <div className="mx-auto max-w-125 space-y-4 p-6">
        <Skeleton className="h-10" />
        <Skeleton className="h-24" />
      </div>
    )
  }

  return (
    <div className="mx-auto max-w-125 space-y-6 p-6">
      <div className="flex items-center gap-2">
        <Button asChild variant="ghost" size="icon" aria-label="Torna indietro">
          <Link to={isEditing && task ? `/tasks/${task.id}` : '/tasks'}>
            <ArrowLeft aria-hidden />
          </Link>
        </Button>
        <h1 className="text-2xl font-semibold">{isEditing ? 'Modifica task' : 'Nuovo task'}</h1>
      </div>

      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4" noValidate>
          <FormField
            control={form.control}
            name="title"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Titolo</FormLabel>
                <FormControl>
                  <Input autoFocus {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="description"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Descrizione</FormLabel>
                <FormControl>
                  <Textarea rows={3} {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          {/* Lo stato si sceglie solo modificando: un task appena creato è da fare. */}
          {isEditing && (
            <FormField
              control={form.control}
              name="status"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Stato</FormLabel>
                  <FormControl>
                    <NativeSelect {...field}>
                      {taskStatuses.map((status) => (
                        <option key={status} value={status}>
                          {statusLabels[status]}
                        </option>
                      ))}
                    </NativeSelect>
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
          )}

          <FormField
            control={form.control}
            name="priority"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Priorità</FormLabel>
                <FormControl>
                  <NativeSelect {...field}>
                    {taskPriorities.map((priority) => (
                      <option key={priority} value={priority}>
                        {priorityLabels[priority]}
                      </option>
                    ))}
                  </NativeSelect>
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="dueDate"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Scadenza</FormLabel>
                <DueDatePicker value={field.value} onChange={field.onChange} />
                <FormMessage />
              </FormItem>
            )}
          />

          <div className="flex gap-2">
            <Button type="submit" disabled={form.formState.isSubmitting}>
              {isEditing ? 'Salva' : 'Crea'}
            </Button>
            <Button asChild type="button" variant="ghost">
              <Link to={isEditing && task ? `/tasks/${task.id}` : '/tasks'}>Annulla</Link>
            </Button>
          </div>
        </form>
      </Form>
    </div>
  )
}
