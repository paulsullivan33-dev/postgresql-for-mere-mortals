# Writing Criteria

Every guide in this repo is written to the same
standard. If you're adding or editing a guide —
human or AI — hold it to these.

1. **Plain words, real ideas.** Simple language,
   never dumbed-down concepts. Explain jargon on
   first use; collect terms in the glossary.
2. **No hype.** No marketing adjectives, no
   "revolutionary," no promises about what
   something will do for the reader.
3. **Honest about limits.** Say what the thing
   *can't* do. State uncertainty instead of
   smoothing it over. Validation notes include
   what remains unverified.
4. **No invented numbers.** Benchmarks, defaults,
   and specs are either measured or qualified with
   "depends on your setup." If it wasn't tested,
   say so.
5. **Checkable.** Commands are meant to be run,
   with "Check:" blocks showing what success looks
   like. Sources are linked, not asserted.
6. **Respect the reader's setup.** Call out
   Windows/Mac/Linux differences. Don't assume a
   GPU, a budget, or prior experience.
7. **Safety isn't skipped.** Real risks get
   stated plainly, not buried.
8. **Scoped.** Each guide says what it covers and
   points elsewhere for the rest. No guide
   pretends to be the whole subject.
9. **Structure over prose.** Tables, before/after
   examples, symptom → fix. Scannable beats essay.

## Verification notes for this guide

Standard 3 and 4 applied to this guide,
specifically. PostgreSQL **16.15** (Ubuntu
package `16+257build1.1`, server
`16.15-0ubuntu0.24.04.1`) was installed fresh
on the build machine with `apt-get install -y
postgresql`, and every quoted output is a
capture from it. Working transcripts are kept
with the build (`postgresql-lab/transcripts/`,
10 numbered files, t01–t10).

**The lab.** The package created a default
cluster `main` on port **5432**; the install
environment's policy-rc.d refused to start
it, and the guide never started, stopped, or
reconfigured it — transcript t10 verifies it
`down`, untouched, at the end. All work ran
in a second cluster, `lab`, created with
`pg_createcluster 16 lab --port=5433`, with
its data under `/var/lib/postgresql/16/lab`
and config under `/etc/postgresql/16/lab`
(the Debian layout; the lab folder on the
build machine holds scripts, fixtures, and
transcripts, not server files — see the root
note below). Lab roles: `librarian` (owner
of the fixture database `seedlib`) and
`reader` (no privileges except as granted
in transcript t08), with invented lab
passwords printed in the transcripts because
the lab is throwaway. The cluster was
stopped in transcript t10; nothing is left
listening on 5432 or 5433 and no postgres
process remains, verified in that
transcript. The cluster still exists on
disk, stopped, removable with
`pg_dropcluster 16 lab`.

