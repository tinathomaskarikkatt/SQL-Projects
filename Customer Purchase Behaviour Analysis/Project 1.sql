create database  Project_1;

use Project_1;

CREATE TABLE P_Sales (
    userid INT NOT NULL,
    created_date DATE NOT NULL,
    product_id INT NOT NULL,

    -- Foreign Keys
    FOREIGN KEY (userid) REFERENCES P_user_name(userid),
    FOREIGN KEY (product_id) REFERENCES P_product(product_id)
);

CREATE TABLE P_user_name (
    userid INT PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL
);

CREATE TABLE P_users (
    userid INT PRIMARY KEY,
    signup_date DATE NOT NULL,
    FOREIGN KEY (userid) REFERENCES P_user_name(userid)
);

CREATE TABLE P_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price INT NOT NULL
);

CREATE TABLE P_golduser_signup (
    userid INT PRIMARY KEY,
    gold_signup_date DATE NOT NULL,
    FOREIGN KEY (userid) REFERENCES P_user_name(userid)
);


INSERT INTO P_Sales (userid, created_date, product_id) VALUES
(1, '2017-04-19', 2),
(3, '2019-12-18', 1),
(2, '2020-07-20', 3),
(1, '2019-10-23', 2),
(1, '2018-03-19', 3),
(3, '2016-12-20', 2),
(1, '2016-11-09', 1),
(1, '2016-05-20', 3),
(2, '2017-09-24', 1),
(1, '2017-03-11', 2),
(1, '2016-03-11', 1),
(3, '2016-11-10', 1),
(3, '2017-12-07', 2),
(3, '2016-12-15', 2),
(2, '2017-11-08', 2),
(2, '2018-09-10', 3),
(4, '2019-05-01', 1),
(5, '2018-11-23', 3),
(6, '2017-06-30', 9),
(7, '2018-08-12', 8),
(8, '2019-03-19', 7),
(9, '2017-12-04', 6),
(10, '2018-09-22',2),
(4, '2020-08-17', 1),
(5, '2017-05-12',10),
(6, '2014-01-27',11),
(7, '2014-04-02', 7),
(8, '2020-12-15', 8),
(9, '2017-09-08', 8);

INSERT INTO P_product (product_id, product_name, price) VALUES
(1, 'Dal Makani', 160),
(2, 'Shahi Panner', 170),
(3, 'Butter Chicken', 340),
(4, 'Aloo Gobi', 150),
(5, 'Chole Bhature', 100),
(6, 'Fish Curry', 380),
(7, 'Chicken Tikka', 300),
(8, 'Mutton Biryani', 450),
(9, 'Veg Pulao', 200),
(10, 'Mango Lassi', 80),
(11, 'Gulab Jamun', 100);

INSERT INTO P_user_name VALUES
(1,'Anshul'),
(2,'Rohan'),
(3,'Shreya'),
(4,'Priya'),
(5,'Aryan'),
(6,'Sara'),
(7,'Sahil'),
(8,'Tanvi'),
(9,'Ritika'),
(10,'Gaurav');

