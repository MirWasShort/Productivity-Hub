import { ArrowDownWideNarrow, Search, X } from 'lucide-react'
import { useEffect, useRef, useState } from 'react'
import type { SortDirection, TaskSortField, TaskStatus } from '@/api/types'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Input } from '@/components/ui/input'
import { toggleFilterValue, withSearch, withSort, type TaskFilter } from '@/features/tasks/filters'
import { cn } from '@/lib/utils'

/** I quattro ordinamenti del menu, con la coppia campo+direzione già decisa. */
const sortOptions: { label: string; sortBy: TaskSortField; direction: SortDirection }[] = [
  { label: 'Più recenti', sortBy: 'CREATED_AT', direction: 'DESC' },
  { label: 'Scadenza più vicina', sortBy: 'DUE_DATE', direction: 'ASC' },
  { label: 'Priorità più alta', sortBy: 'PRIORITY', direction: 'DESC' },
  { label: 'Titolo A-Z', sortBy: 'TITLE', direction: 'ASC' },
]

const statusChips: { label: string; value: TaskStatus }[] = [
  { label: 'Da fare', value: 'TODO' },
  { label: 'In corso', value: 'IN_PROGRESS' },
  { label: 'Completati', value: 'DONE' },
]

const SEARCH_DEBOUNCE_MS = 300

function FilterChip({
  label,
  active,
  onClick,
}: {
  label: string
  active: boolean
  onClick: () => void
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-pressed={active}
      className={cn(
        'rounded-sm border px-3 py-1 text-sm transition-colors',
        active
          ? 'bg-primary-container text-primary-container-foreground border-transparent'
          : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground',
      )}
    >
      {label}
    </button>
  )
}

export function FilterBar({
  filter,
  onChange,
}: {
  filter: TaskFilter
  onChange: (filter: TaskFilter) => void
}) {
  // Il campo di testo ha una vita sua: deve reagire a ogni tasto, mentre il
  // filtro (e quindi la richiesta) si aggiorna solo quando ci si ferma.
  const [term, setTerm] = useState(filter.search ?? '')

  /*
   * Il filtro va letto da un ref, non dalla chiusura dell'effetto: fra il
   * tasto premuto e lo scadere dell'attesa l'utente può aver cliccato un chip,
   * e una chiusura vecchia lo cancellerebbe rimettendo il filtro di allora.
   */
  const filterRef = useRef(filter)
  filterRef.current = filter

  useEffect(() => {
    // Al montaggio (e ogni volta che il testo già corrisponde al filtro) non
    // c'è niente da propagare: senza questa uscita, l'effetto iniziale
    // riscriverebbe il filtro dopo 300ms azzerando quanto fatto nel frattempo.
    if (term.trim() === (filterRef.current.search ?? '')) {
      return
    }
    const timer = setTimeout(() => {
      onChange(withSearch(filterRef.current, term))
    }, SEARCH_DEBOUNCE_MS)
    return () => clearTimeout(timer)
    // oxlint-disable-next-line react-hooks/exhaustive-deps -- solo il testo fa ripartire l'attesa
  }, [term])

  const activeSort =
    sortOptions.find(
      (option) => option.sortBy === filter.sortBy && option.direction === filter.direction,
    ) ?? sortOptions[0]!

  return (
    <div className="space-y-3">
      <div className="flex gap-2">
        <div className="relative flex-1">
          <Search
            className="text-muted-foreground pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2"
            aria-hidden
          />
          <Input
            value={term}
            onChange={(event) => setTerm(event.target.value)}
            placeholder="Cerca fra i task"
            aria-label="Cerca fra i task"
            className="px-9"
          />
          {term !== '' && (
            <Button
              type="button"
              variant="ghost"
              size="icon-xs"
              aria-label="Cancella la ricerca"
              className="absolute top-1/2 right-2 -translate-y-1/2"
              onClick={() => setTerm('')}
            >
              <X aria-hidden />
            </Button>
          )}
        </div>

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="outline" className="gap-2">
              <ArrowDownWideNarrow aria-hidden />
              {activeSort.label}
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            {sortOptions.map((option) => (
              <DropdownMenuItem
                key={option.label}
                onClick={() => onChange(withSort(filter, option.sortBy, option.direction))}
              >
                {option.label}
              </DropdownMenuItem>
            ))}
          </DropdownMenuContent>
        </DropdownMenu>
      </div>

      <div className="flex flex-wrap gap-2">
        {statusChips.map((chip) => (
          <FilterChip
            key={chip.value}
            label={chip.label}
            active={filter.status === chip.value}
            onClick={() => onChange(toggleFilterValue(filter, 'status', chip.value))}
          />
        ))}
        <FilterChip
          label="Alta priorità"
          active={filter.priority === 'HIGH'}
          onClick={() => onChange(toggleFilterValue(filter, 'priority', 'HIGH'))}
        />
      </div>
    </div>
  )
}
