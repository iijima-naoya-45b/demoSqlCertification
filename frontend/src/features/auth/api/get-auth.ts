import { apiGet } from '../../../lib/api-client'
import { authConfigSchema, authUserSchema, type AuthConfig, type AuthUser } from './schemas'

export async function getCurrentUser(): Promise<AuthUser> {
  return apiGet('/api/auth/me', authUserSchema)
}

export async function getAuthConfig(): Promise<AuthConfig> {
  return apiGet('/api/auth/config', authConfigSchema)
}
