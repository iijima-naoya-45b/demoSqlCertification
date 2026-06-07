import { Link } from 'react-router-dom'
import { Button } from '../../../components/ui/button'
import { Card } from '../../../components/ui/card'
import { getRequiredGuides, learnSections } from '../content/curriculum'
import { SectionCard } from './section-card'

export function LearnHomePage() {
  const requiredGuides = getRequiredGuides()
  const sortedSections = [...learnSections].sort((a, b) => a.order - b.order)

  return (
    <div className="space-y-8">
      <section>
        <h2 className="text-2xl font-bold text-slate-900">SQL 学習ガイド</h2>
        <p className="mt-2 max-w-3xl text-sm text-slate-600">
          初心者から上級者まで、段階的に学べるカリキュラムです。解説を読んでから SQL サンドボックスで演習しましょう。
        </p>
      </section>

      <Card className="border-emerald-200 bg-emerald-50 p-5">
        <h3 className="text-lg font-semibold text-emerald-900">最初に読むべきセクション</h3>
        <p className="mt-1 text-sm text-emerald-800">
          初めての方は、以下の必読ガイドを順に読んでから演習に進んでください。
        </p>
        <ul className="mt-4 space-y-2">
          {requiredGuides.map((guide) => (
            <li key={guide.articleId}>
              <Link
                to={`/learn/start/${guide.articleId}`}
                className="text-sm font-medium text-emerald-900 hover:underline"
              >
                {guide.title}
                <span className="ml-2 text-xs text-emerald-700">
                  （約{guide.readTimeMinutes}分）
                </span>
              </Link>
            </li>
          ))}
        </ul>
        <div className="mt-4">
          <Link to="/learn/start">
            <Button>はじめにセクションを開く</Button>
          </Link>
        </div>
      </Card>

      <section>
        <h3 className="mb-4 text-lg font-semibold text-slate-900">レベル別セクション</h3>
        <div className="grid gap-4 md:grid-cols-2">
          {sortedSections.map((section) => (
            <SectionCard key={section.sectionId} section={section} />
          ))}
        </div>
      </section>

      <Card className="p-5">
        <h3 className="font-semibold text-slate-900">すぐに演習を始める</h3>
        <p className="mt-1 text-sm text-slate-600">
          解説を読み終えたら、SQL サンドボックスで手を動かしましょう。
        </p>
        <Link to="/sandbox" className="mt-4 inline-block">
          <Button variant="secondary">SQL サンドボックスを開く</Button>
        </Link>
      </Card>
    </div>
  )
}
