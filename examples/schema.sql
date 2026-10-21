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

\d members
\d seed_packets
\d loans
