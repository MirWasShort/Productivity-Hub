CREATE TABLE tags (
    id         UUID PRIMARY KEY,
    name       VARCHAR(50) NOT NULL,
    color      VARCHAR(7),
    user_id    UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_tags_user_id ON tags (user_id);

-- One tag name per user, case-insensitively: "Urgente" and "urgente"
-- are the same tag.
CREATE UNIQUE INDEX ux_tags_user_lower_name ON tags (user_id, lower(name));
