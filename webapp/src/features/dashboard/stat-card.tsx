import type { ComponentType } from 'react'
import { cn } from '@/lib/utils'

/**
 * Un numero e la sua etichetta. Quando la storia è un numero solo, la forma
 * giusta non è un grafico: è il numero, scritto grande.
 */
export function StatCard({
  icon: Icon,
  label,
  value,
  tone = 'neutral',
}: {
  icon: ComponentType<{ className?: string; 'aria-hidden'?: boolean }>
  label: string
  value: number
  tone?: 'neutral' | 'alert'
}) {
  return (
    <div className="bg-card rounded-lg border p-4">
      <div className="text-muted-foreground flex items-center gap-2 text-sm">
        <Icon className="size-4" aria-hidden />
        {label}
      </div>
      <p className={cn('mt-2 text-3xl font-semibold', tone === 'alert' && 'text-destructive')}>
        {value}
      </p>
    </div>
  )
}
