import { Link } from 'react-router-dom'
import { Badge } from '../../../components/ui/badge'
import type { Customer } from '../api/schemas'

type CustomerTableProps = {
  customers: Customer[]
}

export function CustomerTable({ customers }: CustomerTableProps) {
  return (
    <div className="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
      <table className="min-w-full text-left text-sm">
        <thead className="border-b border-slate-200 bg-slate-50 text-slate-500">
          <tr>
            <th className="px-4 py-3 font-medium">ID</th>
            <th className="px-4 py-3 font-medium">会員名</th>
            <th className="px-4 py-3 font-medium">メール</th>
            <th className="px-4 py-3 font-medium">都道府県</th>
            <th className="px-4 py-3 font-medium">ランク</th>
            <th className="px-4 py-3 font-medium">登録日</th>
          </tr>
        </thead>
        <tbody>
          {customers.map((customer) => (
            <tr key={customer.customerId} className="border-b border-slate-100 hover:bg-slate-50">
              <td className="px-4 py-3">
                <Link
                  to={`/customers/${customer.customerId}`}
                  className="font-medium text-indigo-600 hover:underline"
                >
                  {customer.customerId}
                </Link>
              </td>
              <td className="px-4 py-3">{customer.customerName}</td>
              <td className="px-4 py-3">{customer.email}</td>
              <td className="px-4 py-3">{customer.prefecture ?? '-'}</td>
              <td className="px-4 py-3">
                <Badge>{customer.membershipTier}</Badge>
              </td>
              <td className="px-4 py-3">{customer.registeredAt}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
