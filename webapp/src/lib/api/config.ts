/**
 * Host del backend, equivalente web del `--dart-define=API_BASE_URL` di
 * Flutter. Vive in un modulo suo perché lo usano sia il client sia il refresh,
 * che non possono importarsi a vicenda.
 */
export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8081'

export const API_PREFIX = '/api/v1'

export function apiUrl(path: string): URL {
  return new URL(`${API_PREFIX}${path}`, API_BASE_URL)
}
