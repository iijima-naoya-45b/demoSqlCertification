import { z } from 'zod'
import { pageResultSchema } from '../../shared/schemas'

export const orderSummarySchema = z.object({
  orderId: z.number(),
  customerName: z.string(),
  salesRepName: z.string().nullable(),
  orderDate: z.string(),
  status: z.string(),
  itemCount: z.number(),
  subtotal: z.number(),
  shippingFee: z.number(),
  totalAmount: z.number(),
})

export const orderPageSchema = pageResultSchema(orderSummarySchema)

export type OrderSummary = z.infer<typeof orderSummarySchema>
export type OrderPage = z.infer<typeof orderPageSchema>
