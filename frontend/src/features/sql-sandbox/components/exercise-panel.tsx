import { getExerciseById, getExerciseSummaries } from '../../learn/content/exercises'
import type { Exercise } from '../../learn/content/types'
import { Badge } from '../../../components/ui/badge'
import { Card } from '../../../components/ui/card'

const levelLabels: Record<Exercise['level'], string> = {
  start: 'はじめに',
  beginner: '初級',
  intermediate: '中級',
  advanced: '上級',
}

type ExercisePanelProps = {
  selectedExerciseId: string | null
  onSelectExercise: (exerciseId: string) => void
  onInsertHint: (hint: string) => void
}

export function ExercisePanel({
  selectedExerciseId,
  onSelectExercise,
  onInsertHint,
}: ExercisePanelProps) {
  const summaries = getExerciseSummaries()
  const selectedExercise = selectedExerciseId
    ? getExerciseById(selectedExerciseId)
    : undefined

  const grouped = {
    beginner: summaries.filter((s) => s.level === 'beginner'),
    intermediate: summaries.filter((s) => s.level === 'intermediate'),
    advanced: summaries.filter((s) => s.level === 'advanced'),
  }

  return (
    <div className="space-y-4">
      <Card className="p-4">
        <h2 className="text-lg font-bold text-slate-900">演習問題</h2>
        <p className="mt-1 text-sm text-slate-500">
          レベル別に問題を選んで SQL サンドボックスで挑戦できます。
        </p>
        {(['beginner', 'intermediate', 'advanced'] as const).map((level) => (
          <div key={level} className="mt-4">
            <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-500">
              {levelLabels[level]}
            </p>
            <ul className="space-y-2">
              {grouped[level].map((summary) => (
                <li key={summary.exerciseId}>
                  <button
                    type="button"
                    onClick={() => onSelectExercise(summary.exerciseId)}
                    className={`w-full rounded-lg border px-3 py-2 text-left text-sm transition ${
                      selectedExerciseId === summary.exerciseId
                        ? 'border-indigo-500 bg-indigo-50 text-indigo-900'
                        : 'border-slate-200 bg-white hover:bg-slate-50'
                    }`}
                  >
                    <span className="font-medium">
                      {summary.exerciseId}. {summary.title}
                    </span>
                    <span className="mt-1 block text-xs text-slate-500">
                      {summary.questionCount} 問
                    </span>
                  </button>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </Card>

      {selectedExercise && (
        <Card className="p-4">
          <div className="mb-3 flex items-center gap-2">
            <h3 className="font-semibold text-slate-900">{selectedExercise.title}</h3>
            <Badge>{levelLabels[selectedExercise.level]}</Badge>
          </div>
          <p className="mb-4 text-sm text-slate-600">{selectedExercise.description}</p>
          <ol className="space-y-3">
            {selectedExercise.questions.map((question) => (
              <li key={question.questionId} className="rounded-lg bg-slate-50 p-3 text-sm">
                <p className="font-medium text-slate-800">
                  {question.questionId}. {question.text}
                </p>
                {question.hint && (
                  <button
                    type="button"
                    onClick={() => onInsertHint(question.hint ?? '')}
                    className="mt-2 text-xs text-indigo-600 hover:underline"
                  >
                    ヒントSQLをエディタに挿入
                  </button>
                )}
              </li>
            ))}
          </ol>
        </Card>
      )}
    </div>
  )
}
