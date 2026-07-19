import { useQuery } from '@tanstack/react-query'
import { fetchCompletions, fetchSummary } from '@/features/dashboard/api'

export const analyticsKeys = {
  all: ['analytics'] as const,
  summary: () => ['analytics', 'summary'] as const,
  completions: () => ['analytics', 'completions'] as const,
}

export function useAnalyticsSummary() {
  return useQuery({ queryKey: analyticsKeys.summary(), queryFn: fetchSummary })
}

export function useCompletions() {
  return useQuery({ queryKey: analyticsKeys.completions(), queryFn: fetchCompletions })
}
