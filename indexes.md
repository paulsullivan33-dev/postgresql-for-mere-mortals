# Indexes

An **index** is a lookup structure the
server maintains next to a table — the
book's index, not the table of
contents. With one, finding rows by a
column stops meaning "read every row
and keep the matches." This chapter
measures that difference instead of
asserting it: a planted table of
**500,000 rows**, one question, asked
before and after `CREATE INDEX`, with
the server timing itself.

## The planted table

`loan_history` is the seed library's
pretend archive: half a million loans,
member numbers cycling 1–500, so each
of 500 members owns exactly 1,000 rows
(`examples/big-table.sql` builds it
with `generate_series`). The table
itself occupies 36 MB.

```text
SELECT count(*) AS history_rows FROM loan_history;
    500000
```

The question, both times: *how many
history rows belong to member 123?*
The honest answer is 1,000. The
interesting part is the work.

## Before: read everything

`EXPLAIN ANALYZE` runs the statement
and reports the plan the **planner** —
the part of the server that chooses
*how* to answer — actually used:

```text
 Finalize Aggregate  (actual time=47.539..50.628 rows=1)
   ->  Gather  (Workers Planned: 2)
         ->  Partial Aggregate
               ->  Parallel Seq Scan on loan_history
                     Filter: (member_id = 123)
                     Rows Removed by Filter: 166333
 Planning Time: 0.399 ms
 Execution Time: 50.717 ms
```

With no index on `member_id`, there is
only one way to answer: a **sequential
scan** — read all 500,000 rows, keep
the 1,000 that match, throw the rest
away. The planner parallelised it
across two workers and it still took
**50.717 ms**, each worker discarding
166,333 rows to find its share. (The
`cost=` figures the plan also prints
are the planner's internal estimates,
in arbitrary units — useful for
comparing plans, meaningless as time.
The `actual time` and `Execution Time`
lines are the measurements.)

## The index, and the step everyone forgets

```sql
CREATE INDEX idx_loan_history_member ON loan_history (member_id);
VACUUM ANALYZE loan_history;
```

`CREATE INDEX` builds a B-tree (the
default kind) over `member_id`: sorted,
searchable, maintained on every future
write to the table. The second line is
the step whose absence explains most
"the index didn't help" stories:

- `ANALYZE` refreshes the statistics
  the planner decides with. Without
  fresh statistics it may not know the
  index is worth using.
- `VACUUM` marks the table's pages
  all-visible, which is what allows a
  count like ours to be answered **from
  the index alone**, without visiting
  the table rows at all.

## After: 0.327 ms

```text
 Aggregate  (actual time=0.252..0.252 rows=1)
   ->  Index Only Scan using idx_loan_history_member on loan_history
         Index Cond: (member_id = 123)
         Heap Fetches: 0
 Planning Time: 0.530 ms
 Execution Time: 0.327 ms
```

**Index Only Scan**, `Heap Fetches: 0`:
the planner walked straight down the
index to member 123's 1,000 entries,
counted them there, and never touched
the table. 50.717 ms became **0.327
ms** — about 155 times faster, on this
table, on this machine, measured by
the server itself. Your numbers will
differ; the *shape* — read-everything
versus go-straight-there — is the
portable part.

A second shape, for contrast: fetching
ten of the member's rows (sorted by
date) used a **Bitmap Heap Scan** over
the same index — collect the matching
row locations from the index first,
then visit the table pages once each —
4.667 ms. Different question, different
plan, same index. The planner chooses
per question; your job is to give it
the index and the statistics, and let
`EXPLAIN ANALYZE` show you what it
decided.

## The honest costs

An index is not free, and this guide
won't pretend otherwise:

- It occupies disk next to the table,
  and every `INSERT` and `UPDATE` must
  maintain it. Indexes on columns
  nobody filters by are pure overhead.
- On a small table the planner will
  often ignore an index entirely —
  reading a few pages directly is
  cheaper than consulting a structure
  about them. The lab's first attempt
  at this chapter used 50,000 rows and
  got timings too close and noisy to
  teach from; 500,000 made the effect
  unmissable. Scale decides whether an
  index matters, which is why this
  chapter planted scale.
- The primary keys you met in chapter 3
  were indexes all along — `PRIMARY
  KEY` builds one automatically. What
  this chapter added is the *second*
  kind: an index on a column you merely
  ask about often.

**Check:** run the count query with
`EXPLAIN ANALYZE` twice in a row. The
plan should be the Index Only Scan
both times, and the second run's time
is the warmer, honester one to quote.

## What this chapter established

- Without an index: a parallel
  sequential scan of 500,000 rows,
  50.717 ms. With one, plus `VACUUM
  ANALYZE`: an index-only scan, heap
  fetches 0, 0.327 ms.
- `EXPLAIN ANALYZE` is how you know —
  plan shape first, timings second,
  estimates labelled as estimates.
- Indexes trade disk and write speed
  for read speed, and only pay off
  where the questions actually filter.
