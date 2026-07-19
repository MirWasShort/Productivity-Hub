import { format as formatDate, isSameDay, isSameMonth, isToday } from 'date-fns'
import { it } from 'date-fns/locale'
import { visibleDays, type CalendarFormat } from '@/features/calendar/calendar-view'
import { cn } from '@/lib/utils'

const weekdayLabels = ['lun', 'mar', 'mer', 'gio', 'ven', 'sab', 'dom']

export function CalendarGrid({
  anchor,
  format,
  selected,
  countFor,
  onSelect,
}: {
  anchor: Date
  format: CalendarFormat
  selected: Date
  countFor: (day: Date) => number
  onSelect: (day: Date) => void
}) {
  const days = visibleDays(anchor, format)

  return (
    <div>
      <div className="text-muted-foreground mb-1 grid grid-cols-7 text-center text-xs">
        {weekdayLabels.map((label) => (
          <div key={label} className="py-1">
            {label}
          </div>
        ))}
      </div>

      <div className="grid grid-cols-7 gap-1">
        {days.map((day) => {
          const count = countFor(day)
          const isSelected = isSameDay(day, selected)
          const outside = format === 'month' && !isSameMonth(day, anchor)

          return (
            <button
              key={day.toISOString()}
              type="button"
              onClick={() => onSelect(day)}
              aria-pressed={isSelected}
              aria-label={`${formatDate(day, 'd MMMM yyyy', { locale: it })}${
                count > 0 ? `, ${count} task` : ''
              }`}
              className={cn(
                'flex aspect-square flex-col items-center justify-center gap-1 rounded-md text-sm transition-colors',
                outside && 'text-muted-foreground/50',
                isToday(day) && !isSelected && 'ring-primary/40 ring-1',
                isSelected
                  ? 'bg-primary-container text-primary-container-foreground font-semibold'
                  : 'hover:bg-accent',
              )}
            >
              {day.getDate()}
              {/* Un pallino se il giorno ha task: il numero esatto starebbe
                  stretto in una cella, e la lista sotto lo dice comunque. */}
              <span
                className={cn(
                  'size-1.5 rounded-full',
                  count > 0 ? (isSelected ? 'bg-current' : 'bg-primary') : 'bg-transparent',
                )}
                aria-hidden
              />
            </button>
          )
        })}
      </div>
    </div>
  )
}
