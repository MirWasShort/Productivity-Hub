import { Plus, Tags, Trash2 } from 'lucide-react'
import { useState } from 'react'
import { ArrowLeft } from 'lucide-react'
import { Link } from 'react-router'
import { EmptyState } from '@/components/layout/empty-state'
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
import { ListEditorDialog } from '@/features/lists/list-editor-dialog'
import { useCreateTag, useDeleteTag, useTags, useUpdateTag } from '@/features/tags/queries'
import { ApiError } from '@/lib/api/errors'
import { normalizeHex } from '@/lib/theme/list-colors'

export default function TagManagementPage() {
  const { data: tags, isPending } = useTags()
  const createTag = useCreateTag()
  const updateTag = useUpdateTag()
  const deleteTag = useDeleteTag()
  const [createError, setCreateError] = useState<string | null>(null)

  return (
    <div className="mx-auto max-w-2xl space-y-6 p-6">
      <div className="flex items-center gap-2">
        <Button asChild variant="ghost" size="icon" aria-label="Torna ai task">
          <Link to="/tasks">
            <ArrowLeft aria-hidden />
          </Link>
        </Button>
        <h1 className="flex-1 text-2xl font-semibold">Gestisci tag</h1>
        <ListEditorDialog
          trigger={
            <Button>
              <Plus aria-hidden />
              Nuovo tag
            </Button>
          }
          title="Nuovo tag"
          label="Nome del tag"
          maxLength={50}
          submitLabel="Crea"
          errorMessage={createError}
          onSubmit={async (values) => {
            setCreateError(null)
            try {
              await createTag.mutateAsync(values)
            } catch (error) {
              // 409: esiste già un tag con quel nome. Va detto qui, dove
              // l'utente sta scrivendo, non con un messaggio generico altrove.
              setCreateError(
                error instanceof ApiError && error.isConflict
                  ? 'Esiste già un tag con questo nome'
                  : 'Non riesco a creare il tag. Riprova.',
              )
              throw error
            }
          }}
        />
      </div>

      {isPending && (
        <div className="space-y-2">
          <Skeleton className="h-12 rounded-lg" />
          <Skeleton className="h-12 rounded-lg" />
        </div>
      )}

      {tags?.length === 0 && (
        <EmptyState
          icon={Tags}
          title="Nessun tag"
          description="I tag servono a marcare i task per contesto: casa, lavoro, urgente…"
        />
      )}

      <ul className="space-y-2">
        {tags?.map((tag) => (
          <li key={tag.id} className="bg-card flex items-center gap-3 rounded-lg border p-3">
            <span
              className="size-3 shrink-0 rounded-full"
              style={{ backgroundColor: normalizeHex(tag.color) }}
              aria-hidden
            />
            <span className="flex-1 truncate">{tag.name}</span>

            <ListEditorDialog
              trigger={
                <Button variant="ghost" size="sm" aria-label={`Rinomina "${tag.name}"`}>
                  Rinomina
                </Button>
              }
              title="Modifica tag"
              label="Nome del tag"
              maxLength={50}
              initialName={tag.name}
              initialColor={normalizeHex(tag.color)}
              submitLabel="Salva"
              onSubmit={(values) => updateTag.mutateAsync({ tagId: tag.id, body: values })}
            />

            <AlertDialog>
              <AlertDialogTrigger asChild>
                <Button
                  variant="ghost"
                  size="icon-sm"
                  aria-label={`Elimina "${tag.name}"`}
                  className="text-muted-foreground hover:text-destructive"
                >
                  <Trash2 aria-hidden />
                </Button>
              </AlertDialogTrigger>
              <AlertDialogContent>
                <AlertDialogHeader>
                  <AlertDialogTitle>Eliminare il tag?</AlertDialogTitle>
                  <AlertDialogDescription>
                    «{tag.name}» verrà rimosso da tutti i task che lo usano.
                  </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                  <AlertDialogCancel>Annulla</AlertDialogCancel>
                  <AlertDialogAction onClick={() => deleteTag.mutate(tag.id)}>
                    Elimina
                  </AlertDialogAction>
                </AlertDialogFooter>
              </AlertDialogContent>
            </AlertDialog>
          </li>
        ))}
      </ul>
    </div>
  )
}
