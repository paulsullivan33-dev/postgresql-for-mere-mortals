DROP TABLE IF EXISTS loan_history;
CREATE TABLE loan_history (
    history_id  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id   integer NOT NULL,
    packet_id   integer NOT NULL,
    borrowed_on date NOT NULL,
    returned_on date
);
INSERT INTO loan_history (member_id, packet_id, borrowed_on, returned_on)
SELECT 1 + (g % 500),
       1 + (g % 40),
       DATE '2024-01-01' + (g % 700),
       DATE '2024-01-01' + (g % 700) + 21
FROM generate_series(1, 500000) AS g;
SELECT count(*) AS history_rows FROM loan_history;
SELECT pg_size_pretty(pg_total_relation_size('loan_history')) AS table_size;