INSERT INTO P_users VALUES
(1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11'),
(4,'2015-11-17'),
(10,'2016-01-02'),
(9,'2016-01-02'),
(7,'2013-04-02'),
(8,'2013-12-15'),
(5,'2015-09-08'),
(6,'2014-07-13');

INSERT INTO P_golduser_signup VALUES
(1, '2017-05-10'),  
(3, '2018-03-22'),  
(4, '2019-07-15'),  
(5, '2018-11-30'),  
(7, '2017-09-18');  

--Product with highest revenue
SELECT 
    p.product_name,
    SUM(p.price) AS total_revenue
FROM P_Sales s
JOIN P_product p 
    ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

--Butter Chicken gives the highest revenue of 1700
--Mango Lassi gives the lowest revenue of 80/--

-- 3 product with the highest sales revenue
SELECT TOP 3 
    p.product_name,
    SUM(p.price) AS total_revenue
FROM P_Sales s
JOIN P_product p 
    ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;
--Butter Chicken with 1700
--Shahi Paneer with 1360
-- Mutton Biriyani with 1350

--Users have signed up for the service and has taken the gold membership 
SELECT 
    (SELECT COUNT(*) FROM P_users) AS total_users,
    (SELECT COUNT(*) FROM P_golduser_signup) AS gold_users;

-- there are total of 10 users out of which 5 are gold user

SELECT 
    SUM(p.price) AS revenue_from_gold_users
FROM P_Sales s
JOIN P_product p 
    ON s.product_id = p.product_id
JOIN P_golduser_signup g 
    ON s.userid = g.userid;
--3830

--revenue generated from non_gold users

SELECT 
    SUM(p.price) AS revenue_from_non_gold_users
FROM P_Sales s
JOIN P_product p 
    ON s.product_id = p.product_id
WHERE s.userid NOT IN (
    SELECT userid FROM P_golduser_signup
);
--3060

-- Which users has been a gold user for the How much of time? 
SELECT 
    g.userid,
    u.user_name,
    g.gold_signup_date,
    DATEDIFF(YEAR, g.gold_signup_date, GETDATE()) AS years_as_gold_member
FROM P_golduser_signup g
JOIN P_user_name u
    ON g.userid = u.userid;
--Anshul and Sahil for 8 years
--Shreya and aryan for  7 years
-- Priya for 6 years

--popular product among gold users
SELECT TOP 1
    p.product_name,
    COUNT(*) AS times_ordered
FROM P_Sales s
JOIN P_product p 
    ON s.product_id = p.product_id
JOIN P_golduser_signup g 
    ON s.userid = g.userid
GROUP BY p.product_name
ORDER BY times_ordered DESC;
--dal makani

--sales revenue generated each year
SELECT 
    YEAR(s.created_date) AS sales_year,
    SUM(p.price) AS total_revenue
FROM P_Sales s
JOIN P_product p 
    ON s.product_id = p.product_id
GROUP BY YEAR(s.created_date)
ORDER BY sales_year;
-- highest-2017(1950)
--lowest-2014(400)

--sales revenue trend over the years
WITH YearlyRevenue AS (
    SELECT 
        YEAR(s.created_date) AS sales_year,
        SUM(p.price) AS total_revenue
    FROM P_Sales s
    JOIN P_product p 
        ON s.product_id = p.product_id
    GROUP BY YEAR(s.created_date)
)
SELECT 
    sales_year,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY sales_year) AS prev_year_revenue,
    (total_revenue - LAG(total_revenue) OVER (ORDER BY sales_year)) AS revenue_change,
    ROUND(
        (CAST(total_revenue AS FLOAT) - LAG(total_revenue) OVER (ORDER BY sales_year)) 
        / NULLIF(LAG(total_revenue) OVER (ORDER BY sales_year), 0) * 100, 2
    ) AS percent_change
FROM YearlyRevenue
ORDER BY sales_year;

-- Average Gold-signup compared to just sign up for the users
SELECT 
    COUNT(DISTINCT u.userid) AS total_users,
    COUNT(DISTINCT g.userid) AS gold_users,
    ROUND(
        (CAST(COUNT(DISTINCT g.userid) AS FLOAT) / COUNT(DISTINCT u.userid)) * 100, 2
    ) AS gold_signup_percentage
FROM P_users u
LEFT JOIN P_golduser_signup g
    ON u.userid = g.userid;

--No.of times gold member users have ordered
SELECT 
    g.userid,
    u.user_name,
    COUNT(s.product_id) AS total_orders
FROM P_golduser_signup g
JOIN P_Sales s 
    ON g.userid = s.userid
JOIN P_user_name u
    ON g.userid = u.userid
GROUP BY g.userid, u.user_name
ORDER BY total_orders DESC;

--Anshul with hishest orders of 7
--Shreya with second highest orders of 5
--Priya,Sahil and Aryan with 2 orders each

--Total amount of each customer spent on online food
SELECT 
    u.userid,
    un.user_name,
    SUM(p.price) AS total_amount_spent
FROM P_Sales s
JOIN P_product p 
    ON s.product_id = p.product_id
JOIN P_user_name un 
    ON s.userid = un.userid
JOIN P_users u
    ON s.userid = u.userid
GROUP BY u.userid, un.user_name
ORDER BY total_amount_spent DESC;

--Frequency of customer visits to the online platform
SELECT 
    u.userid,
    un.user_name,
    COUNT(s.created_date) AS visit_frequency
FROM P_Sales s
JOIN P_user_name un 
    ON s.userid = un.userid
JOIN P_users u
    ON s.userid = u.userid
GROUP BY u.userid, un.user_name
ORDER BY visit_frequency DESC;

--first order purchase by each customer 
SELECT 
    s.userid,
    un.user_name,
    MIN(s.created_date) AS first_order_date,
    p.product_name AS first_product
