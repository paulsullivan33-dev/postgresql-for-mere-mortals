# Running the Server

Everything so far happened *inside* the
server. This short chapter steps outside
it: what a cluster is made of on disk,
how you ask the running server what its
settings actually are, and how the lab
was shut down with the room left tidy.

## The cluster is the unit

On this machine there are two clusters,
and `pg_lsclusters` is the roster:

```text
Ver Cluster Port Status Owner    Data directory              Log file
16  lab     5433 online postgres /var/lib/postgresql/16/lab  /var/log/postgresql/postgresql-16-lab.log
16  main    5432 down   postgres /var/lib/postgresql/16/main /var/log/postgresql/postgresql-16-main.log
```

Each cluster is three things: a **data
directory** (the files, owned by the
`postgres` system user), a
**configuration directory**
(`/etc/postgresql/16/lab/` here — the
Debian layout keeps config beside
`/etc`, data under `/var/lib`), and a
**port** it listens on. `pg_ctlcluster
16 lab start` and `... stop` are the
levers; on a machine with systemd, the
same clusters are also services
(`postgresql@16-lab`), and the two
control routes agree about the state.

## Read the settings in force, not the file

Configuration files say what was
*asked* for; the running server says
what *is*. `SHOW` asks:

```text
SHOW port;              -- 5433
SHOW data_directory;    -- /var/lib/postgresql/16/lab
SHOW listen_addresses;  -- localhost
SHOW max_connections;   -- 100
```

Those four answers describe the lab
cluster completely: its own port, its
own directory, listening only on this
machine (`localhost` — nothing on the
network can even knock), and the
package's default connection ceiling.
When reality and the config file
disagree, believe `SHOW` and go find
out why they disagree.

Sizes are a question too, answered
from inside:

```text
SELECT pg_size_pretty(pg_database_size('seedlib'));
    47 MB
```

47 MB for the seed library — nearly
all of it the planted half-million-row
history table and its index, which is
the usual shape of real databases: the
archive outweighs the working data.

## Logs

The server's log is a plain file
(`/var/log/postgresql/postgresql-16-lab.log`
for this cluster). Its first lines,
from chapter 1's start, are the
healthy pattern to recognise:

```text
LOG:  listening on IPv4 address "127.0.0.1", port 5433
LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5433"
LOG:  database system is ready to accept connections
```

Errors you cause as a client (every
refusal in chapters 3–7) go back to the
client; the log is where the *server's*
own story goes — starts, stops,
checkpoints, and anything the server
itself is unhappy about. First stop
when a connection is refused: is the
cluster up at all? `pg_lsclusters`
answers before the log needs opening.

## Stopping cleanly, and what remains

The lab ended on purpose:

```text
$ pg_ctlcluster 16 lab stop
$ pg_lsclusters
16  lab     5433 down   postgres /var/lib/postgresql/16/lab
16  main    5432 down   postgres /var/lib/postgresql/16/main
$ ss -ltn   -- nothing listening on 5432 or 5433
```

Final state, declared the way the
series likes it: the `postgresql`
package stays installed; the packaged
`main` cluster was never started or
reconfigured at any point in the
guide; the lab cluster still exists on
disk, stopped, with the seed library
inside it — restart it with
`pg_ctlcluster 16 lab start`, or remove
it entirely with `pg_dropcluster 16
lab` (named, not run: the guide leaves
its lab standing, switched off).

**Check:** `SHOW listen_addresses;` on
any PostgreSQL you inherit. If it says
`*` and you didn't expect the whole
network, you have found your first
administration task — and chapter 10
explains why the lab's `localhost` is
the right default to start from.

## What this chapter established

- A cluster = data directory + config
  + port, listed by `pg_lsclusters`
  and levered by `pg_ctlcluster`.
- `SHOW` reads the settings in force;
  trust it over the file.
- The server's log is a plain file;
  "ready to accept connections" is the
  healthy signature.
- The lab's end state is explicit:
  lab cluster stopped, packaged
  cluster untouched throughout.
