import { create } from 'zustand'

/** Le tre modalità del client Flutter: chiaro, scuro, o "come il sistema". */
export type ThemeMode = 'light' | 'dark' | 'system'

export const THEME_STORAGE_KEY = 'ph.theme'

const DARK_QUERY = '(prefers-color-scheme: dark)'

/** True se il sistema operativo è impostato su tema scuro. */
export function prefersDark(): boolean {
  return typeof matchMedia === 'function' && matchMedia(DARK_QUERY).matches
}

/** Legge la modalità salvata, ignorando valori non riconosciuti. */
export function readStoredMode(): ThemeMode {
  const stored = localStorage.getItem(THEME_STORAGE_KEY)
  return stored === 'light' || stored === 'dark' ? stored : 'system'
}

/** Traduce la modalità nel tema effettivo da mostrare. */
export function resolveMode(mode: ThemeMode): 'light' | 'dark' {
  if (mode === 'system') {
    return prefersDark() ? 'dark' : 'light'
  }
  return mode
}

function applyMode(mode: ThemeMode) {
  document.documentElement.classList.toggle('dark', resolveMode(mode) === 'dark')
}

interface ThemeState {
  mode: ThemeMode
  setMode: (mode: ThemeMode) => void
  /** Inverte chiaro/scuro; da `system` va all'opposto del sistema, così il primo click ha sempre effetto. */
  toggle: () => void
}

export const useThemeStore = create<ThemeState>((set, get) => ({
  mode: readStoredMode(),
  setMode: (mode) => {
    localStorage.setItem(THEME_STORAGE_KEY, mode)
    applyMode(mode)
    set({ mode })
  },
  toggle: () => {
    get().setMode(resolveMode(get().mode) === 'dark' ? 'light' : 'dark')
  },
}))

/**
 * Applica il tema al primo caricamento e resta in ascolto del sistema
 * finché la modalità è `system`. Chiamata una volta all'avvio.
 */
export function initTheme() {
  applyMode(useThemeStore.getState().mode)

  if (typeof matchMedia !== 'function') {
    return
  }
  matchMedia(DARK_QUERY).addEventListener('change', () => {
    if (useThemeStore.getState().mode === 'system') {
      applyMode('system')
    }
  })
}
