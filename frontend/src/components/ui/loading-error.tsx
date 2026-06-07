type LoadingErrorProps = {
  loading: boolean
  error: Error | null
}

export function LoadingError({ loading, error }: LoadingErrorProps) {
  if (loading) {
    return (
      <div className="rounded-2xl border border-slate-200 bg-white p-10 text-center text-slate-500">
        読み込み中...
      </div>
    )
  }

  if (error) {
    return (
      <div className="rounded-2xl border border-rose-200 bg-rose-50 p-4 text-sm text-rose-700">
        {error.message}
      </div>
    )
  }

  return null
}
