import { z } from 'zod'

export const dashboardStatsSchema = z.object({
  customerCount: z.number(),
  orderCount: z.number(),
  productCount: z.number(),
  employeeCount: z.number(),
  deliveredOrderCount: z.number(),
  totalRevenue: z.number(),
})

export const membershipTierStatSchema = z.object({
  membershipTier: z.string(),
  customerCount: z.number(),
})

export const dashboardResponseSchema = z.object({
  stats: dashboardStatsSchema,
  membershipTierStats: z.array(membershipTierStatSchema),
})

export type DashboardStats = z.infer<typeof dashboardStatsSchema>
export type MembershipTierStat = z.infer<typeof membershipTierStatSchema>
export type DashboardResponse = z.infer<typeof dashboardResponseSchema>
