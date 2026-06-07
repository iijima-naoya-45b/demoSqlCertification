import { z } from 'zod'

export const pageResultSchema = <T extends z.ZodType>(itemSchema: T) =>
  z.object({
    items: z.array(itemSchema),
    totalCount: z.number(),
    page: z.number(),
    pageSize: z.number(),
  })

export type PageResult<T> = {
  items: T[]
  totalCount: number
  page: number
  pageSize: number
}
