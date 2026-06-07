import type { SqlExecutionResult } from '../api/schemas'

type SqlResultTableProps = {
  result: SqlExecutionResult
}

function formatCellValue(value: unknown): string {
  if (value === null || value === undefined) {
    return 'NULL'
  }
  if (typeof value === 'object') {
    return JSON.stringify(value)
  }
  return String(value)
}

export function SqlResultTable({ result }: SqlResultTableProps) {
  if (result.columns.length === 0) {
    return (
      <div className="rounded-xl border border-slate-200 bg-white p-6 text-sm text-slate-500">
        結果列がありません（EXPLAIN 結果などを確認してください）
      </div>
    )
  }

  return (
    <div className="space-y-2">
      <div className="flex flex-wrap gap-3 text-xs text-slate-500">
        <span className="rounded-full bg-emerald-100 px-2 py-0.5 font-medium text-emerald-800">
          {result.auditStatus}
        </span>
        <span>{result.rowCount} 行</span>
        <span>{result.executionTimeMs} ms</span>
        {result.truncated && <span className="text-amber-600">先頭500行のみ表示</span>}
      </div>
      {result.message && (
        <p className="text-xs text-amber-600">{result.message}</p>
      )}
      <div className="overflow-x-auto rounded-xl border border-slate-200 bg-white shadow-sm">
        <table className="min-w-full text-left text-sm">
          <thead className="border-b border-slate-200 bg-slate-50 text-slate-500">
            <tr>
              {result.columns.map((column) => (
                <th key={column} className="px-4 py-3 font-medium">
                  {column}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {result.rows.map((row, rowIndex) => (
              <tr key={rowIndex} className="border-b border-slate-100 hover:bg-slate-50">
                {row.map((cell, cellIndex) => (
                  <td key={cellIndex} className="max-w-xs truncate px-4 py-2 font-mono text-xs">
                    {formatCellValue(cell)}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
