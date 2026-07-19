import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { RouterProvider } from 'react-router'
import './index.css'
import { router } from '@/lib/router'
import { initTheme } from '@/lib/theme/theme-store'

// Prima del primo render: evita il lampo di tema sbagliato.
initTheme()

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <RouterProvider router={router} />
  </StrictMode>,
)
