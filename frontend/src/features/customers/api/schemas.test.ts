import { describe, expect, it } from 'vitest'
import { customerDetailSchema, customerPageSchema } from './schemas'

describe('customer schemas', () => {
  it('should parse customer page result', () => {
    const result = customerPageSchema.parse({
      items: [
        {
          customerId: 1,
          customerName: '山田 太郎',
          email: 'yamada@example.com',
          phone: '090-0000-0000',
          prefecture: '東京都',
          city: '渋谷区',
          registeredAt: '2024-01-01',
          membershipTier: 'gold',
          createdAt: '2024-01-01T00:00:00',
        },
      ],
      totalCount: 1,
      page: 1,
      pageSize: 20,
    })

    expect(result.items[0].customerName).toBe('山田 太郎')
  })

  it('should parse customer detail', () => {
    const result = customerDetailSchema.parse({
      customerId: 5,
      customerName: '佐藤 花子',
      email: 'sato@example.com',
      phone: null,
      prefecture: '大阪府',
      city: '大阪市',
      registeredAt: '2024-02-01',
      membershipTier: 'silver',
      createdAt: '2024-02-01T00:00:00',
      orderCount: 3,
      totalPurchaseAmount: 12000,
      averageOrderAmount: 4000,
    })

    expect(result.orderCount).toBe(3)
  })
})
