# Glossary

**ANALYZE** — the command that refreshes
the statistics the planner decides with;
also a keyword of `EXPLAIN ANALYZE`,
which runs a statement and reports its
real timing.

**B-tree** — the default index kind: a
balanced, sorted tree the server can
search and keep in order.

**Bitmap Heap Scan** — a plan shape that
collects matching row locations from an
index first, then visits the table pages
once each.

**CHECK constraint** — a condition every
row in a table must satisfy, enforced on
every write.

**Cluster** — one PostgreSQL server
installation: one data directory, one
port, many databases. (Not, in this
guide's usage, a group of machines.)

**Commit** — ending a transaction by
making all of its changes permanent and
visible to everyone.

**Constraint** — a rule declared on a
table (primary key, unique, not-null,
check, foreign key) that the server
enforces on every write.

**Database** — a named container inside
a cluster, holding schemas and tables.
Databases in one cluster cannot see
inside each other.

**EXPLAIN ANALYZE** — runs a statement
and prints the plan actually used, with
measured times per step.

**Extension** — an add-on package that
gives the server new abilities (PostGIS
is the famous one). None is used in
this guide.

**Foreign key** — a column whose value
must exist as a key in another table;
declared with `REFERENCES`.

**Identity column** — a column the
server numbers itself
(`GENERATED ... AS IDENTITY`). Numbers
are never reused; gaps are normal.

**Index** — a lookup structure beside a
table that lets the server find rows
without reading the whole table.

**Index Only Scan** — a plan that
answers entirely from an index, without
visiting the table's rows
(`Heap Fetches: 0`).

**Logical backup** — a backup as
statements (a SQL script, from
`pg_dump`) rather than as file copies;
portable across versions and machines.

**Meta-command** — a psql instruction
starting with a backslash (`\l`, `\du`,
`\dt`, `\d`). Handled by psql itself,
never sent to the server.

**NULL** — the absence of a value. Not
zero, not empty; tested with `IS NULL`,
never with `=`.

**Peer authentication** — local-socket
sign-in where the operating-system user
*is* the database role; no password
asked.

**pg_dump** — the tool that writes one
database out as a SQL script (structure
plus data); `pg_dumpall` is its
cluster-wide sibling.

**Planner** — the part of the server
that chooses how to execute a statement
(seq scan, index scan, joins, sorting)
from the statistics it keeps.

**Primary key** — the column (or set)
that identifies each row; never empty,
never repeated, and backed by an index.

**psql** — the command-line client that
ships with PostgreSQL.

**Role** — who is asking: an owner of
things and holder of permissions. A
role with `LOGIN` is a user.

**Rollback** — ending a transaction by
discarding all of its changes.

**Schema** — a namespace inside a
database. A fresh database has one,
`public`, where this guide's tables
live.

**Sequential scan** — reading a whole
table, row by row, to find the matches;
the plan of last resort, and often the
right one on small tables.

**Superuser** — the role that can do
everything (`postgres` in a fresh
cluster). Created the lab's roles;
barely seen afterward, which is the
point.

**Transaction** — a group of statements
between `BEGIN` and `COMMIT`/`ROLLBACK`
that lands all together or not at all.
One failed statement aborts it.

**TRUNCATE** — empties a table in one
statement; `RESTART IDENTITY` resets
its numbering; the fixture-loader's
broom.

**VACUUM** — housekeeping that reclaims
dead row space and marks pages
all-visible, which is what allows
index-only scans to skip the table.

**WAL (write-ahead log)** — the server's
journal of changes, the machinery
behind crash recovery and point-in-time
restore. Named in this guide, not
opened.
