import { useState } from 'react'
import { CalendarDays, ChartLine, CheckCircle2, LogOut, Menu } from 'lucide-react'
import { NavLink, Outlet } from 'react-router'
import { useAuthStore } from '@/lib/auth/auth-store'
import { ThemeToggle } from '@/components/theme-toggle'
import { Button } from '@/components/ui/button'
import { Sheet, SheetContent, SheetTitle, SheetTrigger } from '@/components/ui/sheet'
import { cn } from '@/lib/utils'

/** Le tre destinazioni della NavigationBar del client Flutter. */
const destinations = [
  { to: '/tasks', label: 'Task', icon: CheckCircle2 },
  { to: '/calendar', label: 'Calendario', icon: CalendarDays },
  { to: '/dashboard', label: 'Dashboard', icon: ChartLine },
]

function SidebarContent() {
  const signOut = useAuthStore((state) => state.signOut)

  return (
    <nav className="flex h-full flex-col gap-1 p-3">
      <p className="px-3 pt-2 pb-4 text-lg font-semibold">Smart TODO</p>
      {destinations.map(({ to, label, icon: Icon }) => (
        <NavLink
          key={to}
          to={to}
          className={({ isActive }) =>
            cn(
              'flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors',
              isActive
                ? 'bg-primary-container text-primary-container-foreground'
                : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground',
            )
          }
        >
          <Icon className="size-4" aria-hidden />
          {label}
        </NavLink>
      ))}
      {/* Liste e gestione tag arrivano con i rispettivi commit. */}
      <Button
        variant="ghost"
        className="text-muted-foreground mt-auto justify-start gap-3 px-3"
        onClick={signOut}
      >
        <LogOut className="size-4" aria-hidden />
        Esci
      </Button>
    </nav>
  )
}

/**
 * Guscio dell'app: barra laterale permanente da `lg` in su, a scomparsa sotto.
 * È l'equivalente web di AppShell + AppDrawer del client Flutter, fusi in uno
 * solo perché sul desktop c'è spazio per tenere la navigazione sempre visibile.
 */
export function AppShell() {
  const [drawerOpen, setDrawerOpen] = useState(false)

  return (
    <div className="flex min-h-screen">
      <aside className="hidden w-64 shrink-0 border-r lg:block">
        <SidebarContent />
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex h-14 items-center justify-between border-b px-4">
          <Sheet open={drawerOpen} onOpenChange={setDrawerOpen}>
            <SheetTrigger asChild>
              <Button variant="ghost" size="icon" className="lg:hidden" aria-label="Apri il menu">
                <Menu aria-hidden />
              </Button>
            </SheetTrigger>
            <SheetContent side="left" className="w-64 p-0">
              <SheetTitle className="sr-only">Navigazione</SheetTitle>
              <SidebarContent />
            </SheetContent>
          </Sheet>
          <div className="ml-auto">
            <ThemeToggle />
          </div>
        </header>

        <main className="min-w-0 flex-1">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
