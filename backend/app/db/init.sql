CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS plants (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    crop_slug TEXT NOT NULL,
    nickname TEXT,
    planted_at DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
