import { apiGet } from '../../../lib/api-client'
import { customerPageSchema, type CustomerPage } from './schemas'

export type CustomerQuery = {
  prefecture?: string
  membershipTier?: string
  keyword?: string
  page?: number
  pageSize?: number
}

export async function getCustomers(query: CustomerQuery = {}): Promise<CustomerPage> {
  return apiGet('/api/customers', customerPageSchema, {
    params: {
      prefecture: query.prefecture,
      membershipTier: query.membershipTier,
      keyword: query.keyword,
      page: query.page ?? 1,
      pageSize: query.pageSize ?? 20,
    },
  })
}
