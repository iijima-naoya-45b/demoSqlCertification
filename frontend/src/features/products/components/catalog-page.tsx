import { useQuery } from '@tanstack/react-query'
import { useState } from 'react'
import { Badge } from '../../../components/ui/badge'
import { Card } from '../../../components/ui/card'
import { Input } from '../../../components/ui/input'
import { LoadingError } from '../../../components/ui/loading-error'
import { Pagination } from '../../../components/ui/pagination'
import { formatCurrency } from '../../../lib/format'
import { getProducts } from '../api/get-products'

export function CatalogPage() {
  const [page, setPage] = useState(1)
  const [keyword, setKeyword] = useState('')
  const [categoryName, setCategoryName] = useState('')
  const [inStockOnly, setInStockOnly] = useState(false)

  const { data, isLoading, error } = useQuery({
    queryKey: ['products', page, keyword, categoryName, inStockOnly],
    queryFn: () => getProducts({ page, keyword, categoryName, inStockOnly }),
  })

  return (
    <div className="space-y-4">
      <Card>
        <h2 className="mb-1 text-2xl font-bold text-slate-900">商品カタログ</h2>
        <p className="mb-4 text-sm text-slate-500">DemoShop で取り扱う商品の一覧です。</p>
        <div className="grid gap-3 md:grid-cols-3">
          <Input
            placeholder="商品名で検索"
            value={keyword}
            onChange={(event) => { setPage(1); setKeyword(event.target.value) }}
          />
          <Input
            placeholder="カテゴリ名"
            value={categoryName}
            onChange={(event) => { setPage(1); setCategoryName(event.target.value) }}
          />
          <label className="flex items-center gap-2 rounded-lg border border-slate-300 px-3 py-2 text-sm">
            <input
              type="checkbox"
              checked={inStockOnly}
              onChange={(event) => { setPage(1); setInStockOnly(event.target.checked) }}
            />
            在庫ありのみ
          </label>
        </div>
      </Card>

      <LoadingError loading={isLoading} error={error} />

      {data && (
        <>
          <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
            {data.items.map((product) => (
              <Card key={product.productId}>
                <div className="flex items-start justify-between gap-2">
                  <div>
                    <p className="text-xs font-medium text-indigo-600">{product.categoryName}</p>
                    <h3 className="mt-1 font-semibold text-slate-900">{product.productName}</h3>
                  </div>
                  {product.isDiscontinued ? (
                    <Badge variant="danger">終売</Badge>
                  ) : product.stockQuantity > 0 ? (
                    <Badge variant="success">在庫あり</Badge>
                  ) : (
                    <Badge variant="warning">在庫切れ</Badge>
                  )}
                </div>
                <p className="mt-3 text-lg font-bold text-slate-900">
                  {formatCurrency(product.unitPrice)}
                </p>
                <dl className="mt-3 grid grid-cols-2 gap-2 text-sm text-slate-600">
                  <div>
                    <dt className="text-xs text-slate-400">ブランド</dt>
                    <dd>{product.brandName ?? '-'}</dd>
                  </div>
                  <div>
                    <dt className="text-xs text-slate-400">在庫</dt>
                    <dd>{product.stockQuantity}</dd>
                  </div>
                  <div>
                    <dt className="text-xs text-slate-400">評価</dt>
                    <dd>
                      {product.averageRating.toFixed(1)} ({product.reviewCount})
                    </dd>
                  </div>
                </dl>
              </Card>
            ))}
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
