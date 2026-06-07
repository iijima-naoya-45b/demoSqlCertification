import { describe, expect, it } from 'vitest'
import { authUserSchema } from './schemas'

describe('authUserSchema', () => {
  it('should parse authenticated user', () => {
    const user = authUserSchema.parse({
      userId: 'abc-123',
      username: 'demo',
      email: 'demo@demoshop.local',
      displayName: 'Demo Learner',
      roles: ['learner'],
      authenticated: true,
    })

    expect(user.authenticated).toBe(true)
    expect(user.roles).toContain('learner')
  })
})
