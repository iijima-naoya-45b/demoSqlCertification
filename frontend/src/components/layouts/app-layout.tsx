import { Outlet } from 'react-router-dom'
import { ShopHeader } from './shop-header'

export function AppLayout() {
  return (
    <div className="min-h-screen bg-slate-50">
      <ShopHeader />
      <main className="mx-auto max-w-7xl px-4 py-6">
        <Outlet />
      </main>
    </div>
  )
}
