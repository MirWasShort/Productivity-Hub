import { Link } from 'react-router'
import { Button } from '@/components/ui/button'

export default function NotFoundPage() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-4 p-6 text-center">
      <h1 className="text-2xl font-semibold">Pagina non trovata</h1>
      <p className="text-muted-foreground text-sm">
        L&apos;indirizzo che hai aperto non esiste (più).
      </p>
      <Button asChild>
        <Link to="/tasks">Torna ai task</Link>
      </Button>
    </div>
  )
}
