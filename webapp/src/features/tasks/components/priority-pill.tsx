import type { TaskPriority } from '@/api/types'
import { cn } from '@/lib/utils'

/** Etichette e colori della pillola priorità, gemelli di `PriorityColors`. */
const priorityStyles: Record<TaskPriority, { label: string; className: string }> = {
  LOW: { label: 'BASSA', className: 'bg-priority-low text-priority-low-foreground' },
  MEDIUM: { label: 'MEDIA', className: 'bg-priority-medium text-priority-medium-foreground' },
  HIGH: { label: 'ALTA', className: 'bg-priority-high text-priority-high-foreground' },
}

export function PriorityPill({ priority }: { priority: TaskPriority }) {
  const { label, className } = priorityStyles[priority]

  return (
    <span className={cn('rounded-sm px-2 py-0.5 text-xs font-semibold', className)}>{label}</span>
  )
}
