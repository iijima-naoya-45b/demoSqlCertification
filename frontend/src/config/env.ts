import { z } from 'zod'

const envSchema = z.object({
  apiBaseUrl: z.string().default(''),
  appName: z.string().default('DemoShop'),
})

export const env = envSchema.parse({
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL ?? '',
  appName: import.meta.env.VITE_APP_NAME ?? 'DemoShop',
})
