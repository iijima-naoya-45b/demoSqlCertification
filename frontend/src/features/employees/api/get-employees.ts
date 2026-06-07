import { apiGet } from '../../../lib/api-client'
import { employeePageSchema, type EmployeePage } from './schemas'

export type EmployeeQuery = {
  departmentName?: string
  activeOnly?: boolean
  page?: number
  pageSize?: number
}

export async function getEmployees(query: EmployeeQuery = {}): Promise<EmployeePage> {
  return apiGet('/api/employees', employeePageSchema, {
    params: {
      departmentName: query.departmentName,
      activeOnly: query.activeOnly,
      page: query.page ?? 1,
      pageSize: query.pageSize ?? 20,
    },
  })
}
