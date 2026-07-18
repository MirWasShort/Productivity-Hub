CREATE TABLE todo_lists (
    id         UUID PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    color      VARCHAR(7),
    position   INTEGER      NOT NULL DEFAULT 0,
    user_id    UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_todo_lists_user_id ON todo_lists (user_id);
