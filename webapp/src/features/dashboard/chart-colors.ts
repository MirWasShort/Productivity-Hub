import tokens from '../../../../tokens/tokens.json'
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
const ramp = tokens.chartPriorityRamp
const priorityRamps = {
  light: { LOW: ramp.light.low, MEDIUM: ramp.light.medium, HIGH: ramp.light.high },
  dark: { LOW: ramp.dark.low, MEDIUM: ramp.dark.medium, HIGH: ramp.dark.high },
} as const

const { light, dark } = tokens.scheme
const seriesColors = { light: light.primary, dark: dark.primary } as const
const axisColors = { light: light.mutedForeground, dark: dark.mutedForeground } as const
const gridColors = { light: light.input, dark: dark.input } as const
const surfaceColors = { light: light.card, dark: dark.card } as const

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
