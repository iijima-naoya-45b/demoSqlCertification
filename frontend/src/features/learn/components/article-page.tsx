import { Link, useParams } from 'react-router-dom'
import { Button } from '../../../components/ui/button'
import { Card } from '../../../components/ui/card'
import { getArticle } from '../content/curriculum'
import type { SkillLevel } from '../content/types'
import { ContentRenderer } from './content-renderer'

export function ArticlePage() {
  const { sectionId, articleId } = useParams<{ sectionId: SkillLevel; articleId: string }>()
  const article = sectionId && articleId ? getArticle(sectionId, articleId) : undefined

  if (!article || !sectionId) {
    return (
      <Card className="p-6">
        <p className="text-sm text-slate-600">記事が見つかりません。</p>
        <Link to="/learn" className="mt-4 inline-block text-sm text-indigo-600 hover:underline">
          学習ガイドトップへ
        </Link>
      </Card>
    )
  }

  const sandboxLink =
    article.relatedExerciseIds && article.relatedExerciseIds.length > 0
      ? `/sandbox?exercise=${article.relatedExerciseIds[0]}`
      : '/sandbox'

  return (
    <div className="space-y-6">
      <div>
        <Link
          to={`/learn/${sectionId}`}
          className="text-sm text-indigo-600 hover:underline"
        >
          ← セクション一覧に戻る
        </Link>
        <h2 className="mt-3 text-2xl font-bold text-slate-900">{article.title}</h2>
        <p className="mt-2 text-sm text-slate-600">{article.summary}</p>
        <p className="mt-1 text-xs text-slate-400">読了目安: 約{article.readTimeMinutes}分</p>
      </div>

      <Card className="p-6">
        <ContentRenderer blocks={article.blocks} />
      </Card>

      <div className="flex flex-wrap gap-3">
        <Link to={sandboxLink}>
          <Button>サンドボックスで試す</Button>
        </Link>
        <Link to={`/learn/${sectionId}`}>
          <Button variant="secondary">他の解説を見る</Button>
        </Link>
      </div>
    </div>
  )
}
