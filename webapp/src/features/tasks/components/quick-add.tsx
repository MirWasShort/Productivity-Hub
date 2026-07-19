import { Plus, SlidersHorizontal } from 'lucide-react'
import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

/**
 * Aggiunta rapida: solo il titolo, priorità media e nessuna scadenza — come il
 * bottom sheet del client Flutter. Il pulsante accanto porta all'editor
 * completo, portandosi dietro il titolo già scritto.
 */
export function QuickAdd({
  onAdd,
  pending,
}: {
  onAdd: (title: string) => Promise<unknown>
  pending: boolean
}) {
  const [title, setTitle] = useState('')
  const navigate = useNavigate()
  const trimmed = title.trim()

  async function handleSubmit(event: FormEvent) {
    event.preventDefault()
    if (trimmed === '') {
      return
    }
    await onAdd(trimmed)
    setTitle('')
  }

  return (
    <form onSubmit={handleSubmit} className="flex gap-2">
      <Input
        value={title}
        onChange={(event) => setTitle(event.target.value)}
        placeholder="Aggiungi un task e premi Invio"
        aria-label="Nuovo task"
      />
      <Button type="submit" disabled={trimmed === '' || pending}>
        <Plus aria-hidden />
        Aggiungi
      </Button>
      <Button
        type="button"
        variant="outline"
        size="icon"
        aria-label="Apri l'editor completo"
        onClick={() =>
          void navigate(
            trimmed === '' ? '/tasks/new' : `/tasks/new?title=${encodeURIComponent(trimmed)}`,
          )
        }
      >
        <SlidersHorizontal aria-hidden />
      </Button>
    </form>
  )
}
