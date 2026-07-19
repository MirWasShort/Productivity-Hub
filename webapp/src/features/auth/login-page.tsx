import { zodResolver } from '@hookform/resolvers/zod'
import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { Link } from 'react-router'
import { Button } from '@/components/ui/button'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { login } from '@/features/auth/auth-api'
import { AuthFormLayout } from '@/features/auth/auth-form-layout'
import { loginSchema, type LoginValues } from '@/features/auth/schemas'
import { ApiError } from '@/lib/api/errors'
import { useAuthStore } from '@/lib/auth/auth-store'

export default function LoginPage() {
  const signIn = useAuthStore((state) => state.signIn)
  const [formError, setFormError] = useState<string | null>(null)

  const form = useForm<LoginValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: '', password: '' },
  })

  async function onSubmit(values: LoginValues) {
    setFormError(null)
    try {
      // Nessuna navigazione qui: appena la sessione esiste, RequireAnonymous
      // porta l'utente ai task o alla pagina che aveva chiesto.
      signIn(await login(values))
    } catch (error) {
      setFormError(error instanceof ApiError ? error.message : 'Impossibile accedere. Riprova.')
    }
  }

  return (
    <AuthFormLayout
      title="Accedi"
      description="Bentornato: riprendi da dove avevi lasciato."
      footer={
        <>
          Non hai un account?{' '}
          <Link to="/register" className="text-primary font-medium hover:underline">
            Registrati
          </Link>
        </>
      }
    >
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4" noValidate>
          <FormField
            control={form.control}
            name="email"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Email</FormLabel>
                <FormControl>
                  <Input type="email" autoComplete="email" autoFocus {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="password"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Password</FormLabel>
                <FormControl>
                  <Input type="password" autoComplete="current-password" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          {formError && (
            <p role="alert" className="text-destructive text-sm">
              {formError}
            </p>
          )}

          <Button type="submit" className="w-full" disabled={form.formState.isSubmitting}>
            {form.formState.isSubmitting ? 'Accesso in corso…' : 'Accedi'}
          </Button>
        </form>
      </Form>
    </AuthFormLayout>
  )
}
