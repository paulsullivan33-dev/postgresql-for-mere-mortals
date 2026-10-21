# Querying

With tables standing, the fixture goes
in: six members, six seed packets, ten
loans for the fictional Maple Street
Seed Library (`examples/seed-data.sql`).
Then the questions a seed librarian
actually asks. If you know the SQLite
guide's SQL, all of this is the same
language — the new part is where it
runs: against a server, as a role, in a
database with rules.

One piece of housekeeping first. The
constraint chapter left a test row
behind, and failed inserts had burned
some identity numbers — writing loans
that refer to "member 1" by hand is
only honest if member 1 is who the file
says it is. Fixture loaders everywhere
solve this the same way:

```sql
TRUNCATE members, seed_packets, loans RESTART IDENTITY CASCADE;
```

`TRUNCATE` empties the tables;
`RESTART IDENTITY` puts the numbering
back at 1; `CASCADE` acknowledges the
foreign keys between them. Then the
seed file runs clean — each multi-row
`INSERT` answers with how many rows it
added (`INSERT 0 6`, `INSERT 0 6`,
`INSERT 0 10`).

## Reading rows back

The plain listing is the SQL you
already expect:

```sql
SELECT member_id, full_name, email FROM members ORDER BY member_id;
```

```text
 member_id |   full_name   |           email
-----------+---------------+---------------------------
         1 | Mara Ellison  | mara.ellison@example.org
         2 | Dev Patel     | dev.patel@example.org
         3 | June Okafor   | june.okafor@example.org
...
(6 rows)
```

## The loans still out: a three-table JOIN

"What's still borrowed?" lives in no
single table: loans know dates and
numbers; names live in `members`, crop
names in `seed_packets`. A **join**
stitches rows together on matching
keys:

```sql
SELECT m.full_name, p.crop, p.variety, l.borrowed_on
FROM loans AS l
JOIN members AS m ON m.member_id = l.member_id
JOIN seed_packets AS p ON p.packet_id = l.packet_id
WHERE l.returned_on IS NULL
ORDER BY l.borrowed_on;
```

```text
  full_name   |  crop  |     variety     | borrowed_on
--------------+--------+-----------------+-------------
 Mara Ellison | Peas   | Sugar Snap      | 2026-03-02
 June Okafor  | Tomato | Cherokee Purple | 2026-03-09
 Tomas Rivera | Carrot | Nantes          | 2026-03-12
 Walt Freeman | Tomato | Cherokee Purple | 2026-03-18
 Mara Ellison | Beans  | Provider        | 2026-03-22
(5 rows)
```

Two moves to notice: `returned_on IS
NULL` is how "not yet returned" is
spelled (NULL is not a value, so it is
tested with `IS`, never `=`), and an
ordinary `JOIN` keeps only rows that
match on *both* sides.

## Counting by group: GROUP BY

```sql
SELECT p.crop, count(*) AS times_borrowed
FROM loans AS l
JOIN seed_packets AS p ON p.packet_id = l.packet_id
GROUP BY p.crop
ORDER BY times_borrowed DESC, p.crop;
```

```text
  crop   | times_borrowed
---------+----------------
 Tomato  |              3
 Beans   |              2
 Peas    |              2
 Carrot  |              1
 Kale    |              1
 Lettuce |              1
```

`GROUP BY` collapses each crop's loans
into one row, and `count(*)` counts the
rows in each group.

## Keeping the empty groups: LEFT JOIN

"How active is each member?" asked
with an ordinary join would quietly
drop any member with no loans — the
answer would look complete and be
wrong. A `LEFT JOIN` keeps every member
row, with nothing (`NULL`) in the loan
columns where there is no match, and
counting the joined key — not rows —
turns nothing into 0:

```sql
SELECT m.full_name, count(l.loan_id) AS total_loans
FROM members AS m
LEFT JOIN loans AS l ON l.member_id = m.member_id
GROUP BY m.full_name
ORDER BY total_loans DESC, m.full_name;
```

```text
   full_name   | total_loans
---------------+-------------
 Mara Ellison  |           3
 Dev Patel     |           2
 June Okafor   |           2
 Ingrid Larsen |           1
 Tomas Rivera  |           1
 Walt Freeman  |           1
(6 rows)
```

Every member appears. In this fixture
nobody sits at zero — but the query
would show them if they did, and that
is the difference between a report and
a rumor.

**Check:** ask for loans of one crop
only — add `WHERE p.crop = 'Tomato'`
before the `GROUP BY` in the per-crop
query and the answer is a single row,
Tomato 3. Filters before grouping
choose *which rows* form groups; that
ordering is most of everyday SQL.

## What this chapter established

- Multi-row INSERT reports its row
  counts; `TRUNCATE ... RESTART
  IDENTITY` is how a fixture load
  resets the stage honestly.
- `JOIN ... ON` stitches tables by
  their keys; `WHERE returned_on IS
  NULL` is "still out."
- `GROUP BY` + `count(*)` answers
  per-group questions, and `LEFT JOIN`
  with `count(joined key)` keeps the
  empty groups visible as 0.
