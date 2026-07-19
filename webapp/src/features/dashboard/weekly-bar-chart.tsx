import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'
import { useChartColors } from '@/features/dashboard/chart-colors'
import type { WeekBucket } from '@/features/dashboard/weekly-completions'

/**
 * Una sola serie: una sola tinta, nessuna legenda (il titolo dice cosa sono le
 * barre). Griglia e assi restano sullo sfondo — i dati devono essere la cosa
 * più marcata del riquadro.
 */
export function WeeklyBarChart({ buckets }: { buckets: WeekBucket[] }) {
  const colors = useChartColors()

  return (
    <div className="h-56 w-full">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={buckets} margin={{ top: 8, right: 8, bottom: 0, left: -20 }}>
          <CartesianGrid stroke={colors.grid} vertical={false} />
          <XAxis
            dataKey="label"
            tick={{ fill: colors.axis, fontSize: 12 }}
            tickLine={false}
            axisLine={false}
          />
          <YAxis
            allowDecimals={false}
            tick={{ fill: colors.axis, fontSize: 12 }}
            tickLine={false}
            axisLine={false}
            width={40}
          />
          <Tooltip
            cursor={{ fill: colors.grid, fillOpacity: 0.4 }}
            contentStyle={{
              backgroundColor: colors.surface,
              border: `1px solid ${colors.grid}`,
              borderRadius: 12,
              color: colors.axis,
            }}
            labelFormatter={(label) => `Settimana del ${String(label)}`}
            formatter={(value) => [String(value), 'Completati']}
          />
          {/* Barre sottili con l'estremo arrotondato di 4px, ancorate alla base. */}
          <Bar dataKey="count" fill={colors.series} radius={[4, 4, 0, 0]} maxBarSize={28} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}
