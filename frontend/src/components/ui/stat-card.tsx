type StatCardProps = {
  label: string
  value: string
  subLabel?: string
}

export function StatCard({ label, value, subLabel }: StatCardProps) {
  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
      <p className="text-sm font-medium text-slate-500">{label}</p>
      <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900">{value}</p>
      {subLabel && <p className="mt-1 text-xs text-slate-400">{subLabel}</p>}
    </div>
  )
}
