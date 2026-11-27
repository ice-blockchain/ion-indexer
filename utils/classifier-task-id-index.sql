-- Run with psql in autocommit mode, not inside a migration transaction.
-- Back up the schema first. On failure, inspect pg_index.indisvalid before retrying;
-- IF NOT EXISTS alone does not repair an invalid index from an interrupted build.
CREATE INDEX CONCURRENTLY IF NOT EXISTS _classifier_tasks_id_idx
    ON public._classifier_tasks (id);
