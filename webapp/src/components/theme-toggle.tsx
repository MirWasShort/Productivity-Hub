import { Moon, Sun } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { resolveMode, useThemeStore } from '@/lib/theme/theme-store'

/** Interruttore chiaro/scuro, gemello di quello nella AppBar del client Flutter. */
export function ThemeToggle() {
  const mode = useThemeStore((state) => state.mode)
  const toggle = useThemeStore((state) => state.toggle)
  const isDark = resolveMode(mode) === 'dark'

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={toggle}
      aria-label={isDark ? 'Passa al tema chiaro' : 'Passa al tema scuro'}
    >
      {isDark ? <Sun aria-hidden /> : <Moon aria-hidden />}
    </Button>
  )
}
