import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { QueryClientProvider } from '@tanstack/react-query'
import { RouterProvider } from 'react-router'
import './index.css'
import { initAuth } from '@/lib/auth/auth-store'
import { queryClient } from '@/lib/query-client'
import { router } from '@/lib/router'
import { initTheme } from '@/lib/theme/theme-store'

// Prima del primo render: tema applicato (niente lampo) e sessione riletta
// dal disco (niente rimbalzo al login di chi era già dentro).
initTheme()
initAuth()

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
    </QueryClientProvider>
  </StrictMode>,
)