**The root hurdle, on the record
(transcript t01).** This build shell runs
as root. `initdb` refuses root verbatim
("cannot be run as root"). The sandbox also
refused `chown` of the workspace lab
directory to the postgres user ("Operation
not permitted") and the postgres OS user
cannot read inside the workspace at all —
so the lab cluster's files live at the
distribution's standard locations rather
than inside the lab folder, and chapter 1
says exactly that and why. A consequence:
psql run as the postgres OS user cannot
`-f` a script file inside the workspace
("Permission denied", captured in a
discarded first pass of transcript t02);
the superuser's script runs feed the file
on standard input instead, and the
transcript shows that form.

**The fixtures.** A fictional community
seed library, the Maple Street Seed
Library: six invented members (Mara
Ellison, Dev Patel, June Okafor, Tomas
Rivera, Ingrid Larsen, Walt Freeman, all
`@example.org`), six seed packets, ten
loans, plus a planted `loan_history` of
500,000 generated rows. The dump file
from transcript t09 (17,675,833 bytes)
stays in the lab folder.

**Verified by running, per chapter:**

- *Ch. 1:* the apt install (already-present
  re-run captured), `psql --version`
  16.15, `pg_lsclusters` with `main` down;
  the `initdb`-as-root refusal, the
  refused `chown`, and the postgres
  user's workspace access denial, all
  verbatim; `pg_createcluster 16 lab
  --port=5433`, start, `pg_isready`
  "accepting connections", and the log's
  "ready to accept connections".
- *Ch. 2:* `CREATE ROLE` ×2 and `CREATE
  DATABASE ... OWNER librarian` as the
  superuser over the socket (peer auth);
  `\l` and `\du` read back; the librarian
  role signing in over TCP with its
  password — `current_user` /
  `current_database()` answering
  `librarian | seedlib`. Meta-commands
  captured (t03): `\conninfo` (including
  its SSL line — TLSv1.3 on loopback TCP,
  the package default), `\dn` (schema
  `public` owned by `pg_database_owner`),
  `\dt` answering "Did not find any
  relations." before tables existed,
  `\timing` with `Time: 1.686 ms` on
  `SELECT version();`.
- *Ch. 3:* the three CREATE TABLEs and
  their `\d` read-backs (identity
  defaults, both unique indexes, the
  check, both foreign keys); one good
  insert, then all five refusals
  verbatim with DETAIL lines — UNIQUE
  (`members_email_key`), NOT NULL
  (`full_name`), CHECK ≥ 0
  (`seed_packets_packets_on_hand_check`),
  FOREIGN KEY (`loans_member_id_fkey`,
  key 999), and the cross-column CHECK
  (`loans_check`, return before loan);
  closing counts 1/0/0. The burned
  identity numbers visible in the DETAIL
  lines (failing rows numbered 3, 1, 2)
  are real and are discussed in the
  chapter as the no-reuse property.
- *Ch. 4:* `TRUNCATE ... RESTART
  IDENTITY CASCADE` (fixture reset);
  seed inserts answering `INSERT 0 6`,
  `INSERT 0 6`, `INSERT 0 10`; the
  still-out three-table JOIN (5 rows,
  named in the chapter); GROUP BY crop
  (Tomato 3, Beans 2, Peas 2, Carrot 1,
  Kale 1, Lettuce 1); LEFT JOIN member
  totals (Mara 3, Dev 2, June 2, Ingrid
  1, Tomas 1, Walt 1).
- *Ch. 5:* loan counts 10 → 11 (inside)
  → 10 (after ROLLBACK); the committed
  UPDATE moving Tomato stock 14 → 13;
  the FK error inside a transaction,
  then `ERROR: current transaction is
  aborted, commands ignored until end of
  transaction block` verbatim, ROLLBACK,
  and the count still 10 afterwards.
- *Ch. 6 (the centerpiece):* 500,000
  planted rows (`INSERT 0 500000`),
  relation size 36 MB. Count for member
  123 (exactly 1,000 rows): before any
  index, a **Parallel Seq Scan**,
  Execution Time **50.717 ms**, "Rows
  Removed by Filter: 166333" per worker;
  after `CREATE INDEX
  idx_loan_history_member` and `VACUUM
  ANALYZE`, an **Index Only Scan** with
  `Heap Fetches: 0`, Execution Time
  **0.327 ms**. Fetching 10 of the
  member's rows ordered by date used a
  Bitmap Heap Scan over the same index,
  4.667 ms. Times are this table on
  this machine, quoted as such; the
  chapter's claim is the plan shape and
  the ~155× ratio, not the milliseconds.
  Two honest footnotes: an earlier pass
  at 50,000 rows was discarded because
  the plans it produced were noise
  (a bitmap plan marginally *slower*
  than the sequential scan, and a
  LIMIT query that ignored the new
  index); and the pre-vacuum index plan
  at that size was a Bitmap Heap Scan —
  the index-only result depends on the
  VACUUM step, which is why the chapter
  teaches it as part of the move.
- *Ch. 7:* as `reader`: `permission
  denied for table members` verbatim;
  owner runs `GRANT SELECT ON members
  TO reader`; the same SELECT returns
  all 6 members; reader's INSERT into
  members and SELECT from loans both
  refused with `permission denied` —
  the grant's exact shape, proven from
  both sides.
- *Ch. 8:* aggregates before the backup
  — counts 500000/10/6/6 (history /
  loans / members / packets),
  members md5
  `c06475d07487f83324fbc44039ef0e15`,
  loans md5
  `f4abecd92adc6f5bad70e67748634c43`,
  packets on hand 80 (= 81 seeded minus
  the 1 committed away in ch. 5).
  `pg_dump` produced a 17,675,833-byte
  script with 4 COPY blocks; the
  database was dropped and recreated by
  the superuser; the replay (`-q`)
  surfaced the sequence `setval`s
  (500000, 12, 6, 6); `\dt` showed all
  four tables owned by `librarian`;
  the aggregates after are identical
  in every value.
- *Ch. 9:* `SHOW port` 5433,
  `data_directory`
  `/var/lib/postgresql/16/lab`,
  `listen_addresses` `localhost`,
  `max_connections` 100 — read from the
  running server; `pg_database_size`
  for seedlib after the restore:
  47 MB; the shutdown sequence and the
  nothing-listening / no-processes
  checks.
- *Ch. 11:* every symptom is one the lab
  produced (initdb-as-root, auth
  failure, file-permission route,
  empty `\dt`, all five constraint
  errors, the aborted transaction,
  permission denied, seq-scan reading)
  or the direct neighbour of one
  (connection refused on a stopped
  cluster — the state t10 ends in;
  sequence collision after a hand-made
  restore — the failure pg_dump's
  captured `setval` lines exist to
  prevent).

**Capture hygiene (declared trims):** the
capture harness echoes commands with `$`
and its echo drops shell quoting on `-c`
arguments (so a transcript line reads
`$ LIB -d seedlib -c SELECT ...`); the SQL
in chapters is quoted from the lab's .sql
files, which are shipped in `examples/`
and are byte-identical to the files the
final transcripts ran (the schema, seed,
queries, and big-table scripts).
Long aligned outputs are trimmed in
chapters with the omitted rows marked
(`\l`'s privilege columns, the members
listing) — nothing was reworded, and every
number quoted in a chapter was read off
the transcripts. Two passes were discarded
and rebuilt before the final transcripts:
t02 (file-access route, above) and t05
(first seed run failed its loans insert —
identity values 4–9 after ch. 3's test
rows, the exact lesson ch. 4 now teaches;
fixed with the TRUNCATE reset and a full
rerun of t02–t05) and t07 (scale, above).

**Documented-only (not run), and why:**

- *Replication, standby failover, and HA
  tooling* — needs several cooperating
  clusters; the lab's discipline is one
  throwaway cluster. Named in ch. 10
  with their jobs stated.
- *Point-in-time recovery (base backups
  + WAL archiving)* — named in ch. 8/10;
  the lab's backup story is the logical
  dump, run end to end.
- *Connection pooling (PgBouncer)*,
  *extensions (PostGIS and others)*,
  *managed services (RDS, Cloud SQL,
  Azure Database)* — named where they
  belong, not taught; no commands quoted
  for any of them.
- *Tuning beyond the index chapter* —
  memory knobs, non-B-tree index kinds,
  partitioning: named in ch. 10. The
  one quantitative tuning claim in the
  guide is ch. 6's measured pair.
- *Group roles, GRANT on many objects,
  REVOKE, `\z`* — named in ch. 7 as the
  same statement with longer lists; the
  lab ran the single-table atom so the
  boundary could be proven exactly.
- *`pg_dumpall` and role restoration* —
  named in ch. 8; the lab's roles were
  never deleted, so their absence from
  a single-database dump is stated as
  the tool's documented behaviour and
  as what the restore visibly relied on
  (the owner role had to already exist),
  not as a separately staged experiment.
- *Installation on Windows/macOS* —
  described (project installers,
  Homebrew), not performed; the build
  machine installed the Ubuntu package.
