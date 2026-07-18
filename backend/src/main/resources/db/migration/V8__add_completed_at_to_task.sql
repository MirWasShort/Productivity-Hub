ALTER TABLE tasks
    ADD COLUMN completed_at TIMESTAMPTZ;

-- Backfill existing DONE tasks with their last-update time as a proxy.
UPDATE tasks SET completed_at = updated_at WHERE status = 'DONE';
