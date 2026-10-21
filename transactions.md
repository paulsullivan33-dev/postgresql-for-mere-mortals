# Transactions

So far, every statement has stood on
its own: it worked, or it was refused,
and either way it was *done*. Real work
isn't like that. Recording a loan means
two changes — a row in `loans`, and one
fewer packet on the shelf — and "one
happened, the other didn't" is a broken
state. A **transaction** is PostgreSQL's
answer: a group of statements that
commits all together, or not at all.

Three transactions were run against the
fixture, and this chapter is their
record.

## Rollback: the change that un-happens

```sql
SELECT count(*) AS loans_before FROM loans;   -- 10
BEGIN;
INSERT INTO loans (member_id, packet_id, borrowed_on)
VALUES (2, 5, DATE '2026-04-15');
SELECT count(*) AS loans_inside_transaction FROM loans;   -- 11
ROLLBACK;
SELECT count(*) AS loans_after_rollback FROM loans;   -- 10
```

Inside the transaction, the new loan is
real: the same session counts 11. After
`ROLLBACK`, the count is 10 and the
insert is simply gone — not flagged,
not hidden, *gone*, as if typed in a
dream. Meanwhile, any *other* session
looking during the transaction would
never have seen 11 at all: uncommitted
work is private until it commits.

## Commit: the change that stays

```sql
BEGIN;
UPDATE seed_packets
SET packets_on_hand = packets_on_hand - 1
WHERE crop = 'Tomato';
COMMIT;
SELECT crop, variety, packets_on_hand FROM seed_packets
WHERE crop = 'Tomato';
```

```text
  crop  |     variety     | packets_on_hand
--------+-----------------+-----------------
 Tomato | Cherokee Purple |              13
```

Fourteen packets became thirteen, and
because the word was `COMMIT`, it
stays thirteen for every later reader —
this number (13, not 14) is the one the
backup chapter's totals are built on.

## The poisoned transaction

The third run is the one to internalise.
A statement inside a transaction fails:

```sql
BEGIN;
INSERT INTO loans (member_id, packet_id) VALUES (999, 1);
-- ERROR:  insert or update on table "loans" violates
-- foreign key constraint "loans_member_id_fkey"
-- DETAIL:  Key (member_id)=(999) is not present in table "members".
SELECT count(*) FROM loans;
-- ERROR:  current transaction is aborted, commands ignored
-- until end of transaction block
ROLLBACK;
```

After an error, the transaction is
**aborted**: PostgreSQL refuses every
further statement in it — even perfectly
good ones — until `ROLLBACK` ends it.
This surprises everyone once. The logic
is sound: the transaction's whole
promise is "all of this, exactly as
planned," and after a failure the plan
is no longer the thing being executed.
Rather than guess which later statements
still make sense, the server makes you
start the unit over. Applications that
use transactions seriously are built
around this: catch the error, roll
back, retry the whole unit if it is
worth retrying.

And the verification, as always: after
the rollback, `loans` still counts 10,
and the Tomato stock is still the 13
the committed transaction left — the
poisoned unit changed nothing at all.

**Check:** open psql, `BEGIN;`, insert
a loan for member 999, and read both
errors yourself. Then `ROLLBACK;` and
confirm `SELECT count(*) FROM loans;`
matches the count from before you
began. It will. That is the entire
point of the feature, and it is worth
feeling once with your own hands.

## What this chapter established

- `BEGIN` … `COMMIT` makes a group of
  statements land together; `ROLLBACK`
  makes them never have happened, with
  the counts to prove both.
- Uncommitted work is invisible to
  other sessions.
- One failed statement aborts the
  transaction: everything after it is
  refused until `ROLLBACK`. Design for
  retrying the whole unit, not for
  repairing it mid-flight.
