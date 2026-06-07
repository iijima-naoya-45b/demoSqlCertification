import { NavLink } from 'react-router-dom'
import { env } from '../../config/env'
import { useAuth } from '../../features/auth/components/auth-provider'
import { Button } from '../ui/button'

const navItems = [
  { to: '/learn', label: '学習ガイド' },
  { to: '/sandbox', label: 'SQL演習' },
  { to: '/', label: 'ダッシュボード' },
  { to: '/catalog', label: '商品カタログ' },
  { to: '/orders', label: '注文管理' },
  { to: '/customers', label: '会員' },
  { to: '/staff', label: 'スタッフ' },
]

export function ShopHeader() {
  const { user, logout } = useAuth()

  return (
    <header className="border-b border-slate-200 bg-white">
      <div className="mx-auto flex max-w-7xl items-center justify-between px-4 py-4">
        <div>
          <p className="text-xs font-semibold uppercase tracking-widest text-indigo-600">
            Sample E-Commerce
          </p>
          <h1 className="text-xl font-bold text-slate-900">{env.appName}</h1>
          <p className="text-sm text-slate-500">MyBatis + PostgreSQL デモ通販管理画面</p>
        </div>
        <div className="flex items-center gap-3">
          {user?.displayName && (
            <p className="text-sm text-slate-600">{user.displayName}</p>
          )}
          <Button variant="secondary" onClick={logout}>
            ログアウト
          </Button>
        </div>
      </div>
      <nav className="mx-auto max-w-7xl px-4 pb-3">
        <ul className="flex flex-wrap gap-2">
          {navItems.map((item) => (
            <li key={item.to}>
              <NavLink
                to={item.to}
                end={item.to === '/'}
                className={({ isActive }) =>
                  `rounded-lg px-3 py-1.5 text-sm font-medium transition-colors ${
                    isActive
                      ? 'bg-indigo-600 text-white'
                      : 'bg-slate-100 text-slate-700 hover:bg-slate-200'
                  }`
                }
              >
                {item.label}
              </NavLink>
            </li>
          ))}
        </ul>
      </nav>
    </header>
  )
}
