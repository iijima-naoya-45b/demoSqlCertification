import { apiGet } from '../../../lib/api-client'
import { productPageSchema, type ProductPage } from './schemas'

export type ProductQuery = {
  categoryName?: string
  keyword?: string
  inStockOnly?: boolean
  page?: number
  pageSize?: number
}

export async function getProducts(query: ProductQuery = {}): Promise<ProductPage> {
  return apiGet('/api/products', productPageSchema, {
    params: {
      categoryName: query.categoryName,
      keyword: query.keyword,
      inStockOnly: query.inStockOnly,
      page: query.page ?? 1,
      pageSize: query.pageSize ?? 20,
    },
  })
}
