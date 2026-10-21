# What PostgreSQL Is

PostgreSQL (often just "Postgres") is a
**database server**. That one word —
server — is the idea this whole guide
hangs on, so it is worth being precise
about what it means.

A server is a program that runs all the
time, owns a set of data files nobody
else touches, and answers requests over
a connection. Your program does not open
the data file; it *asks the server*, in
a language called SQL, and the server
checks who is asking, applies the rules,
and answers. Several programs can ask at
once, from several machines. The server
keeps the whole thing consistent.

That is a different shape from the two
database guides next to this one on the
shelf:

- **SQLite** is a library and a file. No
  server, no sign-in, no network — one
  program, one file, and it is superb at
  exactly that job.
- **Redis** is a server, but memory-first:
  it trades durability and rich querying
  for speed, and works best as a layer in
  front of storage like this.
- **PostgreSQL** is the general-purpose
  system of record: relational tables,
  real constraints, sign-ins with
  permissions, transactions, and forty
  years of being the place data lives
  when it has to be *right*.

## The three nouns

Everything you will meet is one of
three things:

- A **cluster** is one running server,
  with one data directory, one port, and
  one set of configuration files. ("Cluster"
  here means one server installation —
  not several machines; the multi-machine
  meaning is chapter 10's territory.)
- A **database** is a named container
  inside a cluster, holding tables. One
  cluster holds many databases, which
  cannot see inside each other.
- A **role** is who is asking. A role
  with `LOGIN` is what other systems call
  a user. Roles own things and are
  granted permissions; one special role,
  the **superuser**, can do everything.

The tool you type at is **psql**, the
command-line client that ships with the
server. Programs connect with the same
protocol psql uses; nothing in this
guide needs anything else.

## Installing, and the lab cluster

The lab installed the Ubuntu package:

```text
$ apt-get install -y postgresql
$ psql --version
psql (PostgreSQL) 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)
```

The package creates a default cluster
named `main`, on the standard port
**5432**, and the install environment
refused to auto-start it. You can see
both clusters this guide ends up with
using the distribution's own listing:

```text
$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory              Log file
16  main    5432 down   postgres /var/lib/postgresql/16/main /var/log/postgresql/postgresql-16-main.log
```

The lab never starts or reconfigures
`main`. Everything happens in a second
cluster of the lab's own — and getting
there taught the first real lesson.
PostgreSQL's server refuses to run as
the root user, by design, and the
textbook tool for making a data
directory says so in plain words:

```text
$ /usr/lib/postgresql/16/bin/initdb -D data/try1
initdb: error: cannot be run as root
initdb: hint: Please log in (using, e.g., "su") as the (unprivileged) user that will own the server process.
```

In this build sandbox, handing a
directory in the workspace to the
`postgres` user was refused too
(`chown`: "Operation not permitted" —
the sandbox's guard, not PostgreSQL's).
So the lab took the route the
distribution provides for exactly this:
a second cluster, created the Debian
way, on a nonstandard port:

```text
$ pg_createcluster 16 lab --port=5433
$ pg_ctlcluster 16 lab start
$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory              Log file
16  lab     5433 online postgres /var/lib/postgresql/16/lab  /var/log/postgresql/postgresql-16-lab.log
16  main    5432 down   postgres /var/lib/postgresql/16/main /var/log/postgresql/postgresql-16-main.log
$ pg_isready -h 127.0.0.1 -p 5433
127.0.0.1:5433 - accepting connections
```

Two clusters, two ports, two data
directories, no interference: `main`
stays down and untouched for the entire
guide, and `lab` is the throwaway the
chapters work in. On your own machine,
`pg_createcluster` — or simply the
package's default cluster, started with
`pg_ctlcluster 16 main start` — is the
same idea with less sandbox in the way.

**Check:** `pg_lsclusters` should show
your cluster `online` and its port.
Every command in this guide after this
chapter connects to port **5433**; the
port number in the command is what
keeps the lab the lab.

## What this chapter established

- PostgreSQL is a server that owns the
  data; clients ask in SQL and the
  server enforces the rules.
- Cluster, database, role: the three
  nouns everything else is built from.
- The lab is its own cluster on port
  5433, PostgreSQL 16.15, and the
  packaged cluster on 5432 was left
  exactly as the package made it.
