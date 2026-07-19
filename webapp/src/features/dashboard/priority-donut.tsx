import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip } from 'recharts'
import type { AnalyticsSummary, TaskPriority } from '@/api/types'
import { useChartColors } from '@/features/dashboard/chart-colors'
import { priorityLabels } from '@/features/tasks/labels'

const order: TaskPriority[] = ['LOW', 'MEDIUM', 'HIGH']

/**
 * Ripartizione dei task per priorità: tre fette, parte-sul-tutto, colpo
 * d'occhio. La legenda a fianco riporta etichetta e valore, così l'identità
 * non è affidata al solo colore.
 */
export function PriorityDonut({ summary }: { summary: AnalyticsSummary }) {
  const colors = useChartColors()
  const data = order.map((priority) => ({
    priority,
    label: priorityLabels[priority],
    value: summary.byPriority[priority] ?? 0,
  }))
  const total = data.reduce((sum, slice) => sum + slice.value, 0)

  if (total === 0) {
    return (
      <p className="text-muted-foreground py-8 text-center text-sm">Nessun task da ripartire.</p>
    )
  }

  return (
    <div className="flex flex-wrap items-center gap-6">
      <div className="h-44 w-44">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={data}
              dataKey="value"
              nameKey="label"
              innerRadius={44}
              outerRadius={70}
              paddingAngle={2}
              strokeWidth={2}
              stroke={colors.surface}
            >
              {data.map((slice) => (
                <Cell key={slice.priority} fill={colors.priority[slice.priority]} />
              ))}
            </Pie>
            <Tooltip
              contentStyle={{
                backgroundColor: colors.surface,
                border: `1px solid ${colors.grid}`,
                borderRadius: 12,
                color: colors.axis,
              }}
              formatter={(value, name) => [String(value), String(name)]}
            />
          </PieChart>
        </ResponsiveContainer>
      </div>

      <ul className="space-y-2 text-sm">
        {data.map((slice) => (
          <li key={slice.priority} className="flex items-center gap-2">
            <span
              className="size-3 rounded-full"
              style={{ backgroundColor: colors.priority[slice.priority] }}
              aria-hidden
            />
            <span>
              {slice.label} — {slice.value} ({Math.round((slice.value / total) * 100)}%)
            </span>
          </li>
        ))}
      </ul>
    </div>
  )
}
