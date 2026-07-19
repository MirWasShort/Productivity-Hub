import type { AuthResponse, LoginRequest, RegisterRequest } from '@/api/types'
import { apiFetch } from '@/lib/api/client'
import { sessionFromAuthResponse, type Session } from '@/lib/auth/token-storage'

export async function login(body: LoginRequest): Promise<Session> {
  return sessionFromAuthResponse(
    await apiFetch<AuthResponse>('/auth/login', { method: 'POST', body }),
  )
}

export async function register(body: RegisterRequest): Promise<Session> {
  return sessionFromAuthResponse(
    await apiFetch<AuthResponse>('/auth/register', { method: 'POST', body }),
  )
}
