import { describe, expect, it } from 'vitest'
import { sqlBlockedErrorSchema, sqlExecutionResultSchema } from './schemas'

describe('sql sandbox schemas', () => {
  it('should parse allowed execution result', () => {
    const result = sqlExecutionResultSchema.parse({
      auditStatus: 'ALLOWED',
      columns: ['customerId', 'customerName'],
      rows: [[1, '山田 太郎']],
      rowCount: 1,
      executionTimeMs: 25,
      truncated: false,
    })

    expect(result.columns).toHaveLength(2)
    expect(result.auditStatus).toBe('ALLOWED')
  })

  it('should parse blocked audit response', () => {
    const blocked = sqlBlockedErrorSchema.parse({
      timestamp: '2026-06-07T00:00:00',
      status: 403,
      error: 'Forbidden',
      auditStatus: 'BLOCKED',
      detectedKeyword: 'DELETE',
      message: 'DELETE文は実行できません',
    })

    expect(blocked.detectedKeyword).toBe('DELETE')
  })
})
