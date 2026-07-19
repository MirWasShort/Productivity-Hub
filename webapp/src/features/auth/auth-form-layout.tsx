import type { ReactNode } from 'react'
import { Card, CardContent, CardDescription, CardHeader } from '@/components/ui/card'

/**
 * Cornice comune di login e registrazione: card centrata e stretta, come nel
 * client Flutter (`maxWidth: 400`), perché un form di due campi largo quanto
 * uno schermo desktop è solo faticoso da leggere.
 */
export function AuthFormLayout({
  title,
  description,
  children,
  footer,
}: {
  title: string
  description: string
  children: ReactNode
  footer: ReactNode
}) {
  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <Card className="w-full max-w-100 shadow-none">
        <CardHeader>
          {/* La card di shadcn rende il titolo come <div>: qui serve un <h1>,
              perché è l'intestazione della pagina. */}
          <h1 className="text-xl font-semibold">{title}</h1>
          <CardDescription>{description}</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {children}
          <p className="text-muted-foreground text-center text-sm">{footer}</p>
        </CardContent>
      </Card>
    </main>
  )
}
