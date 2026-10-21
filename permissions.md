# Permissions

Chapter 2 created a second role,
`reader`, and gave it nothing but a
password. This chapter finds out what
"nothing" means in practice — it is
more interesting than it sounds —
and then grants exactly one privilege
and watches the boundary move exactly
that far.

## The default: you may knock

`reader` can connect to `seedlib`.
Connecting is granted to every role by
default (`PUBLIC`, in the server's
vocabulary). But connecting is all it
can do:

```sql
-- connected as reader
SELECT member_id, full_name, email FROM members ORDER BY member_id;
```

```text
ERROR:  permission denied for table members
```

That is the whole philosophy in one
error: in PostgreSQL, owning a table
means *nobody else may touch it* until
the owner says so, specifically. No
ambient "well, they're signed in"
access. The error names the table;
chapter 11 shows its cousins.

## One grant, one door

The owner grants a single privilege,
on a single table, to a single role:

```sql
-- connected as librarian, the owner
GRANT SELECT ON members TO reader;
```

The identical read now succeeds —
member IDs, names, and emails, all
six rows. Nothing else about reader
changed. That is the granularity to
internalise: privileges are per
**role**, per **object**, per
**action**, and `GRANT` moves exactly
the one you name.

## Everything else is still refused

The same session, minutes later,
pushing on the neighbouring doors:

```sql
-- connected as reader
INSERT INTO members (full_name, email)
VALUES ('Sneaky Reader', 'sneaky@example.org');
-- ERROR:  permission denied for table members

SELECT loan_id, member_id, packet_id FROM loans LIMIT 3;
-- ERROR:  permission denied for table loans
```

The grant was `SELECT`, so writing is
refused — the same table, the same
role, a different action, a different
answer. And it was on `members`, so
`loans` is refused entirely. Two
separate walls, both still standing,
each with its own exact error text.

A few load-bearing details:

- **The owner and the superuser**
  stand outside this system: the owner
  can do anything to their own tables
  (including granting them away), and
  the superuser can do anything at
  all. Everyone else lives on grants.
- Grants compose: `GRANT SELECT,
  UPDATE`, `GRANT ... ON ALL TABLES`,
  granting to a role that other roles
  inherit from — the group-role
  pattern real systems are organised
  with. The lab demonstrates the atom;
  the molecules are the same statement
  with longer lists, and are named
  here rather than run.
- `REVOKE` is the mirror statement,
  and privileges can be inspected with
  `\z members` in psql (named, not run
  in the lab — the two refusals and
  the one success already pin the
  state down).

**Check:** as `reader`, `SELECT
count(*) FROM seed_packets;` — expect
`permission denied for table
seed_packets`. Then, as the owner,
`GRANT SELECT ON seed_packets TO
reader;` and the count answers 6. One
statement moved the boundary by one
table; verify that it moved by *no
more* — the `loans` read is still
refused.

## What this chapter established

- Connected is not permitted: by
  default a new role can sign in and
  do nothing else.
- `ERROR: permission denied for table
  members` is the default state, not a
  malfunction.
- `GRANT SELECT ON members TO reader`
  opened exactly one door — the read
  worked; the write to the same table
  and any touch of `loans` were still
  refused.
