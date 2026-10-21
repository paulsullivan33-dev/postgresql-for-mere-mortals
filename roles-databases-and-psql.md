# Roles, Databases, and psql

A fresh cluster knows exactly one role:
the superuser, `postgres`. Before any
data exists, somebody has to create the
roles that will own and use it, and the
databases they will use. That is this
chapter: two roles, one database, and a
first tour of `psql`.

## Creating roles and a database

The superuser connects over the local
Unix socket. On a Debian-style install
that sign-in is **peer authentication**:
the operating-system user `postgres`
*is* the database superuser, no password
asked. Other connections — over TCP —
use passwords, stored by the server as
scrambled verifiers. The lab keeps both
routes and uses each where it belongs.

```sql
CREATE ROLE librarian LOGIN PASSWORD 'lab-pass-librarian';
CREATE ROLE reader LOGIN PASSWORD 'lab-pass-reader';
CREATE DATABASE seedlib OWNER librarian;
```

Three ideas to take from those three
lines:

- `LOGIN` is what makes a role a user.
  Without it, a role is just a name
  permissions can be granted to.
- The passwords are invented for the
  lab and printed here because the lab
  is throwaway. Real passwords are not
  printed anywhere.
- A database has an **owner** — here,
  `librarian`. The owner can do anything
  inside their database, including
  granting pieces of it to others
  (chapter 7 lives on that).

Two of psql's own commands — **meta-
commands**, which start with a backslash
and are instructions to psql, not SQL —
show what now exists:

```text
\du
                             List of roles
 Role name |                         Attributes
-----------+------------------------------------------------------------
 librarian |
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS
 reader    |

\l
   Name    |   Owner   |
-----------+-----------+
 postgres  | postgres  |
 seedlib   | librarian |
 template0 | postgres  |
 template1 | postgres  |
```

(`\l` prints more columns than fit
here; the name and owner are the
point.) The two `template` databases
come with every cluster — new databases
are copied from `template1`, and the
guide never touches either.

The librarian then signs in as itself,
over TCP with its password, to prove
the second route works:

```text
$ psql -h 127.0.0.1 -p 5433 -U librarian -d seedlib \
      -c "SELECT current_user, current_database()"
 current_user | current_database
--------------+------------------
 librarian    | seedlib
(1 row)
```

`current_user` and `current_database()`
are the "where am I?" of SQL. Most
mysteries in a database session are
being somewhere else than you think.

## psql's backslash commands

Inside psql, lines beginning with `\`
never reach the server — psql handles
them itself. The everyday set:

- `\conninfo` — where this connection
  actually landed. In the lab it
  answered: *You are connected to
  database "seedlib" as user "librarian"
  on host "127.0.0.1" at port "5433"* —
  and, one line later, reported an **SSL
  connection (TLSv1.3)**: the package's
  default configuration encrypts even
  loopback TCP connections.
- `\l` — databases (above).
- `\du` — roles (above).
- `\dn` — **schemas**, namespaces inside
  a database. A fresh database has one,
  `public`, and every table in this
  guide lives in it.
- `\dt` — tables in the current schema.
  Before chapter 3 it answers honestly:

  ```text
  \dt
  error: Did not find any relations.
  ```

  No tables yet is a state, not a
  failure.
- `\d members` — describe one table
  (chapter 3 puts it to work).
- `\timing` — after each statement,
  psql prints how long it took
  (`Time: 1.686 ms` on `SELECT
  version();`). The index chapter uses
  the server-side version of the same
  idea.

**Check:** connect as `librarian` and
run `SELECT current_user,
current_database();`. If the answer
isn't `librarian | seedlib`, nothing
later in the guide will land where you
expect — fix the connection first; the
usual causes are the wrong port (5432
is the sleeping packaged cluster) or
the wrong `-d` database.

## What this chapter established

- Roles sign in (`LOGIN`), own things,
  and hold permissions; the superuser
  creates the first ones.
- Socket connections use peer
  authentication; TCP connections use
  passwords — the lab used both, on the
  record.
- psql's backslash commands inspect the
  world: `\conninfo`, `\l`, `\du`,
  `\dn`, `\dt`, `\d`, `\timing`.
