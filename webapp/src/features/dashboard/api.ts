import type { AnalyticsSummary, Completions } from '@/api/types'
import { apiFetch } from '@/lib/api/client'

/** Sei settimane di storico: quanto serve al grafico settimanale. */
export const COMPLETIONS_DAYS = 42

export function fetchSummary(): Promise<AnalyticsSummary> {
  return apiFetch<AnalyticsSummary>('/analytics/summary')
}

export function fetchCompletions(): Promise<Completions> {
  return apiFetch<Completions>('/analytics/completions', { params: { days: COMPLETIONS_DAYS } })
}
