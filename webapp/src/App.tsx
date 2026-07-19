import { ThemeToggle } from '@/components/theme-toggle'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

const priorities = [
  { label: 'BASSA', className: 'bg-priority-low text-priority-low-foreground' },
  { label: 'MEDIA', className: 'bg-priority-medium text-priority-medium-foreground' },
  { label: 'ALTA', className: 'bg-priority-high text-priority-high-foreground' },
]

export default function App() {
  return (
    <main className="mx-auto max-w-2xl p-6">
      <header className="mb-6 flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Smart TODO</h1>
        <ThemeToggle />
      </header>

      <Card className="rounded-lg border shadow-none">
        <CardHeader>
          <CardTitle>Design system</CardTitle>
        </CardHeader>
        <CardContent className="flex gap-2">
          {priorities.map((priority) => (
            <span
              key={priority.label}
              className={`rounded-sm px-2 py-1 text-xs font-semibold ${priority.className}`}
            >
              {priority.label}
            </span>
          ))}
        </CardContent>
      </Card>
    </main>
  )
}
