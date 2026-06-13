import { useQuery, useQueryClient } from '@tanstack/react-query'
import { createContext, useCallback, useContext, useMemo, type ReactNode } from 'react'
import { env } from '../../../config/env'
import { getAuthConfig, getCurrentUser } from '../api/get-auth'
import type { AuthUser } from '../api/schemas'

type AuthContextValue = {
  user: AuthUser | undefined
  isLoading: boolean
  isAuthenticated: boolean
  googleLoginEnabled: boolean
  login: () => void
  loginWithGoogle: () => void
  logout: () => void
  refreshUser: () => Promise<void>
}

const AuthContext = createContext<AuthContextValue | null>(null)

type AuthProviderProps = {
  children: ReactNode
}

export function AuthProvider({ children }: AuthProviderProps) {
  const queryClient = useQueryClient()

  const { data: authConfig } = useQuery({
    queryKey: ['auth', 'config'],
    queryFn: getAuthConfig,
    staleTime: Infinity,
  })

  const {
    data: user,
    isLoading,
    refetch,
  } = useQuery({
    queryKey: ['auth', 'me'],
    queryFn: getCurrentUser,
    retry: false,
  })

  const buildAuthRedirectUrl = useCallback((path: string) => {
    return path.startsWith('http') ? path : `${env.apiBaseUrl}${path}`
  }, [])

  const login = useCallback(() => {
    const loginPath = authConfig?.loginUrl ?? '/oauth2/authorization/keycloak'
    window.location.href = buildAuthRedirectUrl(loginPath)
  }, [authConfig, buildAuthRedirectUrl])

  const loginWithGoogle = useCallback(() => {
    const googleLoginPath =
      authConfig?.googleLoginUrl ?? '/oauth2/authorization/keycloak?idp=google'
    window.location.href = buildAuthRedirectUrl(googleLoginPath)
  }, [authConfig, buildAuthRedirectUrl])

  const logout = useCallback(() => {
    const logoutPath = authConfig?.logoutUrl ?? '/api/auth/logout'
    const logoutUrl = logoutPath.startsWith('http')
      ? logoutPath
      : `${env.apiBaseUrl}${logoutPath}`
    window.location.href = logoutUrl
  }, [authConfig])

  const refreshUser = useCallback(async () => {
    await queryClient.invalidateQueries({ queryKey: ['auth', 'me'] })
    await refetch()
  }, [queryClient, refetch])

  const value = useMemo<AuthContextValue>(
    () => ({
      user,
      isLoading,
      isAuthenticated: user?.authenticated === true,
      googleLoginEnabled: authConfig?.googleLoginEnabled === true,
      login,
      loginWithGoogle,
      logout,
      refreshUser,
    }),
    [user, isLoading, authConfig, login, loginWithGoogle, logout, refreshUser],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth: AuthProvider の外で呼び出されました')
  }
  return context
}
