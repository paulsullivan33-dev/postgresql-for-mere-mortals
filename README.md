# PostgreSQL for Mere Mortals

**PostgreSQL** is a database *server*:
one program that owns your data, speaks
SQL, and answers many programs at once,
each signed in as its own role with its
own permissions. Where SQLite is a file
and Redis is a memory, PostgreSQL is the
building both of those live in — the
default answer when the data matters,
several people or programs touch it, and
the rules about what counts as valid data
should be enforced by the database itself
and not by everyone's good intentions.

Those rules are this guide's spine. Its
third chapter builds three tables and
then pushes on every door: a duplicate
email, a missing name, a negative stock
count, a loan for a member who doesn't
exist, a return dated before the loan —
five refusals, each printed in the
server's own words. Later chapters roll a
transaction back and watch the data not
change, plant half a million rows and
measure an index turning a 50.7-millisecond
question into a 0.327-millisecond one,
deny a reader and then grant exactly one
privilege, and dump the whole database,
destroy it, and prove the restore with
checksums.

Everything here is practised on a
throwaway lab cluster: PostgreSQL
**16.15** from the Ubuntu package,
running as its own cluster on the
nonstandard port **5433**, so the
package's own cluster on 5432 is never
started or changed. The lab's data is a
fictional community seed library —
members, seed packets, and loans, plus
the planted history table the index
chapter measures. Every command quoted
was run against that cluster and
captured; `criteria.md` keeps the ledger,
including the timings, the checksums, and
what was only described, not run.

## What this guide covers

- [**What PostgreSQL is**](what-postgresql-is.md) —
  a server, not a file; clusters,
  databases, and roles; installing it;
  and why the lab runs on port 5433
- [**Roles, databases, and psql**](roles-databases-and-psql.md) —
  CREATE ROLE and CREATE DATABASE,
  peer versus password sign-in, and
  psql's backslash commands
- [**Tables and constraints**](tables-and-constraints.md) —
  CREATE TABLE with PRIMARY KEY, UNIQUE,
  NOT NULL, CHECK, and FOREIGN KEY —
  and the five error messages when each
  one refuses bad data
- [**Querying**](querying.md) —
  INSERT, SELECT, WHERE, JOIN,
  GROUP BY, and the LEFT JOIN that
  keeps members with no loans
- [**Transactions**](transactions.md) —
  BEGIN, COMMIT, ROLLBACK, and the
  poisoned transaction that refuses
  everything until it is rolled back
- [**Indexes**](indexes.md) —
  EXPLAIN ANALYZE on 500,000 planted
  rows: a parallel sequential scan at
  50.7 ms, then an index-only scan at
  0.327 ms, and what VACUUM had to do
  with it
- [**Permissions**](permissions.md) —
  a second role denied with the
  server's exact words, then granted
  SELECT on one table — and still
  refused everything else
- [**Backup and restore**](backup-and-restore.md) —
  pg_dump to a file, the database
  dropped and recreated, the dump
  replayed, and row counts plus md5
  checksums compared before and after
- [**Running the server**](running-the-server.md) —
  clusters as the unit of management,
  the settings in force read back,
  logs, sizes, and stopping cleanly
- [**The honest limits**](the-honest-limits.md) —
  what one cluster on one machine is
  not: replication, high availability,
  managed cloud PostgreSQL, extensions,
  and tuning, named plainly
- [**Troubleshooting**](troubleshooting.md) —
  symptom → fix for the failures the
  lab produced, from "cannot be run
  as root" to "current transaction
  is aborted"
- [**Glossary**](glossary.md) — the
  terms, collected in one place

## What it doesn't cover

Replication, failover, and connection
pooling — running several PostgreSQL
servers as one system — are named in
chapter 10 and left there: the lab is
one cluster, deliberately. The managed
services (RDS, Cloud SQL, Azure
Database) and the extension zoo (PostGIS
and friends) are likewise named, not
taught. Programming against PostgreSQL
from Python, Node, or anything else
belongs to those languages' guides; here
every statement is typed into `psql`,
which is where understanding starts
anyway.

## How to use this guide

Read chapters 1–4 in order; they stand
up the lab and the three ideas
everything else leans on (a server owns
the data, roles decide who may do what,
and constraints are rules the server
enforces). After that, chapters stand
alone — go to the problem you have. Keep
the lab cluster on its own port, and
when a chapter says **Check:**, run the
command: in this guide the checks are
the content, and most of them read a
number back out of the server and
compare it with what the chapter
promised.

Choosing between the database guides:
[SQLite for Mere
Mortals](https://paulsullivan33-dev.github.io/sqlite-for-mere-mortals/)
is the embedded end — one file, no
server, no roles. [Redis for Mere
Mortals](https://paulsullivan33-dev.github.io/redis-for-mere-mortals/)
is the memory-first end — a cache and
queue layer, not the system of record.
This guide is the server in the middle:
the place data lives when it has to be
correct, shared, and still there after
the machine restarts.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [SQL for Mere Mortals](https://paulsullivan33-dev.github.io/sql-for-mere-mortals/)
- [SQLite for Mere Mortals](https://paulsullivan33-dev.github.io/sqlite-for-mere-mortals/)
- [Redis for Mere Mortals](https://paulsullivan33-dev.github.io/redis-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/postgresql-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/postgresql-for-mere-mortals/blob/main/LICENSE-CODE).
