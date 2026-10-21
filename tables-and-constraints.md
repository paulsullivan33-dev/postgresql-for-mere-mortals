# Tables and Constraints

The seed library needs three tables:
members, the seed packets they borrow,
and the loans that join them. This
chapter builds them — and then spends
most of its length on the part tutorials
skip: what happens when data breaks the
rules. The full schema ships as
`examples/schema.sql`; what follows is
the same file, discussed.

## The three tables

```sql
CREATE TABLE members (
    member_id  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name  text NOT NULL,
    email      text NOT NULL UNIQUE,
    joined_on  date NOT NULL DEFAULT CURRENT_DATE,
    active     boolean NOT NULL DEFAULT true
);

CREATE TABLE seed_packets (
    packet_id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    crop            text NOT NULL,
    variety         text NOT NULL,
    packets_on_hand integer NOT NULL CHECK (packets_on_hand >= 0),
    UNIQUE (crop, variety)
);

CREATE TABLE loans (
    loan_id     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id   integer NOT NULL REFERENCES members (member_id),
    packet_id   integer NOT NULL REFERENCES seed_packets (packet_id),
    borrowed_on date NOT NULL DEFAULT CURRENT_DATE,
    returned_on date,
    CHECK (returned_on IS NULL OR returned_on >= borrowed_on)
);
```

The types are the plain set —
`integer`, `text`, `date`, `boolean`.
The interesting words are the
**constraints**, the rules the server
will enforce on every write, from every
client, forever:

- `PRIMARY KEY` — this column identifies
  the row; it can never be empty or
  repeated. `GENERATED ALWAYS AS
  IDENTITY` means the server numbers the
  rows itself (1, 2, 3, …); you never
  supply the number.
- `NOT NULL` — the column must have a
  value in every row.
- `UNIQUE` — no two rows may share this
  value (one member per email; one
  packet row per crop-and-variety pair).
- `DEFAULT` — what to use when the
  insert doesn't say.
- `CHECK (...)` — a condition every row
  must satisfy: stock can never go
  negative; a return can't predate its
  loan.
- `REFERENCES` (a **foreign key**) — this
  value must exist as a key over there:
  a loan's member and packet must be
  real rows.

`\d loans` shows the table as the server
understood it — columns, the index the
primary key quietly built, the check,
and both foreign keys. That readback is
the habit to build: never trust that
the table in your head matches the one
on the server; `\d` is how you ask.

## The five refusals

Now the doors get pushed. One honest
insert succeeds. Then five inserts each
break a different rule, and each is
refused in the server's own words:

```text
INSERT INTO members (full_name, email) VALUES ('Copy Cat', 'test@example.org');
ERROR:  duplicate key value violates unique constraint "members_email_key"
DETAIL:  Key (email)=(test@example.org) already exists.
```

```text
INSERT INTO members (full_name, email) VALUES (NULL, 'noname@example.org');
ERROR:  null value in column "full_name" of relation "members" violates not-null constraint
```

```text
INSERT INTO seed_packets (crop, variety, packets_on_hand) VALUES ('Testcrop', 'Testvar', -3);
ERROR:  new row for relation "seed_packets" violates check constraint "seed_packets_packets_on_hand_check"
DETAIL:  Failing row contains (1, Testcrop, Testvar, -3).
```

```text
INSERT INTO loans (member_id, packet_id) VALUES (999, 1);
ERROR:  insert or update on table "loans" violates foreign key constraint "loans_member_id_fkey"
DETAIL:  Key (member_id)=(999) is not present in table "members".
```

```text
INSERT INTO loans (member_id, packet_id, borrowed_on, returned_on)
VALUES (1, 1, DATE '2026-04-10', DATE '2026-04-01');
ERROR:  new row for relation "loans" violates check constraint "loans_check"
```

Read an error properly: the first line
names the rule and the constraint; the
`DETAIL` line shows the offending
values. Notice what did *not* happen —
no partial writes, no error left for
the application to notice later, no
difference between a careful client and
a careless one. The rule lives with the
data. That is the argument for
constraints in one paragraph: validation
written in application code protects one
application; a constraint protects the
table from everything, including next
year's import script.

The final count proves the state after
all six attempts:

```text
 members | seed_packets | loans
---------+--------------+-------
       1 |            0 |     0
```

Exactly the one good row. (Sharp eyes
will spot a side effect in the error
details: the failed inserts burned
identity numbers — the second member
attempt shows number 3 in its failing
row. Identity sequences are not
transactional and never reuse numbers;
gaps are normal and mean nothing. The
querying chapter's fixture load deals
with this openly.)

**Check:** on your own copy of the
schema, run the negative-stock insert
and read the CHECK refusal; then insert
the same crop-and-variety pair twice
and meet the UNIQUE refusal on the
second. Either way, *a* constraint
answers in the server's words, and the
table holds only the rows that obeyed.

## What this chapter established

- A table is columns and types plus the
  constraints that police them.
- `PRIMARY KEY`, `UNIQUE`, `NOT NULL`,
  `CHECK`, `DEFAULT`, and `REFERENCES`
  each refused the matching bad row, in
  captured error text.
- Constraints protect the data from
  every writer, not just the careful
  ones — that is why they live in the
  database.
