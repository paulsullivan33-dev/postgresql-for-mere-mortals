# The Honest Limits

This guide ran one cluster, on one
machine, with the package defaults.
PostgreSQL's reputation, though, rests
partly on things one cluster in a lab
cannot show. This chapter names them
plainly — what they are, what they're
for, and the honest statement that
they were **not run here** — so the
guide's map shows its own edges.

## Named, not run

- **Replication and high availability.**
  A second server (a *standby*) can
  follow the first one's changes
  continuously, ready to take over.
  This is how real PostgreSQL survives
  a dead machine. It needs at least
  two clusters choreographed together;
  the lab's discipline was one cluster,
  so streaming replication, failover,
  and the tooling around them (Patroni
  and friends) are described here and
  demonstrated nowhere in this guide.
- **Point-in-time recovery.** Physical
  base backups plus archived
  write-ahead log (WAL — the server's
  own journal of changes, which the
  lab never opened) let you restore to
  a chosen moment, not just to the
  last dump. Chapter 8's logical dump
  is the right tool at lab scale; the
  WAL machinery is the grown-up
  sibling, named, not taught.
- **Connection pooling.** A busy
  application may want more
  connections than a server should
  have; a pooler (PgBouncer is the
  usual name) multiplexes them. The
  lab's ceiling was the default 100
  and its load was one typist.
- **Extensions.** PostgreSQL grows by
  installing extensions — PostGIS for
  geography is the famous one; others
  add statistics, text search
  machinery, new index kinds. None was
  installed in the lab; everything you
  saw is the core server.
- **Managed PostgreSQL.** RDS, Cloud
  SQL, Azure Database and their kin
  rent you a cluster with the
  administration partly done. The SQL
  and the concepts transfer unchanged;
  the levers (`pg_ctlcluster`, the
  files, the logs) become a console
  and an API. Not used here.
- **Tuning.** `shared_buffers`,
  work-memory knobs, planner
  statistics targets, index kinds
  beyond B-tree (GiST, GIN, BRIN),
  partitioning very large tables —
  a real discipline, of which this
  guide used exactly one move:
  measure with `EXPLAIN ANALYZE`,
  add the index the question asks
  for, measure again. Any chapter
  claiming more from defaults and a
  36 MB table would be inventing
  numbers; this one doesn't.
- **Other platforms.** Installation
  on Windows and macOS is described
  in the project's own docs (installers
  and Homebrew respectively); the lab
  installed the Ubuntu package only.

## When PostgreSQL isn't the answer

The honest chapter also runs the other
direction. PostgreSQL is the wrong
tool, or at least more tool than the
job wants, when:

- **One program, one file, no
  network.** An embedded database —
  SQLite — has no server to run, no
  roles to manage, and nothing to
  administer. The shelf's SQLite guide
  covers it; choosing it is not a
  downgrade, it's a fit.
- **The data is a cache, a queue, or
  a scoreboard.** Memory-first stores
  like Redis do those jobs faster and
  simpler, in front of a system of
  record. The Redis guide sits next to
  this one for that reason.
- **The "database" is a spreadsheet
  with ambitions.** If nothing
  enforces rules, nobody connects
  concurrently, and SELECT is a
  foreign word, the server will wait
  patiently until the project grows
  into needing it. It keeps.

What remains after the limits is the
guide's actual claim: for data that
must be *correct* (constraints),
*shared* (roles and permissions),
*atomic* (transactions), and *still
there tomorrow* (a backup loop you
have personally restored), one
PostgreSQL cluster on one machine —
exactly what the lab ran — is the
complete, honest article.

## What this chapter established

- Replication, failover, WAL-based
  recovery, pooling, extensions,
  managed services, and tuning are
  real, named, and **not demonstrated
  in this guide** — believe chapters
  that show you their transcripts
  over chapters that don't.
- The neighbours are fits, not rivals:
  SQLite for the embedded end, Redis
  for the memory-first layer,
  PostgreSQL for the system of record.
