import { useEffect } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { Button } from '../../../components/ui/button'
import { Card } from '../../../components/ui/card'
import { useAuth } from './auth-provider'

export function LoginPage() {
  const { isAuthenticated, isLoading, login, loginWithGoogle, googleLoginEnabled } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const redirectPath = (location.state as { from?: string } | null)?.from ?? '/'

  useEffect(() => {
    if (!isLoading && isAuthenticated) {
      navigate(redirectPath, { replace: true })
    }
  }, [isAuthenticated, isLoading, navigate, redirectPath])

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 px-4">
      <Card className="w-full max-w-md p-8">
        <p className="text-xs font-semibold uppercase tracking-widest text-indigo-600">
          DemoShop SQL Practice
        </p>
        <h1 className="mt-2 text-2xl font-bold text-slate-900">ログイン</h1>
        <p className="mt-2 text-sm text-slate-600">
          Keycloak（OIDC）で認証します。セッションは HttpOnly Cookie（SameSite=Lax）で管理されます。
          {googleLoginEnabled && ' Google アカウントでもログインできます。'}
        </p>

        <div className="mt-6 space-y-3 rounded-lg bg-slate-50 p-4 text-sm text-slate-600">
          <p>
            <span className="font-medium text-slate-800">学習ユーザー:</span> demo / demopass
          </p>
          <p>
            <span className="font-medium text-slate-800">管理者:</span> admin / adminpass
          </p>
        </div>

        <div className="mt-6 space-y-3">
          {googleLoginEnabled && (
            <Button className="w-full" variant="secondary" onClick={loginWithGoogle}>
              Google でログイン
            </Button>
          )}
          <Button className="w-full" onClick={login}>
            Keycloak でログイン
          </Button>
        </div>

        {googleLoginEnabled && (
          <p className="mt-4 text-xs text-slate-500">
            「Keycloak でログイン」からも Google ボタンで同じアカウント連携が利用できます。
          </p>
        )}
      </Card>
    </div>
  )
}
