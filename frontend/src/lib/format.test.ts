import { describe, expect, it } from 'vitest'
import { formatCurrency } from './format'

describe('formatCurrency', () => {
  it('should format yen with locale', () => {
    expect(formatCurrency(1234567)).toBe('¥1,234,567')
  })

  it('should round fractional values', () => {
    expect(formatCurrency(999.6)).toBe('¥1,000')
  })
})
