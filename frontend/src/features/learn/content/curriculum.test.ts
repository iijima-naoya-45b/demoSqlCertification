import { describe, expect, it } from 'vitest'
import { getRequiredGuides, getSectionById, learnSections } from './curriculum'
import { exercises } from './exercises'

describe('curriculum', () => {
  it('should have four skill levels in order', () => {
    const sectionIds = learnSections.map((section) => section.sectionId)
    expect(sectionIds).toEqual(['start', 'beginner', 'intermediate', 'advanced'])
  })

  it('should have required guides in start section', () => {
    const required = getRequiredGuides()
    expect(required.length).toBeGreaterThanOrEqual(3)
    expect(required.every((guide) => guide.isRequired)).toBe(true)
  })

  it('should map all exercises to a section', () => {
    const mappedIds = learnSections.flatMap((section) => section.exerciseIds)
    exercises.forEach((exercise) => {
      expect(mappedIds).toContain(exercise.exerciseId)
    })
  })

  it('should return beginner section', () => {
    const section = getSectionById('beginner')
    expect(section?.title).toBe('初級')
    expect(section?.exerciseIds).toContain('01')
  })
})
