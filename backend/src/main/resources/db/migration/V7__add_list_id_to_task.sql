-- Deleting a list must not delete its tasks: they fall back to "no list".
ALTER TABLE tasks
    ADD COLUMN list_id UUID REFERENCES todo_lists (id) ON DELETE SET NULL;

CREATE INDEX idx_tasks_list_id ON tasks (list_id);
