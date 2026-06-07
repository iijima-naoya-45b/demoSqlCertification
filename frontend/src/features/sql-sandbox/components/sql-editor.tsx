import { Button } from '../../../components/ui/button'

type SqlEditorProps = {
  sql: string
  onSqlChange: (sql: string) => void
  onExecute: () => void
  isExecuting: boolean
}

export function SqlEditor({ sql, onSqlChange, onExecute, isExecuting }: SqlEditorProps) {
  return (
    <div className="flex h-full flex-col gap-3">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-semibold text-slate-700">SQL エディタ</h3>
        <p className="text-xs text-slate-400">SELECT / WITH / EXPLAIN のみ実行可能</p>
      </div>
      <textarea
        value={sql}
        onChange={(event) => onSqlChange(event.target.value)}
        spellCheck={false}
        className="min-h-[220px] flex-1 resize-y rounded-xl border border-slate-300 bg-slate-900 p-4 font-mono text-sm leading-relaxed text-emerald-300 outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100"
        placeholder="SELECT customerId, customerName FROM customers LIMIT 10;"
      />
      <div className="flex items-center justify-between">
        <p className="text-xs text-slate-500">
          DELETE / DROP / UPDATE / INSERT などは監査によりブロックされます
        </p>
        <Button onClick={onExecute} disabled={isExecuting || sql.trim().length === 0}>
          {isExecuting ? '実行中...' : '実行 (Ctrl+Enter)'}
        </Button>
      </div>
    </div>
  )
}
