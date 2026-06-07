import { z } from 'zod'

export const exerciseSummarySchema = z.object({
  exerciseId: z.string(),
  title: z.string(),
  difficulty: z.number(),
  questionCount: z.number(),
})

export const exerciseQuestionSchema = z.object({
  questionId: z.string(),
  text: z.string(),
  hint: z.string().optional(),
})

export const exerciseSchema = z.object({
  exerciseId: z.string(),
  title: z.string(),
  difficulty: z.number(),
  description: z.string(),
  questions: z.array(exerciseQuestionSchema),
})

export const sqlExecutionResultSchema = z.object({
  auditStatus: z.literal('ALLOWED'),
  columns: z.array(z.string()),
  rows: z.array(z.array(z.unknown())),
  rowCount: z.number(),
  executionTimeMs: z.number(),
  truncated: z.boolean(),
  message: z.string().optional().nullable(),
})

export const sqlBlockedErrorSchema = z.object({
  timestamp: z.string(),
  status: z.number(),
  error: z.string(),
  auditStatus: z.literal('BLOCKED'),
  detectedKeyword: z.string(),
  message: z.string(),
})

export type ExerciseSummary = z.infer<typeof exerciseSummarySchema>
export type Exercise = z.infer<typeof exerciseSchema>
export type SqlExecutionResult = z.infer<typeof sqlExecutionResultSchema>
export type SqlBlockedError = z.infer<typeof sqlBlockedErrorSchema>
