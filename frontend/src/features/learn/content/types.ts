export type SkillLevel = 'start' | 'beginner' | 'intermediate' | 'advanced'

export type ContentBlock =
  | { type: 'paragraph'; text: string }
  | { type: 'heading'; text: string; level: 2 | 3 }
  | { type: 'code'; language: 'sql' | 'text'; code: string }
  | { type: 'list'; items: string[]; ordered?: boolean }
  | { type: 'tip'; title: string; text: string }
  | { type: 'warning'; text: string }

export type GuideArticle = {
  articleId: string
  title: string
  summary: string
  readTimeMinutes: number
  isRequired?: boolean
  blocks: ContentBlock[]
  relatedExerciseIds?: string[]
}

export type ExerciseQuestion = {
  questionId: string
  text: string
  hint?: string
}

export type Exercise = {
  exerciseId: string
  title: string
  difficulty: 1 | 2 | 3
  description: string
  level: SkillLevel
  questions: ExerciseQuestion[]
}

export type LearnSection = {
  sectionId: SkillLevel
  title: string
  subtitle: string
  difficultyLabel: string
  description: string
  order: number
  colorClass: string
  guides: GuideArticle[]
  exerciseIds: string[]
}
