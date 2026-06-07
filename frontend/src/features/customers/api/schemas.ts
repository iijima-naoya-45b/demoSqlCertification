import { z } from 'zod'
import { pageResultSchema } from '../../shared/schemas'

export const customerSchema = z.object({
  customerId: z.number(),
  customerName: z.string(),
  email: z.string(),
  phone: z.string().nullable(),
  prefecture: z.string().nullable(),
  city: z.string().nullable(),
  registeredAt: z.string(),
  membershipTier: z.string(),
  createdAt: z.string(),
})

export const customerDetailSchema = customerSchema.extend({
  orderCount: z.number(),
  totalPurchaseAmount: z.number(),
  averageOrderAmount: z.number(),
})

export const customerPageSchema = pageResultSchema(customerSchema)

export type Customer = z.infer<typeof customerSchema>
export type CustomerDetail = z.infer<typeof customerDetailSchema>
export type CustomerPage = z.infer<typeof customerPageSchema>
