import { useQuery } from '@tanstack/react-query'
import { useState } from 'react'
import { Badge } from '../../../components/ui/badge'
import { Card } from '../../../components/ui/card'
import { Input } from '../../../components/ui/input'
import { LoadingError } from '../../../components/ui/loading-error'
import { Pagination } from '../../../components/ui/pagination'
import { formatCurrency } from '../../../lib/format'
import { getEmployees } from '../api/get-employees'

export function StaffPage() {
  const [page, setPage] = useState(1)
  const [departmentName, setDepartmentName] = useState('')
  const [activeOnly, setActiveOnly] = useState(true)

  const { data, isLoading, error } = useQuery({
    queryKey: ['employees', page, departmentName, activeOnly],
    queryFn: () => getEmployees({ page, departmentName, activeOnly }),
  })

  return (
    <div className="space-y-4">
      <Card>
        <h2 className="mb-1 text-2xl font-bold text-slate-900">スタッフ管理</h2>
        <p className="mb-4 text-sm text-slate-500">DemoShop を支える社内スタッフの一覧です。</p>
        <div className="grid gap-3 md:grid-cols-2">
          <Input
            placeholder="部署名で検索"
            value={departmentName}
            onChange={(event) => { setPage(1); setDepartmentName(event.target.value) }}
          />
          <label className="flex items-center gap-2 rounded-lg border border-slate-300 px-3 py-2 text-sm">
            <input
              type="checkbox"
              checked={activeOnly}
              onChange={(event) => { setPage(1); setActiveOnly(event.target.checked) }}
            />
            在籍中のみ
          </label>
        </div>
      </Card>

      <LoadingError loading={isLoading} error={error} />

      {data && (
        <>
          <div className="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
            <table className="min-w-full text-left text-sm">
              <thead className="border-b border-slate-200 bg-slate-50 text-slate-500">
                <tr>
                  <th className="px-4 py-3 font-medium">ID</th>
                  <th className="px-4 py-3 font-medium">氏名</th>
                  <th className="px-4 py-3 font-medium">部署</th>
                  <th className="px-4 py-3 font-medium">役職</th>
                  <th className="px-4 py-3 font-medium">状態</th>
                  <th className="px-4 py-3 font-medium">給与</th>
                </tr>
              </thead>
              <tbody>
                {data.items.map((employee) => (
                  <tr key={employee.employeeId} className="border-b border-slate-100 hover:bg-slate-50">
                    <td className="px-4 py-3">{employee.employeeId}</td>
                    <td className="px-4 py-3">{employee.employeeName}</td>
                    <td className="px-4 py-3">{employee.departmentName}</td>
                    <td className="px-4 py-3">{employee.jobTitle}</td>
                    <td className="px-4 py-3">
                      <Badge variant={employee.isActive ? 'success' : 'default'}>
                        {employee.isActive ? '在籍' : '退職'}
                      </Badge>
                    </td>
                    <td className="px-4 py-3">{formatCurrency(employee.salary)}</td>
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
