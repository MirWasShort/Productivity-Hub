import { addYears, format, subDays } from 'date-fns'
import { it } from 'date-fns/locale'
import { CalendarIcon, X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Calendar } from '@/components/ui/calendar'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'

/**
 * Intervallo selezionabile: un anno indietro (per registrare cose scadute) e
 * cinque avanti, come nel client Flutter.
 */
function dateRange(today: Date) {
  return { from: subDays(today, 365), to: addYears(today, 5) }
}

export function DueDatePicker({
  value,
  onChange,
}: {
  value: Date | undefined
  onChange: (date: Date | undefined) => void
}) {
  const { from, to } = dateRange(new Date())

  return (
    <div className="flex gap-2">
      <Popover>
        <PopoverTrigger asChild>
          <Button
            type="button"
            variant="outline"
            className="flex-1 justify-start gap-2 font-normal"
          >
            <CalendarIcon aria-hidden />
            {value ? format(value, 'd MMMM yyyy', { locale: it }) : 'Nessuna scadenza'}
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-auto p-0" align="start">
          <Calendar
            mode="single"
            locale={it}
            selected={value}
            onSelect={onChange}
            startMonth={from}
            endMonth={to}
            disabled={{ before: from, after: to }}
            autoFocus
          />
        </PopoverContent>
      </Popover>

      {value && (
        <Button
          type="button"
          variant="ghost"
          size="icon"
          aria-label="Togli la scadenza"
          onClick={() => onChange(undefined)}
        >
          <X aria-hidden />
        </Button>
      )}
    </div>
  )
}
