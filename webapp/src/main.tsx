import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from '@/App'
import { initTheme } from '@/lib/theme/theme-store'

// Prima del primo render: evita il lampo di tema sbagliato.
initTheme()

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
