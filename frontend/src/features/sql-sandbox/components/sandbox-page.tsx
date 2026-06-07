import { useCallback, useEffect, useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { Card } from '../../../components/ui/card'
import { executeSql } from '../api/execute-sql'
import type { SqlBlockedError, SqlExecutionResult } from '../api/schemas'
import { ExercisePanel } from './exercise-panel'
import { SqlEditor } from './sql-editor'
import { SqlResultTable } from './sql-result-table'

export function SandboxPage() {
  const [searchParams] = useSearchParams()
  const initialExerciseId = searchParams.get('exercise')

  const [sql, setSql] = useState(
    'SELECT customerId, customerName, membershipTier\nFROM customers\nLIMIT 10;',
  )
  const [selectedExerciseId, setSelectedExerciseId] = useState<string | null>(
    initialExerciseId,
  )
  const [isExecuting, setIsExecuting] = useState(false)
  const [result, setResult] = useState<SqlExecutionResult | null>(null)
  const [blockedError, setBlockedError] = useState<SqlBlockedError | null>(null)
  const [errorMessage, setErrorMessage] = useState<string | null>(null)

  useEffect(() => {
    if (initialExerciseId) {
      setSelectedExerciseId(initialExerciseId)
    }
  }, [initialExerciseId])

  const handleExecute = useCallback(async () => {
    setIsExecuting(true)
    setResult(null)
    setBlockedError(null)
    setErrorMessage(null)

    try {
      const response = await executeSql({
        sql,
        exerciseId: selectedExerciseId ?? undefined,
      })

      if (response.type === 'success') {
        setResult(response.data)
      } else if (response.type === 'blocked') {
        setBlockedError(response.error)
      } else {
        setErrorMessage(response.message)
      }
    } catch (executeError) {
      setErrorMessage(
        executeError instanceof Error ? executeError.message : 'SQL実行中にエラーが発生しました',
      )
    } finally {
      setIsExecuting(false)
    }
  }, [sql, selectedExerciseId])

  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if ((event.ctrlKey || event.metaKey) && event.key === 'Enter') {
        event.preventDefault()
        handleExecute()
      }
    }
    window.addEventListener('keydown', onKeyDown)
    return () => window.removeEventListener('keydown', onKeyDown)
  }, [handleExecute])

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h2 className="text-2xl font-bold text-slate-900">SQL 演習サンドボックス</h2>
          <p className="mt-1 text-sm text-slate-500">
            DemoShop のデータベースに対して SQL を実行できます。危険な操作は auditLogs に記録のうえ拒否されます。
          </p>
        </div>
        <Link to="/learn" className="text-sm font-medium text-indigo-600 hover:underline">
          学習ガイドを見る →
        </Link>
      </div>

      <div className="grid gap-4 xl:grid-cols-[320px_1fr]">
        <ExercisePanel
          selectedExerciseId={selectedExerciseId}
          onSelectExercise={setSelectedExerciseId}
          onInsertHint={(hint) => setSql(hint)}
        />

        <div className="space-y-4">
          <Card className="min-h-[320px]">
            <SqlEditor
              sql={sql}
              onSqlChange={setSql}
              onExecute={handleExecute}
              isExecuting={isExecuting}
            />
          </Card>

          {blockedError && (
            <div className="rounded-xl border border-rose-200 bg-rose-50 p-4">
              <div className="mb-2 flex items-center gap-2">
                <span className="rounded-full bg-rose-200 px-2 py-0.5 text-xs font-semibold text-rose-800">
                  {blockedError.auditStatus}
                </span>
                <span className="text-xs text-rose-600">
                  検出キーワード: {blockedError.detectedKeyword}
                </span>
              </div>
              <p className="text-sm text-rose-800">{blockedError.message}</p>
            </div>
          )}

          {errorMessage && (
            <div className="rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-800">
              {errorMessage}
            </div>
          )}

          {result && <SqlResultTable result={result} />}
        </div>
      </div>
    </div>
  )
}
