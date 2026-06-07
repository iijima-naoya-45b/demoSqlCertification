import { apiGet } from '../../../lib/api-client'
import { dashboardResponseSchema, type DashboardResponse } from './schemas'

export async function getDashboardStats(): Promise<DashboardResponse> {
  return apiGet('/api/dashboard/stats', dashboardResponseSchema)
}
