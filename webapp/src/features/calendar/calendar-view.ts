import {
  addDays,
  eachDayOfInterval,
  endOfMonth,
  endOfWeek,
  startOfMonth,
  startOfWeek,
} from 'date-fns'
import { it } from 'date-fns/locale'

/** Le tre granularità del client Flutter. */
export const calendarFormats = ['month', 'twoWeeks', 'week'] as const
export type CalendarFormat = (typeof calendarFormats)[number]

export const calendarFormatLabels: Record<CalendarFormat, string> = {
  month: 'Mese',
  twoWeeks: '2 settimane',
  week: 'Settimana',
}

/** Lunedì-first, come il calendario italiano. */
const weekOptions = { locale: it, weekStartsOn: 1 } as const

/**
 * I giorni da disegnare: sempre settimane intere, così la griglia resta di
 * sette colonne e le celle non ballano. In vista mensile si parte dal lunedì
 * della settimana che contiene il primo del mese e si arriva alla domenica
 * dell'ultima: i giorni "di riempimento" ci sono, ma si vedono spenti.
 */
export function visibleDays(anchor: Date, format: CalendarFormat): Date[] {
  if (format === 'month') {
    return eachDayOfInterval({
      start: startOfWeek(startOfMonth(anchor), weekOptions),
      end: endOfWeek(endOfMonth(anchor), weekOptions),
    })
  }
  const start = startOfWeek(anchor, weekOptions)
  return eachDayOfInterval({ start, end: addDays(start, format === 'twoWeeks' ? 13 : 6) })
}
