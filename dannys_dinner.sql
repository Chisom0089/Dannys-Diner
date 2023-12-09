CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
SELECT *
FROM sales;

SELECT *
FROM menu;

SELECT *
FROM members;

-- What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(m.price) AS total_amount_spent
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY total_amount_spent DESC;

-- How many days has each customer visited the restaurant?

SELECT customer_id, COUNT (DISTINCT order_date) AS num_days
FROM sales AS s
GROUP BY customer_id;

-- What was the first item from the menu purchased by each customer?

SELECT s.customer_id, m.product_name, s.order_date
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
WHERE order_date = '2021-01-01'
GROUP BY customer_id, m.product_name, s.order_date
ORDER BY customer_id;

/* What is the most purchased item on the menu and 
how many times was it purchased by all customers?*/

SELECT COUNT(m.product_name) AS num_items, m.product_name
FROM menu AS m
JOIN sales AS s
ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY num_items DESC;

-- Which item was the most popular for each customer?

SELECT COUNT(m.product_name) AS num_items, m.product_name, s.customer_id
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY m.product_name, customer_id
ORDER BY customer_id;

-- Which item was purchased first by the customer after they became a member?

SELECT m.product_name, s.customer_id, s.order_date
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
WHERE (s.customer_id = 'A' AND order_date > '2021-01-07')
ORDER BY s.order_date 
LIMIT 1;

--Customer B first purchase after becoming a member

SELECT m.product_name, s.customer_id, s.order_date
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
WHERE (s.customer_id = 'B' AND order_date > '2021-01-09')
ORDER BY s.order_date 
LIMIT 1;

-- Which item was purchased just before the customer became a member?

SELECT m.product_name, s.customer_id, s.order_date
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
WHERE (s.customer_id = 'A' AND order_date < '2021-01-07')
ORDER BY s.order_date DESC;

--Customer B before becoming a member

SELECT m.product_name, s.customer_id, s.order_date
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
WHERE (s.customer_id = 'B' AND order_date < '2021-01-09')
ORDER BY s.order_date DESC
LIMIT 1;

/*What is the total items and amount spent for each member before
they became a member?*/

SELECT COUNT(m.product_name) AS num_items, SUM(m.price) AS amount_spent, s.customer_id
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
WHERE (s.customer_id = 'A' AND order_date < '2021-01-07') OR (s.customer_id = 'B' AND order_date < '2021-01-09')
GROUP BY s.customer_id;


/*If each $1 spent equates to 10 points and Sushi has a 2X multiplier 
- how many points would each customer have*/

SELECT s.customer_id,
SUM (CASE 
 	WHEN m.product_name = 'sushi' THEN 2 * m.price
		  ELSE m.price END) * 10 AS customer_points
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

/* In the first week after a customer joins the program (including their join date),
they earn 2X points on all items, not just Sushi - How many points do customers A and B
have at the end of January */

SELECT customer_id,
SUM(CASE WHEN s.order_date BETWEEN mem.join_date AND mem.join_date + interval '6 days' THEN 2 * m.price 
	 WHEN product_name = 'sushi' THEN 2 * m.price ELSE m.price END) * 10 AS total_points
FROM sales AS s
JOIN menu AS m
USING (product_id)
JOIN members AS mem
USING (customer_id)
WHERE order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY s.customer_id
ORDER BY customer_id;

-- Join All Thing

WITH member_status AS
	(SELECT s.customer_id, s.order_date, m.product_name, m.price,
 	 CASE WHEN s.order_date >= mem.join_date THEN 'Y' ELSE 'N'
	 END AS member_program
FROM sales AS s
LEFT JOIN menu AS m
USING (product_id)
LEFT JOIN members AS mem
USING (customer_id)
ORDER BY customer_id, order_date
)
SELECT *
FROM member_status;

WITH member_status AS
	(SELECT s.customer_id, s.order_date, m.product_name, m.price,
 	 CASE WHEN s.order_date >= mem.join_date THEN 'Y' ELSE 'N'
	 END AS member_program
FROM sales AS s
LEFT JOIN menu AS m
USING (product_id)
LEFT JOIN members AS mem
USING (customer_id)
ORDER BY customer_id, order_date
)
SELECT *, 
CASE WHEN member_program = 'N' THEN null ELSE
RANK() OVER(PARTITION BY customer_id, member_program ORDER BY order_date) END
AS ranking
FROM member_status;


 
   
 
