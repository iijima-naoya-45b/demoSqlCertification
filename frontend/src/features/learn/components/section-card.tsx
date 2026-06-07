import { Link } from 'react-router-dom'
import { Badge } from '../../../components/ui/badge'
import type { LearnSection } from '../content/types'

type SectionCardProps = {
  section: LearnSection
}

export function SectionCard({ section }: SectionCardProps) {
  const requiredCount = section.guides.filter((guide) => guide.isRequired).length

  return (
    <Link
      to={`/learn/${section.sectionId}`}
      className={`block rounded-2xl border p-5 transition hover:shadow-md ${section.colorClass}`}
    >
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">
            {section.subtitle}
          </p>
          <h3 className="mt-1 text-xl font-bold text-slate-900">{section.title}</h3>
        </div>
        <Badge>{section.difficultyLabel}</Badge>
      </div>
      <p className="mt-3 text-sm text-slate-600">{section.description}</p>
      <div className="mt-4 flex flex-wrap gap-2 text-xs text-slate-500">
        <span>解説 {section.guides.length} 本</span>
        {section.exerciseIds.length > 0 && (
          <span>演習 {section.exerciseIds.length} セット</span>
        )}
        {requiredCount > 0 && <span>必読 {requiredCount} 本</span>}
      </div>
    </Link>
  )
}
