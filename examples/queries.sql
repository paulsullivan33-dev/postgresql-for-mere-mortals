SELECT member_id, full_name, email FROM members ORDER BY member_id;
SELECT crop, variety, packets_on_hand FROM seed_packets ORDER BY crop;
SELECT m.full_name, p.crop, p.variety, l.borrowed_on
FROM loans AS l
JOIN members AS m ON m.member_id = l.member_id
JOIN seed_packets AS p ON p.packet_id = l.packet_id
WHERE l.returned_on IS NULL
ORDER BY l.borrowed_on;
SELECT p.crop, count(*) AS times_borrowed
FROM loans AS l
JOIN seed_packets AS p ON p.packet_id = l.packet_id
GROUP BY p.crop
ORDER BY times_borrowed DESC, p.crop;
SELECT m.full_name, count(l.loan_id) AS total_loans
FROM members AS m
LEFT JOIN loans AS l ON l.member_id = m.member_id
GROUP BY m.full_name
ORDER BY total_loans DESC, m.full_name;
