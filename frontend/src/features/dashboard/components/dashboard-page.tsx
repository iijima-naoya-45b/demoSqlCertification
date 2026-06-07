import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { Button } from '../../../components/ui/button'
import { Card } from '../../../components/ui/card'
import { StatCard } from '../../../components/ui/stat-card'
import { LoadingError } from '../../../components/ui/loading-error'
import { getRequiredGuides } from '../../learn/content/curriculum'
import { formatCurrency } from '../../../lib/format'
import { getDashboardStats } from '../api/get-dashboard-stats'
import { MembershipTierTable } from './membership-tier-table'

export function DashboardPage() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['dashboard', 'stats'],
    queryFn: getDashboardStats,
  })

  if (isLoading || error) {
    return <LoadingError loading={isLoading} error={error} />
  }

  if (!data) {
    return null
  }

  const { stats, membershipTierStats } = data
  const requiredGuides = getRequiredGuides()

  return (
    <div className="space-y-6">
      <Card className="border-emerald-200 bg-emerald-50 p-5">
        <h3 className="font-semibold text-emerald-900">SQL演習を始める</h3>
        <p className="mt-1 text-sm text-emerald-800">
          初めての方は「はじめに」({requiredGuides.length}本の必読ガイド) から読み始めてください。
        </p>
        <div className="mt-4 flex flex-wrap gap-3">
          <Link to="/learn">
            <Button>学習ガイドを開く</Button>
          </Link>
          <Link to="/sandbox">
            <Button variant="secondary">SQLサンドボックス</Button>
          </Link>
        </div>
      </Card>

      <section>
        <h2 className="mb-1 text-2xl font-bold text-slate-900">店舗サマリー</h2>
        <p className="mb-4 text-sm text-slate-500">DemoShop の売上・会員・在庫の概要です。</p>
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <StatCard label="会員数" value={stats.customerCount.toLocaleString('ja-JP')} />
          <StatCard label="注文数" value={stats.orderCount.toLocaleString('ja-JP')} />
          <StatCard label="商品数" value={stats.productCount.toLocaleString('ja-JP')} />
          <StatCard label="スタッフ数" value={stats.employeeCount.toLocaleString('ja-JP')} />
          <StatCard
            label="配送完了"
            value={stats.deliveredOrderCount.toLocaleString('ja-JP')}
          />
          <StatCard
            label="売上合計"
            value={formatCurrency(stats.totalRevenue)}
            subLabel="confirmed / shipped / delivered"
          />
        </div>
      </section>
      <MembershipTierTable tierStats={membershipTierStats} />
    </div>
  )
}
