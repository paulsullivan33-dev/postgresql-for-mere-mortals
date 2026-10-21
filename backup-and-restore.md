# Backup and Restore

A backup you haven't restored is a
hope, not a backup. So this chapter
does the whole loop on the record:
measure the database, dump it to a
file, **drop the database**, recreate
it empty, replay the dump, and measure
again. The two measurements match —
that match is the chapter.

## The proof, before

Four numbers stand for "the data":
row counts for every table, a checksum
over every member row and every loan
row (an md5 of the rows' text, in key
order — change any value anywhere and
the checksum changes), and the total
packets on hand:

```text
  table_name  | row_count
--------------+-----------
 loan_history |    500000
 loans        |        10
 members      |         6
 seed_packets |         6

 members_checksum: c06475d07487f83324fbc44039ef0e15
 loans_checksum:   f4abecd92adc6f5bad70e67748634c43
 total_packets_on_hand: 80
```

(80 is 81 minus the one packet the
committed transaction in chapter 5
took off the Tomato row — the fixture's
history is consistent, and the checksum
can tell.)

## pg_dump: the database as a script

```text
$ pg_dump -h 127.0.0.1 -p 5433 -U librarian -d seedlib -f seedlib-dump.sql
$ ls -l seedlib-dump.sql
-rw-rw---- 1 root nogroup 17675833 ... seedlib-dump.sql
```

`pg_dump` writes a **logical backup**:
the whole database as one SQL script —
the `CREATE TABLE`s, the constraints,
the indexes, and the data as four
`COPY` blocks (one per table). 17.7 MB
for our 47 MB database, most of it the
half-million history rows. Because it
is a script, it restores into any
PostgreSQL, of any minor version, on
any machine — the portability is the
point, and the reason this is the
default backup habit to build.

Two things the dump does *not*
contain, both worth knowing before you
need them: roles and their passwords
(they live at cluster level, outside
any one database — `pg_dumpall` is
the cluster-wide sibling, named here,
not run), and nothing about the
*server's* configuration. The restore
below works because the `librarian`
role still exists in the cluster; the
dump recreates what the role owns.

## Drop, recreate, replay

```sql
-- as the superuser, connected to a different database
DROP DATABASE seedlib;
CREATE DATABASE seedlib OWNER librarian;
```

(The drop is the superuser's job in
this lab for a mundane reason: you
cannot drop the database you are
standing in, and the owner was
connected to it.)

```text
$ psql -h 127.0.0.1 -p 5433 -U librarian -d seedlib -f seedlib-dump.sql
```

The script replays quietly under `-q` —
what surfaces is a handful of `setval`
results (500000, 12, 6, 6): the
identity sequences being restored to
where they left off, so the next
insert doesn't collide with restored
rows. Then `\dt` shows the four tables
back, all owned by `librarian`.

## The proof, after

Same aggregate script, same database
name, new incarnation:

```text
  table_name  | row_count
--------------+-----------
 loan_history |    500000
 loans        |        10
 members      |         6
 seed_packets |         6

 members_checksum: c06475d07487f83324fbc44039ef0e15
 loans_checksum:   f4abecd92adc6f5bad70e67748634c43
 total_packets_on_hand: 80
```

Identical — counts, both checksums,
and the total. Not "the restore
printed no errors": the *data itself*
compares equal, which is the only
evidence a backup deserves to be
believed on.

**Check:** your own loop, smaller:
`pg_dump` your lab database, note
`SELECT count(*)` on one table, drop
and restore, count again. If you skip
the "before" count, you have performed
a ritual, not a verification.

## What about the other kind of backup?

`pg_dump` is the *logical* kind. The
other kind — physical copies of the
data directory, base backups, and
write-ahead-log archiving for
point-in-time recovery — exists for
bigger databases and tighter recovery
windows, and is named in chapter 10
rather than run here. For a database
this size, on one machine, the dump
*is* the backup plan; the discipline
that matters is the loop above, run
before you need it.

## What this chapter established

- `pg_dump` renders a database as a
  portable SQL script: structure,
  constraints, indexes, data.
- The loop that proves a backup:
  measure → dump → drop → recreate →
  replay → measure again, identical.
- Roles live outside a single-database
  dump; sequences come back set to
  continue where they left off.
