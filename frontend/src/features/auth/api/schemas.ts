import { z } from 'zod'

export const authUserSchema = z.object({
  userId: z.string().nullable().optional(),
  username: z.string().nullable().optional(),
  email: z.string().nullable().optional(),
  displayName: z.string().nullable().optional(),
  roles: z.array(z.string()),
  authenticated: z.boolean(),
})

export const authConfigSchema = z.object({
  loginUrl: z.string(),
  logoutUrl: z.string(),
  googleLoginEnabled: z.boolean().default(false),
  googleLoginUrl: z.string().optional(),
})

export type AuthUser = z.infer<typeof authUserSchema>
export type AuthConfig = z.infer<typeof authConfigSchema>
