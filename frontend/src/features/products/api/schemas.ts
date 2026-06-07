import { z } from 'zod'
import { pageResultSchema } from '../../shared/schemas'

export const productSchema = z.object({
  productId: z.number(),
  productName: z.string(),
  categoryName: z.string(),
  brandName: z.string().nullable(),
  unitPrice: z.number(),
  stockQuantity: z.number(),
  isDiscontinued: z.boolean(),
  averageRating: z.number(),
  reviewCount: z.number(),
})

export const productPageSchema = pageResultSchema(productSchema)

export type Product = z.infer<typeof productSchema>
export type ProductPage = z.infer<typeof productPageSchema>
