import { Plus, Trash2 } from 'lucide-react'
import { Link, useLocation, useSearchParams } from 'react-router'
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
import { ListEditorDialog } from '@/features/lists/list-editor-dialog'
import { useCreateList, useDeleteList, useLists } from '@/features/lists/queries'
import { normalizeHex } from '@/lib/theme/list-colors'
import { cn } from '@/lib/utils'

/**
 * Le liste dell'utente nella barra laterale. La lista selezionata vive
 * nell'URL (`/tasks?list=<id>`), non in uno stato condiviso: sul web è
 * l'indirizzo il posto naturale per "cosa sto guardando" — si può mettere fra
 * i preferiti, condividere, e il pulsante Indietro fa quello che ci si aspetta.
 */
export function SidebarLists() {
  const { data: lists } = useLists()
  const [searchParams] = useSearchParams()
  const location = useLocation()
  const createList = useCreateList()
  const deleteList = useDeleteList()
  const selectedListId = searchParams.get('list')
  const onTasks = location.pathname === '/tasks'

  return (
    <div className="mt-4 space-y-1">
      <p className="text-muted-foreground px-3 text-xs font-semibold tracking-wide uppercase">
        Liste
      </p>

      <Link
        to="/tasks"
        className={cn(
          'block rounded-md px-3 py-1.5 text-sm',
          onTasks && !selectedListId
            ? 'bg-primary-container text-primary-container-foreground'
            : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground',
        )}
      >
        Tutte le attività
      </Link>

      {lists?.map((list) => (
        <div key={list.id} className="group flex items-center gap-1">
          <Link
            to={`/tasks?list=${list.id}`}
            className={cn(
              'flex min-w-0 flex-1 items-center gap-2 rounded-md px-3 py-1.5 text-sm',
              selectedListId === list.id
                ? 'bg-primary-container text-primary-container-foreground'
                : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground',
            )}
          >
            <span
              className="size-2.5 shrink-0 rounded-full"
              style={{ backgroundColor: normalizeHex(list.color) }}
              aria-hidden
            />
            <span className="truncate">{list.name}</span>
          </Link>

          <AlertDialog>
            <AlertDialogTrigger asChild>
              <Button
                variant="ghost"
                size="icon-xs"
                aria-label={`Elimina la lista "${list.name}"`}
                className="text-muted-foreground hover:text-destructive opacity-0 group-hover:opacity-100 focus-visible:opacity-100"
              >
                <Trash2 aria-hidden />
              </Button>
            </AlertDialogTrigger>
            <AlertDialogContent>
              <AlertDialogHeader>
                <AlertDialogTitle>Eliminare la lista?</AlertDialogTitle>
                <AlertDialogDescription>
                  «{list.name}» verrà eliminata. I task che le appartengono restano, senza lista.
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel>Annulla</AlertDialogCancel>
                <AlertDialogAction onClick={() => deleteList.mutate(list.id)}>
                  Elimina
                </AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialog>
        </div>
      ))}

      <ListEditorDialog
        trigger={
          <Button variant="ghost" className="text-muted-foreground w-full justify-start gap-2 px-3">
            <Plus className="size-4" aria-hidden />
            Nuova lista
          </Button>
        }
        title="Nuova lista"
        label="Nome della lista"
        maxLength={100}
        submitLabel="Crea"
        onSubmit={(values) => createList.mutateAsync(values)}
      />
    </div>
  )
}
