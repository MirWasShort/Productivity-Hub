import { ChevronDown } from 'lucide-react'
import type { ComponentProps } from 'react'
import { cn } from '@/lib/utils'

/**
 * Elenco a discesa nativo, stilato come gli input del design system.
 *
 * Per scelte brevi e chiuse (stato, priorità, lista) il `<select>` del browser
 * batte una versione costruita a mano: è accessibile senza sforzo, sui telefoni
 * apre il selettore di sistema, funziona da tastiera e non ha bisogno di
 * portali. Il componente Select di Radix resta disponibile dove servono
 * contenuti ricchi nelle opzioni.
 */
export function NativeSelect({ className, children, ...props }: ComponentProps<'select'>) {
  return (
    <div className="relative">
      <select
        className={cn(
          'border-input bg-background h-9 w-full appearance-none rounded-md border px-3 py-1 pr-8 text-sm',
          'focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] focus-visible:outline-none',
          'disabled:cursor-not-allowed disabled:opacity-50',
          className,
        )}
        {...props}
      >
        {children}
      </select>
      <ChevronDown
        className="text-muted-foreground pointer-events-none absolute top-1/2 right-3 size-4 -translate-y-1/2"
        aria-hidden
      />
    </div>
  )
}
