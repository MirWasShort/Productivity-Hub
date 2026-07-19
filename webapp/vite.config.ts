/// <reference types="vitest/config" />
import { fileURLToPath } from 'node:url'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  test: {
    environment: 'jsdom',
    // Origine reale invece di about:blank, così window.location è sensato.
    environmentOptions: { jsdom: { url: 'http://localhost:5173' } },
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
    css: false,
  },
})
