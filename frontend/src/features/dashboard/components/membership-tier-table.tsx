import { Card } from '../../../components/ui/card'
import type { MembershipTierStat } from '../api/schemas'

type MembershipTierTableProps = {
  tierStats: MembershipTierStat[]
}

export function MembershipTierTable({ tierStats }: MembershipTierTableProps) {
  return (
    <Card>
      <h3 className="mb-4 text-lg font-semibold text-slate-900">会員ランク別会員数</h3>
      <div className="overflow-x-auto">
        <table className="min-w-full text-left text-sm">
          <thead className="border-b border-slate-200 text-slate-500">
            <tr>
              <th className="px-3 py-2 font-medium">ランク</th>
              <th className="px-3 py-2 font-medium">会員数</th>
            </tr>
          </thead>
          <tbody>
            {tierStats.map((tier) => (
              <tr key={tier.membershipTier} className="border-b border-slate-100">
                <td className="px-3 py-2 capitalize">{tier.membershipTier}</td>
                <td className="px-3 py-2">{tier.customerCount.toLocaleString('ja-JP')}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Card>
  )
}
