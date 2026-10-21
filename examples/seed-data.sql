INSERT INTO members (full_name, email, joined_on) VALUES
    ('Mara Ellison',  'mara.ellison@example.org',  DATE '2025-11-03'),
    ('Dev Patel',     'dev.patel@example.org',     DATE '2025-11-03'),
    ('June Okafor',   'june.okafor@example.org',   DATE '2025-12-08'),
    ('Tomas Rivera',  'tomas.rivera@example.org',  DATE '2026-01-12'),
    ('Ingrid Larsen', 'ingrid.larsen@example.org', DATE '2026-01-19'),
    ('Walt Freeman',  'walt.freeman@example.org',  DATE '2026-02-02');

INSERT INTO seed_packets (crop, variety, packets_on_hand) VALUES
    ('Tomato',  'Cherokee Purple', 14),
    ('Kale',    'Winterbor',        9),
    ('Peas',    'Sugar Snap',      22),
    ('Beans',   'Provider',        17),
    ('Carrot',  'Nantes',          11),
    ('Lettuce', 'Buttercrunch',     8);

INSERT INTO loans (member_id, packet_id, borrowed_on, returned_on) VALUES
    (1, 1, DATE '2026-03-02', DATE '2026-03-29'),
    (1, 3, DATE '2026-03-02', NULL),
    (2, 2, DATE '2026-03-05', DATE '2026-04-01'),
    (3, 1, DATE '2026-03-09', NULL),
    (3, 4, DATE '2026-03-09', DATE '2026-03-30'),
    (4, 5, DATE '2026-03-12', NULL),
    (5, 6, DATE '2026-03-15', DATE '2026-04-05'),
    (6, 1, DATE '2026-03-18', NULL),
    (2, 3, DATE '2026-03-20', DATE '2026-04-10'),
    (1, 4, DATE '2026-03-22', NULL);
