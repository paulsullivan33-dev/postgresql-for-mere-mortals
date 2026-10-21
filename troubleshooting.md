# Troubleshooting

Every symptom below happened in the
lab, in a transcript, on purpose or by
accident. The fix given is the one the
lab itself used.

| Symptom | What it means | Fix |
| --- | --- | --- |
| `initdb: error: cannot be run as root` | The server and its tools refuse to run as the root user, by design. | Don't fight it: run as the `postgres` user (`sudo -u postgres ...`), or let the distribution's wrapper do it — `pg_createcluster` (chapter 1). |
| `connection to server ... failed: Connection refused` | Nothing is listening on that port — the cluster is down, or you asked the wrong port. | `pg_lsclusters` to see state and ports; `pg_ctlcluster 16 lab start` to start. In the lab, 5432 is the packaged cluster that was never started; 5433 is yours. |
| `FATAL: password authentication failed for user "librarian"` | The role doesn't exist, or the password offered isn't the one the server holds. | Check the role exists with `\du` as the superuser; reset it with `ALTER ROLE librarian PASSWORD '...'` if it's yours. Confirm you're really aiming at *your* cluster (port). |
| `psql: error: ... .sql: Permission denied` when running a file as another OS user | psql opens `-f` files as the user running psql; that user may not be able to read your files. | Give psql the script on standard input (`psql ... < file.sql`) from a shell that can read it — the route the lab's superuser commands took. |
| `error: Did not find any relations.` from `\dt` | The database (or schema) you're connected to has no tables. A state, not a failure. | Check where you are: `\conninfo`. Create the tables, or connect to the database that has them (`-d seedlib`, not the default `postgres`). |
| `ERROR: duplicate key value violates unique constraint` | The row would repeat a value a UNIQUE rule protects. The DETAIL shows the value. | The data is already there, or the new row is wrong. `SELECT` by that value to see which. |
| `ERROR: null value in column ... violates not-null constraint` | A required column was left out of the INSERT. | Supply the value, or — if the column truly is optional — that is a schema conversation, not a data one. |
| `ERROR: new row ... violates check constraint` | A CHECK condition (stock ≥ 0; return not before loan) failed. DETAIL shows the failing row. | Read the DETAIL, find the wrong number, fix the row. The constraint is doing its job. |
| `ERROR: insert or update on table "loans" violates foreign key constraint` | The referenced row (member, packet) doesn't exist. DETAIL names the key. | Create the referenced row first, or correct the reference. Inside an application, this error usually means the two writes belonged in one transaction. |
| `ERROR: current transaction is aborted, commands ignored until end of transaction block` | An earlier statement in this transaction failed; the whole unit is poisoned. | `ROLLBACK;` — there is no other way out — find the failing statement, fix it, and re-run the transaction as a unit (chapter 5). |
| `ERROR: permission denied for table members` | Your role has not been granted that action on that table. The default state, not a malfunction. | Ask the table's owner for the specific grant (`GRANT SELECT ON members TO yourrole;`), or connect as a role that has it (chapter 7). |
| A query is slow and `EXPLAIN ANALYZE` shows `Seq Scan` | The planner read the whole table — usually no usable index, or stale statistics. | `CREATE INDEX` on the filtered column, then `VACUUM ANALYZE`, then measure again (chapter 6). On a small table a sequential scan is often the *right* plan; check the table size before fixing what isn't broken. |
| Numbers in a restored database collide (`duplicate key` on insert after a restore) | The identity sequences weren't restored with the data — happens with hand-assembled restores, not with a full pg_dump replay. | Restore from the pg_dump file itself (its `setval` lines reset the sequences), or reset a sequence by hand after checking the table's real maximum. |

Two habits cover most of the table
before it happens. **Read the DETAIL
line** — PostgreSQL's errors carry the
offending values, and half of
debugging is reading what the server
already told you. And **check where
you are** — `\conninfo`, `SELECT
current_user, current_database();`,
`\dt` — because "the table is empty"
and "I'm in the wrong database" feel
identical from the keyboard.
