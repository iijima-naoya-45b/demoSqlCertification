import { useQuery } from '@tanstack/react-query'
import { Link, useParams } from 'react-router-dom'
import { Button } from '../../../components/ui/button'
import { Card } from '../../../components/ui/card'
import { LoadingError } from '../../../components/ui/loading-error'
import { Badge } from '../../../components/ui/badge'
import { formatCurrency } from '../../../lib/format'
import { getCustomer } from '../api/get-customer'

export function CustomerDetailPage() {
  const { customerId } = useParams()
  const parsedCustomerId = Number(customerId)

  const { data, isLoading, error } = useQuery({
    queryKey: ['customers', parsedCustomerId],
    queryFn: () => getCustomer(parsedCustomerId),
    enabled: Number.isFinite(parsedCustomerId),
  })

  if (isLoading || error) {
    return <LoadingError loading={isLoading} error={error} />
  }

  if (!data) {
    return null
  }

  return (
    <div className="space-y-4">
      <Link to="/customers" className="text-sm text-indigo-600 hover:underline">
        ← 会員一覧に戻る
      </Link>
      <Card>
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <h2 className="text-2xl font-bold text-slate-900">{data.customerName}</h2>
            <p className="mt-1 text-sm text-slate-500">会員 ID: {data.customerId}</p>
          </div>
          <Badge>{data.membershipTier}</Badge>
        </div>
        <dl className="mt-6 grid gap-4 sm:grid-cols-2">
          <div>
            <dt className="text-xs text-slate-500">メール</dt>
            <dd className="text-sm text-slate-900">{data.email}</dd>
          </div>
          <div>
            <dt className="text-xs text-slate-500">電話</dt>
            <dd className="text-sm text-slate-900">{data.phone ?? '-'}</dd>
          </div>
          <div>
            <dt className="text-xs text-slate-500">住所</dt>
            <dd className="text-sm text-slate-900">
              {data.prefecture ?? '-'} {data.city ?? ''}
            </dd>
          </div>
          <div>
            <dt className="text-xs text-slate-500">注文件数</dt>
            <dd className="text-sm text-slate-900">{data.orderCount.toLocaleString('ja-JP')}</dd>
          </div>
          <div>
            <dt className="text-xs text-slate-500">累計購入額</dt>
            <dd className="text-sm text-slate-900">{formatCurrency(data.totalPurchaseAmount)}</dd>
          </div>
          <div>
            <dt className="text-xs text-slate-500">平均注文額</dt>
            <dd className="text-sm text-slate-900">{formatCurrency(data.averageOrderAmount)}</dd>
          </div>
        </dl>
        <div className="mt-6">
          <Link to={`/orders?customerId=${data.customerId}`}>
            <Button>この会員の注文を見る</Button>
          </Link>
        </div>
      </Card>
    </div>
  )
}
