# Classifier task lookup index

The classifier joins task claims by `id` and deletes completed tasks by `id`.
The schema previously indexed only `mc_seqno`, forcing full task-table scans
for each completion. This becomes expensive during a historical rebuild.

Fresh schema creation now includes a nonunique B-tree on `id`. Existing large
databases should apply `classifier-task-id-index.sql` with psql autocommit before
starting the updated worker, avoiding a blocking index build at startup.
Back up the schema and verify free disk space first. Do not truncate the queue.

Verify `pg_index.indisvalid` and `indisready` for the new index, then use
`EXPLAIN DELETE FROM _classifier_tasks WHERE id = 123;` (without ANALYZE) to
verify an index scan. Measure queue reduction over several minutes rather than
using the classifier's lifetime-average trace counter as a current rate.

If a concurrent build fails, inspect its index validity and investigate the
failure before retrying. An invalid same-named index is not repaired by
`IF NOT EXISTS`. Rollback, if required, is `DROP INDEX CONCURRENTLY
public._classifier_tasks_id_idx;`; this removes only the index, not task data.
