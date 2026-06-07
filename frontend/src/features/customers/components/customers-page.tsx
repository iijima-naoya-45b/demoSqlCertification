import { useQuery } from '@tanstack/react-query'
import { useState } from 'react'
import { Card } from '../../../components/ui/card'
import { LoadingError } from '../../../components/ui/loading-error'
import { Pagination } from '../../../components/ui/pagination'
import { getCustomers } from '../api/get-customers'
import { CustomerFilters } from './customer-filters'
import { CustomerTable } from './customer-table'

export function CustomersPage() {
  const [page, setPage] = useState(1)
  const [keyword, setKeyword] = useState('')
  const [prefecture, setPrefecture] = useState('')
  const [membershipTier, setMembershipTier] = useState('')

  const { data, isLoading, error } = useQuery({
    queryKey: ['customers', page, keyword, prefecture, membershipTier],
    queryFn: () => getCustomers({ page, keyword, prefecture, membershipTier }),
  })

  return (
    <div className="space-y-4">
      <Card>
        <h2 className="mb-1 text-2xl font-bold text-slate-900">会員一覧</h2>
        <p className="mb-4 text-sm text-slate-500">DemoShop に登録された会員を検索・閲覧できます。</p>
        <CustomerFilters
          keyword={keyword}
          prefecture={prefecture}
          membershipTier={membershipTier}
          onKeywordChange={(value) => {
            setPage(1)
            setKeyword(value)
          }}
          onPrefectureChange={(value) => {
            setPage(1)
            setPrefecture(value)
          }}
          onMembershipTierChange={(value) => {
            setPage(1)
            setMembershipTier(value)
          }}
        />
      </Card>

      <LoadingError loading={isLoading} error={error} />

      {data && (
        <>
          <CustomerTable customers={data.items} />
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
