import { apiGet } from '../../../lib/api-client'
import { orderPageSchema, type OrderPage } from './schemas'

export type OrderQuery = {
  status?: string
  customerId?: number
  page?: number
  pageSize?: number
}

export async function getOrders(query: OrderQuery = {}): Promise<OrderPage> {
  return apiGet('/api/orders', orderPageSchema, {
    params: {
      status: query.status,
      customerId: query.customerId,
      page: query.page ?? 1,
      pageSize: query.pageSize ?? 20,
    },
  })
}
