import { useQuery } from '@tanstack/react-query'
import { useEffect, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { Badge } from '../../../components/ui/badge'
import { Card } from '../../../components/ui/card'
import { Input } from '../../../components/ui/input'
import { LoadingError } from '../../../components/ui/loading-error'
import { Pagination } from '../../../components/ui/pagination'
import { Select } from '../../../components/ui/select'
import { formatCurrency, formatDateTime } from '../../../lib/format'
import { getOrders } from '../api/get-orders'

function orderStatusVariant(status: string): 'default' | 'success' | 'warning' | 'danger' {
  if (status === 'delivered') return 'success'
  if (status === 'cancelled') return 'danger'
  if (status === 'pending') return 'warning'
  return 'default'
}

export function OrdersPage() {
  const [searchParams] = useSearchParams()
  const initialCustomerId = searchParams.get('customerId') ?? ''

  const [page, setPage] = useState(1)
  const [status, setStatus] = useState('')
  const [customerId, setCustomerId] = useState(initialCustomerId)

  useEffect(() => {
    setCustomerId(initialCustomerId)
    setPage(1)
  }, [initialCustomerId])

  const { data, isLoading, error } = useQuery({
    queryKey: ['orders', page, status, customerId],
    queryFn: () =>
      getOrders({
        page,
        status,
        customerId: customerId ? Number(customerId) : undefined,
      }),
  })

  return (
    <div className="space-y-4">
      <Card>
        <h2 className="mb-1 text-2xl font-bold text-slate-900">注文管理</h2>
        <p className="mb-4 text-sm text-slate-500">DemoShop の受注状況を確認できます。</p>
        <div className="grid gap-3 md:grid-cols-2">
          <Select value={status} onChange={(event) => { setPage(1); setStatus(event.target.value) }}>
            <option value="">全ステータス</option>
            <option value="pending">pending</option>
            <option value="confirmed">confirmed</option>
            <option value="shipped">shipped</option>
            <option value="delivered">delivered</option>
            <option value="cancelled">cancelled</option>
          </Select>
          <Input
            type="number"
            placeholder="会員 ID で絞り込み"
            value={customerId}
            onChange={(event) => { setPage(1); setCustomerId(event.target.value) }}
          />
        </div>
      </Card>

      <LoadingError loading={isLoading} error={error} />

      {data && (
        <>
          <div className="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
            <table className="min-w-full text-left text-sm">
              <thead className="border-b border-slate-200 bg-slate-50 text-slate-500">
                <tr>
                  <th className="px-4 py-3 font-medium">注文ID</th>
                  <th className="px-4 py-3 font-medium">会員</th>
                  <th className="px-4 py-3 font-medium">担当</th>
                  <th className="px-4 py-3 font-medium">日時</th>
                  <th className="px-4 py-3 font-medium">ステータス</th>
                  <th className="px-4 py-3 font-medium">合計</th>
                </tr>
              </thead>
              <tbody>
                {data.items.map((order) => (
                  <tr key={order.orderId} className="border-b border-slate-100 hover:bg-slate-50">
                    <td className="px-4 py-3 font-medium">{order.orderId}</td>
                    <td className="px-4 py-3">{order.customerName}</td>
                    <td className="px-4 py-3">{order.salesRepName ?? '-'}</td>
                    <td className="px-4 py-3">{formatDateTime(order.orderDate)}</td>
                    <td className="px-4 py-3">
                      <Badge variant={orderStatusVariant(order.status)}>{order.status}</Badge>
                    </td>
                    <td className="px-4 py-3">{formatCurrency(order.totalAmount)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <Pagination
            page={data.page}
            pageSize={data.pageSize}
            totalCount={data.totalCount}
            onPageChange={setPage}
          />
        </>
      )}
    </div>
  )
}
