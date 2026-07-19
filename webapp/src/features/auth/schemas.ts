import { z } from 'zod'

/*
 * Le regole rispecchiano i vincoli del backend (`RegisterRequest`,
 * `LoginRequest`): password fra 8 e 100 caratteri, nome fino a 100. Validare
 * qui non sostituisce il server — evita solo un giro di rete per dirci quello
 * che sappiamo già.
 */

export const loginSchema = z.object({
  email: z.email('Inserisci un indirizzo email valido'),
  password: z.string().min(1, 'Inserisci la password'),
})

export type LoginValues = z.infer<typeof loginSchema>

export const registerSchema = z
  .object({
    displayName: z.string().trim().min(1, 'Inserisci il tuo nome').max(100, 'Nome troppo lungo'),
    email: z.email('Inserisci un indirizzo email valido'),
    password: z
      .string()
      .min(8, 'La password deve avere almeno 8 caratteri')
      .max(100, 'Password troppo lunga'),
    confirmPassword: z.string(),
  })
  .refine((values) => values.password === values.confirmPassword, {
    message: 'Le password non coincidono',
    path: ['confirmPassword'],
  })

export type RegisterValues = z.infer<typeof registerSchema>
