import { AlertTriangle, CalendarClock, CheckCircle2, ListTodo, RefreshCw } from 'lucide-react'
import { useMemo } from 'react'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import { PriorityDonut } from '@/features/dashboard/priority-donut'
import { useAnalyticsSummary, useCompletions } from '@/features/dashboard/queries'
import { StatCard } from '@/features/dashboard/stat-card'
import { WeeklyBarChart } from '@/features/dashboard/weekly-bar-chart'
import { weeklyBuckets } from '@/features/dashboard/weekly-completions'

export default function DashboardPage() {
  const summary = useAnalyticsSummary()
  const completions = useCompletions()

  const buckets = useMemo(
    () => weeklyBuckets(completions.data?.days ?? [], new Date()),
    [completions.data],
  )

  const isPending = summary.isPending || completions.isPending
  const isError = summary.isError || completions.isError

  return (
    <div className="mx-auto max-w-3xl space-y-6 p-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Dashboard</h1>
        <Button
          variant="ghost"
          size="sm"
          onClick={() => {
            void summary.refetch()
            void completions.refetch()
          }}
        >
          <RefreshCw aria-hidden />
          Aggiorna
        </Button>
      </div>

      {isError && (
        <p role="alert" className="text-destructive text-sm">
          Non riesco a caricare le statistiche. Riprova.
        </p>
      )}

      {isPending ? (
        <div className="grid gap-3 sm:grid-cols-2">
          <Skeleton className="h-24 rounded-lg" />
          <Skeleton className="h-24 rounded-lg" />
          <Skeleton className="h-24 rounded-lg" />
          <Skeleton className="h-24 rounded-lg" />
        </div>
      ) : (
        summary.data && (
          <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
            <StatCard icon={ListTodo} label="Totali" value={summary.data.total} />
            <StatCard icon={CheckCircle2} label="Completati" value={summary.data.completed} />
            <StatCard
              icon={AlertTriangle}
              label="In ritardo"
              value={summary.data.overdue}
              tone="alert"
            />
            <StatCard icon={CalendarClock} label="Oggi" value={summary.data.dueToday} />
          </div>
        )
      )}

      <section className="bg-card space-y-3 rounded-lg border p-4">
        <h2 className="font-medium">Completati per settimana</h2>
        {completions.isPending ? (
          <Skeleton className="h-56" />
        ) : (
          <WeeklyBarChart buckets={buckets} />
        )}
      </section>

      <section className="bg-card space-y-3 rounded-lg border p-4">
        <h2 className="font-medium">Task per priorità</h2>
        {summary.isPending ? (
          <Skeleton className="h-44" />
        ) : (
          summary.data && <PriorityDonut summary={summary.data} />
        )}
      </section>
    </div>
  )
}
