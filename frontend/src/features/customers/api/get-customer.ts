import { apiGet } from '../../../lib/api-client'
import { customerDetailSchema, type CustomerDetail } from './schemas'

export async function getCustomer(customerId: number): Promise<CustomerDetail> {
  return apiGet(`/api/customers/${customerId}`, customerDetailSchema)
}
