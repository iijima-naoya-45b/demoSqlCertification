import { Link, useParams } from 'react-router-dom'
import { Badge } from '../../../components/ui/badge'
import { Button } from '../../../components/ui/button'
import { Card } from '../../../components/ui/card'
import { getExerciseById } from '../content/exercises'
import { getSectionById } from '../content/curriculum'
import type { SkillLevel } from '../content/types'

export function SectionPage() {
  const { sectionId } = useParams<{ sectionId: SkillLevel }>()
  const section = sectionId ? getSectionById(sectionId) : undefined

  if (!section) {
    return (
      <Card className="p-6">
        <p className="text-sm text-slate-600">セクションが見つかりません。</p>
        <Link to="/learn" className="mt-4 inline-block text-sm text-indigo-600 hover:underline">
          学習ガイドトップへ
        </Link>
      </Card>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <Link to="/learn" className="text-sm text-indigo-600 hover:underline">
          ← 学習ガイドトップ
        </Link>
        <div className="mt-3 flex flex-wrap items-center gap-3">
          <h2 className="text-2xl font-bold text-slate-900">{section.title}</h2>
          <Badge>{section.difficultyLabel}</Badge>
        </div>
        <p className="mt-2 text-sm text-slate-600">{section.description}</p>
      </div>

      <section>
        <h3 className="mb-3 text-lg font-semibold text-slate-900">解説記事</h3>
        <div className="grid gap-3">
          {section.guides.map((guide) => (
            <Link
              key={guide.articleId}
              to={`/learn/${section.sectionId}/${guide.articleId}`}
              className="rounded-xl border border-slate-200 bg-white p-4 transition hover:border-indigo-300 hover:bg-indigo-50/40"
            >
              <div className="flex flex-wrap items-center gap-2">
                <h4 className="font-semibold text-slate-900">{guide.title}</h4>
                {guide.isRequired && (
                  <span className="rounded-full bg-emerald-100 px-2 py-0.5 text-xs font-medium text-emerald-800">
                    必読
                  </span>
                )}
                <span className="text-xs text-slate-400">約{guide.readTimeMinutes}分</span>
              </div>
              <p className="mt-1 text-sm text-slate-600">{guide.summary}</p>
            </Link>
          ))}
        </div>
      </section>

      {section.exerciseIds.length > 0 && (
        <section>
          <h3 className="mb-3 text-lg font-semibold text-slate-900">対応する演習</h3>
          <div className="grid gap-3 md:grid-cols-2">
            {section.exerciseIds.map((exerciseId) => {
              const exercise = getExerciseById(exerciseId)
              if (!exercise) return null
              return (
                <Card key={exerciseId} className="p-4">
                  <p className="text-xs text-slate-500">演習 {exercise.exerciseId}</p>
                  <h4 className="font-semibold text-slate-900">{exercise.title}</h4>
                  <p className="mt-1 text-sm text-slate-600">{exercise.description}</p>
                  <p className="mt-2 text-xs text-slate-500">{exercise.questions.length} 問</p>
                  <Link
                    to={`/sandbox?exercise=${exercise.exerciseId}`}
                    className="mt-3 inline-block"
                  >
                    <Button variant="secondary">サンドボックスで挑戦</Button>
                  </Link>
                </Card>
              )
            })}
          </div>
        </section>
      )}
    </div>
  )
}
