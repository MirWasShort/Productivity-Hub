import { beforeEach, describe, expect, it, vi } from 'vitest'
import { readStoredMode, THEME_STORAGE_KEY, useThemeStore } from '@/lib/theme/theme-store'

/** Stub di matchMedia: jsdom non lo implementa. */
function stubPlatformDark(prefersDark: boolean) {
  vi.stubGlobal(
    'matchMedia',
    vi.fn((query: string) => ({
      matches: query.includes('dark') ? prefersDark : false,
      media: query,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
    })),
  )
}

describe('theme store', () => {
  beforeEach(() => {
    localStorage.clear()
    document.documentElement.classList.remove('dark')
    stubPlatformDark(false)
    useThemeStore.setState({ mode: 'system' })
  })

  it('parte da system quando non c è nulla di salvato', () => {
    expect(useThemeStore.getState().mode).toBe('system')
  })

  it('persiste la modalità scelta', () => {
    useThemeStore.getState().setMode('dark')

    expect(useThemeStore.getState().mode).toBe('dark')
    expect(localStorage.getItem(THEME_STORAGE_KEY)).toBe('dark')
  })

  it('applica la classe dark al documento quando la modalità è dark', () => {
    useThemeStore.getState().setMode('dark')
    expect(document.documentElement.classList.contains('dark')).toBe(true)

    useThemeStore.getState().setMode('light')
    expect(document.documentElement.classList.contains('dark')).toBe(false)
  })

  it('con system segue la preferenza di sistema', () => {
    stubPlatformDark(true)

    useThemeStore.getState().setMode('system')

    expect(document.documentElement.classList.contains('dark')).toBe(true)
  })

  it('toggle inverte light e dark', () => {
    useThemeStore.getState().setMode('light')
    useThemeStore.getState().toggle()
    expect(useThemeStore.getState().mode).toBe('dark')

    useThemeStore.getState().toggle()
    expect(useThemeStore.getState().mode).toBe('light')
  })

  it('toggle da system va all opposto della preferenza di sistema', () => {
    stubPlatformDark(true)
    useThemeStore.getState().setMode('system')

    useThemeStore.getState().toggle()

    expect(useThemeStore.getState().mode).toBe('light')
  })

  it('ignora un valore salvato non valido e torna a system', () => {
    localStorage.setItem(THEME_STORAGE_KEY, 'arcobaleno')

    expect(readStoredMode()).toBe('system')
  })
})
