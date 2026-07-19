import { resolveMode, useThemeStore } from '@/lib/theme/theme-store'

/**
 * Colori dei grafici, tenuti separati dai token dell'interfaccia.
 *
 * La priorità è una scala **ordinata** (Bassa < Media < Alta), quindi vuole una
 * rampa a una sola tinta con passi di luminosità crescenti: il lettore vede
 * l'ordine nel colore. Gli accenti delle pillole (verde/ambra/rosso) qui non
 * vanno bene — validati come palette da grafico, verde e ambra risultano quasi
 * indistinguibili sotto deuteranopia (ΔE 0.7) e persino a vista normale
 * (ΔE 12.8, sotto la soglia di 15).
 *
 * Le due rampe qui sotto passano tutti i controlli (monotonia, distacco fra i
 * passi, contrasto dell'estremo chiaro sulla superficie) sui rispettivi sfondi.
 */
const priorityRamps = {
  light: { LOW: '#A8A4F0', MEDIUM: '#6E6BB8', HIGH: '#424178' },
  dark: { LOW: '#4E4C8A', MEDIUM: '#8481D6', HIGH: '#C3C0FF' },
} as const

const seriesColors = { light: '#5A5892', dark: '#C3C0FF' } as const
const axisColors = { light: '#47464F', dark: '#C8C5D0' } as const
const gridColors = { light: '#E5E1E9', dark: '#35343A' } as const
const surfaceColors = { light: '#FFFFFF', dark: '#201F25' } as const

/** I colori del tema corrente: Recharts vuole valori, non classi CSS. */
export function useChartColors() {
  const mode = resolveMode(useThemeStore((state) => state.mode))
  return {
    priority: priorityRamps[mode],
    series: seriesColors[mode],
    axis: axisColors[mode],
    grid: gridColors[mode],
    surface: surfaceColors[mode],
  }
}
