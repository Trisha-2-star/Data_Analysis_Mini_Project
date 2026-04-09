-- Q1: Last booked room per user
SELECT user_id, room_no
FROM bookings b1
WHERE booking_date = (
    SELECT MAX(booking_date)
    FROM bookings b2
    WHERE b1.user_id = b2.user_id
);

-- Q2: Booking billing in Nov 2021
SELECT bc.booking_id,
       SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 11 AND YEAR(bc.bill_date) = 2021
GROUP BY bc.booking_id;

-- Q3: Bills > 1000 in Oct 2021
SELECT bc.bill_id,
       SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 10 AND YEAR(bc.bill_date) = 2021
GROUP BY bc.bill_id
HAVING bill_amount > 1000;

-- Q4: Most & least ordered item per month
SELECT *
FROM (
    SELECT MONTH(bc.bill_date) AS month,
           bc.item_id,
           SUM(bc.item_quantity) AS total_qty,
           RANK() OVER (PARTITION BY MONTH(bc.bill_date)
                        ORDER BY SUM(bc.item_quantity) DESC) AS rnk_desc,
           RANK() OVER (PARTITION BY MONTH(bc.bill_date)
                        ORDER BY SUM(bc.item_quantity) ASC) AS rnk_asc
    FROM booking_commercials bc
    GROUP BY MONTH(bc.bill_date), bc.item_id
) t
WHERE rnk_desc = 1 OR rnk_asc = 1;

-- Q5: 2nd highest bill per month
SELECT *
FROM (
    SELECT MONTH(bc.bill_date) AS month,
           bc.bill_id,
           SUM(bc.item_quantity * i.item_rate) AS bill_amount,
           RANK() OVER (PARTITION BY MONTH(bc.bill_date)
                        ORDER BY SUM(bc.item_quantity * i.item_rate) DESC) AS rnk
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    GROUP BY MONTH(bc.bill_date), bc.bill_id
) t
WHERE rnk = 2;