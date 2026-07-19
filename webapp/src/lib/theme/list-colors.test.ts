import { describe, expect, it } from 'vitest'
import { listColorSwatches, normalizeHex, withAlpha } from '@/lib/theme/list-colors'

describe('list colors', () => {
  it('espone gli otto swatch condivisi col client Flutter', () => {
    expect(listColorSwatches).toEqual([
      '#4F46E5',
      '#0EA5E9',
      '#10B981',
      '#F59E0B',
      '#EF4444',
      '#EC4899',
      '#8B5CF6',
      '#64748B',
    ])
  })

  it('accetta un colore #RRGGBB valido', () => {
    expect(normalizeHex('#10B981')).toBe('#10B981')
    expect(normalizeHex('#10b981')).toBe('#10b981')
  })

  it('ripiega su slate per null, vuoto o formato non valido', () => {
    expect(normalizeHex(null)).toBe('#64748B')
    expect(normalizeHex(undefined)).toBe('#64748B')
    expect(normalizeHex('rosso')).toBe('#64748B')
    expect(normalizeHex('#FFF')).toBe('#64748B')
    expect(normalizeHex('#GGGGGG')).toBe('#64748B')
  })

  it('aggiunge il canale alfa in esadecimale', () => {
    expect(withAlpha('#10B981', 0.15)).toBe('#10B98126')
    expect(withAlpha('#10B981', 0.5)).toBe('#10B98180')
    expect(withAlpha(null, 1)).toBe('#64748BFF')
  })
})
