import { Check } from 'lucide-react'
import { useState, type FormEvent, type ReactNode } from 'react'
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { FALLBACK_COLOR, listColorSwatches } from '@/lib/theme/list-colors'
import { cn } from '@/lib/utils'

/**
 * Dialogo condiviso da liste e tag: un nome e otto colori preimpostati.
 * Niente selettore libero — otto colori distinguibili valgono più di sedici
 * milioni indistinguibili, ed è la stessa scelta del client Flutter.
 */
export function ListEditorDialog({
  trigger,
  title,
  label,
  maxLength,
  initialName = '',
  // Il primo swatch è il colore di partenza; il ripiego serve solo a
  // soddisfare il tipo, la palette non è mai vuota.
  initialColor = listColorSwatches[0] ?? FALLBACK_COLOR,
  submitLabel,
  errorMessage,
  onSubmit,
}: {
  trigger: ReactNode
  title: string
  label: string
  maxLength: number
  initialName?: string
  initialColor?: string
  submitLabel: string
  errorMessage?: string | null
  onSubmit: (values: { name: string; color: string }) => Promise<unknown>
}) {
  const [open, setOpen] = useState(false)
  const [name, setName] = useState(initialName)
  const [color, setColor] = useState(initialColor)
  const trimmed = name.trim()

  async function handleSubmit(event: FormEvent) {
    event.preventDefault()
    if (trimmed === '') {
      return
    }
    try {
      await onSubmit({ name: trimmed, color })
    } catch {
      // Chi ci passa `onSubmit` mostra il messaggio in `errorMessage`: qui
      // basta non chiudere, così l'utente può correggere quello che ha scritto.
      return
    }
    setOpen(false)
    setName(initialName)
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        setOpen(next)
        if (next) {
          // Riapre sempre con i valori correnti, non con quelli lasciati a metà.
          setName(initialName)
          setColor(initialColor)
        }
      }}
    >
      <DialogTrigger asChild>{trigger}</DialogTrigger>
      <DialogContent>
        <form onSubmit={handleSubmit}>
          <DialogHeader>
            <DialogTitle>{title}</DialogTitle>
          </DialogHeader>

          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="editor-name">{label}</Label>
              <Input
                id="editor-name"
                value={name}
                maxLength={maxLength}
                onChange={(event) => setName(event.target.value)}
                autoFocus
              />
            </div>

            <fieldset className="space-y-2">
              <legend className="text-sm font-medium">Colore</legend>
              <div className="flex flex-wrap gap-2">
                {listColorSwatches.map((swatch) => (
                  <button
                    key={swatch}
                    type="button"
                    onClick={() => setColor(swatch)}
                    aria-label={`Colore ${swatch}`}
                    aria-pressed={color === swatch}
                    className={cn(
                      'flex size-8 items-center justify-center rounded-full transition-transform',
                      color === swatch && 'ring-ring scale-110 ring-2 ring-offset-2',
                    )}
                    style={{ backgroundColor: swatch }}
                  >
                    {color === swatch && <Check className="size-4 text-white" aria-hidden />}
                  </button>
                ))}
              </div>
            </fieldset>

            {errorMessage && (
              <p role="alert" className="text-destructive text-sm">
                {errorMessage}
              </p>
            )}
          </div>

          <DialogFooter>
            <Button type="submit" disabled={trimmed === ''}>
              {submitLabel}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
