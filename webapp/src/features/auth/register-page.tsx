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
import { register } from '@/features/auth/auth-api'
import { AuthFormLayout } from '@/features/auth/auth-form-layout'
import { registerSchema, type RegisterValues } from '@/features/auth/schemas'
import { ApiError } from '@/lib/api/errors'
import { useAuthStore } from '@/lib/auth/auth-store'

export default function RegisterPage() {
  const signIn = useAuthStore((state) => state.signIn)
  const [formError, setFormError] = useState<string | null>(null)

  const form = useForm<RegisterValues>({
    resolver: zodResolver(registerSchema),
    defaultValues: { displayName: '', email: '', password: '', confirmPassword: '' },
  })

  async function onSubmit({ displayName, email, password }: RegisterValues) {
    setFormError(null)
    try {
      // Come nel login, il redirect lo fa il guard.
      signIn(await register({ displayName, email, password }))
    } catch (error) {
      if (error instanceof ApiError) {
        // Il backend risponde 409 quando l'email è già in uso: l'errore
        // riguarda un campo preciso, quindi va mostrato lì e non in fondo.
        if (error.isConflict) {
          form.setError('email', { message: error.message })
          return
        }
        for (const [field, message] of Object.entries(error.fieldErrors ?? {})) {
          if (field in form.getValues()) {
            form.setError(field as keyof RegisterValues, { message })
          }
        }
        setFormError(error.fieldErrors ? null : error.message)
        return
      }
      setFormError('Impossibile completare la registrazione. Riprova.')
    }
  }

  return (
    <AuthFormLayout
      title="Crea un account"
      description="Bastano un nome, un'email e una password."
      footer={
        <>
          Hai già un account?{' '}
          <Link to="/login" className="text-primary font-medium hover:underline">
            Accedi
          </Link>
        </>
      }
    >
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4" noValidate>
          <FormField
            control={form.control}
            name="displayName"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Nome</FormLabel>
                <FormControl>
                  <Input autoComplete="name" autoFocus {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="email"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Email</FormLabel>
                <FormControl>
                  <Input type="email" autoComplete="email" {...field} />
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
                  <Input type="password" autoComplete="new-password" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="confirmPassword"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Conferma password</FormLabel>
                <FormControl>
                  <Input type="password" autoComplete="new-password" {...field} />
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
            {form.formState.isSubmitting ? 'Creazione in corso…' : 'Crea account'}
          </Button>
        </form>
      </Form>
    </AuthFormLayout>
  )
}