FROM P_Sales s
JOIN P_product p 
    ON s.product_id = p.product_id
JOIN P_user_name un 
    ON s.userid = un.userid
WHERE s.created_date = (
    SELECT MIN(s2.created_date)
    FROM P_Sales s2
    WHERE s2.userid = s.userid
)
GROUP BY s.userid, un.user_name, p.product_name;
--Dal Makani was the first orders of 4 users
--Chicken Tikka was the first order of 2 users

--Most purchased item on the menu and no.of times it was  purchased by all customers
SELECT TOP 1
    p.product_name,
    COUNT(*) AS times_purchased
FROM P_Sales s
JOIN P_product p 
    ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY times_purchased DESC;

--Shahi Paneer was the most purchased

-- Most popular item for each customer 
WITH UserProductCount AS (
    SELECT 
        s.userid,
        un.user_name,
        p.product_name,
        COUNT(*) AS order_count
    FROM P_Sales s
    JOIN P_product p 
        ON s.product_id = p.product_id
    JOIN P_user_name un 
        ON s.userid = un.userid
    GROUP BY s.userid, un.user_name, p.product_name
)
SELECT 
    u.userid,
    u.user_name,
    u.product_name,
    u.order_count
FROM UserProductCount u
WHERE u.order_count = (
    SELECT MAX(order_count)
    FROM UserProductCount up
    WHERE up.userid = u.userid
);

-- First Item purchased after becoming gold member
SELECT 
    g.userid,
    un.user_name,
    MIN(s.created_date) AS first_order_after_gold,
    p.product_name
FROM P_golduser_signup g
JOIN P_Sales s 
    ON g.userid = s.userid
JOIN P_product p 
    ON s.product_id = p.product_id
JOIN P_user_name un 
    ON g.userid = un.userid
WHERE s.created_date >= g.gold_signup_date
GROUP BY g.userid, un.user_name, p.product_name
HAVING MIN(s.created_date) = MIN(s.created_date);
--Dal Makani was the first order of 2 gold members

--Last product purchased before the member became a gold user
SELECT 
    g.userid,
    un.user_name,
    MAX(s.created_date) AS last_order_before_gold,
    p.product_name
FROM P_golduser_signup g
JOIN P_Sales s 
    ON g.userid = s.userid
JOIN P_product p 
    ON s.product_id = p.product_id
JOIN P_user_name un 
    ON g.userid = un.userid
WHERE s.created_date < g.gold_signup_date
GROUP BY g.userid, un.user_name, p.product_name
HAVING MAX(s.created_date) = MAX(s.created_date);

--Total amount spent by each member before gold membership
SELECT 
    g.userid,
    un.user_name,
    COUNT(s.product_id) AS total_orders_before_gold,
    SUM(p.price) AS total_amount_spent_before_gold
FROM P_golduser_signup g
JOIN P_Sales s 
    ON g.userid = s.userid
JOIN P_product p 
    ON s.product_id = p.product_id
JOIN P_user_name un 
    ON g.userid = un.userid
WHERE s.created_date < g.gold_signup_date
GROUP BY g.userid, un.user_name
ORDER BY total_amount_spent_before_gold DESC;

--Total amount spent by each member after gold membership
SELECT 
    g.userid,
    un.user_name,
    COUNT(s.product_id) AS total_orders_after_gold,
    SUM(p.price) AS total_amount_spent_after_gold
FROM P_golduser_signup g
JOIN P_Sales s 
    ON g.userid = s.userid
JOIN P_product p 
    ON s.product_id = p.product_id
JOIN P_user_name un 
    ON g.userid = un.userid
WHERE s.created_date >= g.gold_signup_date
GROUP BY g.userid, un.user_name
ORDER BY total_amount_spent_after_gold DESC;

--Transaction Rankings
SELECT 
    s.userid,
    un.user_name,
    s.created_date,
    p.product_name,
    CASE 
        WHEN s.created_date >= g.gold_signup_date THEN 
            CAST(RANK() OVER (PARTITION BY s.userid ORDER BY s.created_date) AS VARCHAR)
        ELSE 'NA'
    END AS gold_transaction_rank
FROM P_Sales s
JOIN P_product p 
    ON s.product_id = p.product_id
JOIN P_user_name un 
    ON s.userid = un.userid
LEFT JOIN P_golduser_signup g 
    ON s.userid = g.userid
ORDER BY s.userid, s.created_date;














