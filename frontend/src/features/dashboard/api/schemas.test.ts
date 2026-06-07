import { describe, expect, it } from 'vitest'
import { dashboardResponseSchema } from './schemas'

describe('dashboardResponseSchema', () => {
  it('should parse valid dashboard response', () => {
    const result = dashboardResponseSchema.parse({
      stats: {
        customerCount: 10000,
        orderCount: 50000,
        productCount: 2000,
        employeeCount: 150,
        deliveredOrderCount: 12000,
        totalRevenue: 1500000,
      },
      membershipTierStats: [
        { membershipTier: 'gold', customerCount: 2500 },
      ],
    })

    expect(result.stats.customerCount).toBe(10000)
    expect(result.membershipTierStats).toHaveLength(1)
  })

  it('should reject invalid payload', () => {
    expect(() =>
      dashboardResponseSchema.parse({
        stats: { customerCount: 'invalid' },
        membershipTierStats: [],
      }),
    ).toThrow()
  })
})
