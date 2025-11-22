-- Cleaning & Data Manipulation

-- Replace NULL discounts with 0
SELECT COALESCE(discount, 0)
FROM orders;

 -- Extract year and month from order_date
SELECT order_date,
	EXTRACT(year FROM order_date::date) AS order_year,
	EXTRACT(month FROM order_date::date) AS order_month
FROM orders

-- Profit Margin 
SELECT order_id,
	product_id,
	profit/sales AS profit_margin
FROM orders;

-- Flag high-discount orders (> 0.3)
SELECT order_id,
	product_id,
	discount,
	CASE WHEN discount > 0.3 then 'Yes' ELSE 'No' END AS high_discount
FROM orders;

-- Empty quantity
WITH unit_price AS(
	SELECT DISTINCT product_id,
		discount,
		market,
		region,
		sales / quantity AS unit
	FROM orders
	WHERE quantity is not null)
	
SELECT DISTINCT o.product_id,
	o.discount,
	o.market,
	o.region,
	o.sales,
	o.quantity,
	ROUND(o.sales / u.unit) AS calculated_quantity
FROM orders o
JOIN unit_price u
ON o.product_id = u.product_id 
AND o.discount = u.discount
AND o.market = u.market
AND o.region = u.region
WHERE o.quantity IS NULL;


-- Data Exploration
-- List orders showing whether they were returned or not
SELECT o.order_id,
	product_id,
	o.market,
	COALESCE(returned, 'No') AS returned
FROM orders o
LEFT JOIN returned_orders r
ON o.order_id = r.order_id;

-- Count number of orders per market
SELECT market,
	COUNT(*) AS orders
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- top 10 products by total sales
SELECT product_id,
	SUM(sales) AS total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- total profit per person
SELECT
	person,
	SUM(profit) AS total_profit
FROM people p
JOIN orders o
ON p.region = o.region
GROUP BY 1
ORDER BY 2 DESC;


-- Summary Statistics
-- average sales, quantity, discount, profit
SELECT AVG(sales) As avg_sales,
	AVG(quantity) AS avg_quantity,
	AVG(profit) AS avg_profit
FROM orders;

-- Average sales per category
SELECT category,
	AVG(sales) AS avg_sales
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC;

-- Total returns percentage per region
SELECT region,
	COUNT(r.returned) AS total_returned,
	count(*) AS total_orders,
	ROUND(COUNT(r.order_id)::decimal / COUNT(*),3) * 100 AS return_precentage
FROM orders o
LEFT JOIN returned_orders r
ON o.order_id = r.order_id
GROUP BY 1
ORDER BY 1 ;


-- Window Functions
-- Rank products by total sales within each category
WITH products_rank AS(
	SELECT p.category,
		p.product_name,
		ROUND(SUM(o.sales)::NUMERIC,2) AS product_total_sales,
		ROUND(SUM(o.profit)::NUMERIC,2) AS product_total_profit,
		RANK() OVER(PARTITION BY category ORDER BY SUM(o.sales) DESC) AS product_rank
	FROM products p
	JOIN orders o
	ON p.product_id = o.product_id
	GROUP BY p.category, p.product_name
	ORDER BY p.category, product_total_sales DESC)
SELECT *
FROM products_rank;

-- running total of sales by order_date
WITH daily_sales AS(
	SELECT order_date,
	SUM(sales) AS sales
	FROM orders
	GROUP BY 1
)
SELECT order_date,
	sales,
	SUM(sales) OVER(ORDER BY order_date) AS running_total
FROM daily_sales
ORDER BY 1;

-- average sales over last 7 orders (moving average)
WITH daily_sales AS(
	SELECT order_date,
	SUM(sales) AS sales
	FROM orders
	GROUP BY 1
)
SELECT order_date,
	sales,
	AVG(sales) OVER(ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENt ROW) AS moving_avg_7_days
FROM daily_sales;

-- salesperson’s best-selling product
WITH salesperson AS(
	SELECT person,
		p.region,
		product_id,
		SUM(sales) AS total_sales,
		RANK() OVER(PARTITION BY person ORDER BY SUM(sales) DESC) AS best_selling
	FROM orders o
	RIGHT JOIN people p
	ON o.region = p.region
	GROUP BY  1,2,3)
SELECT person,
	region,
	product_id,
	total_sales
FROM salesperson
WHERE best_selling = 1;

-- profit share of each product within its category
WITH sales_by_category AS(
	SELECT p.product_id,
		product_name,
		category,
		SUM(profit) AS profit
	FROM orders o
	JOIN products p
	ON o.product_id = p.product_id
	GROUP BY 1,2,3
)
SELECT product_id,
	product_name,
	category,
	profit,
	profit / SUM(profit) OVER(PARTITION BY category) AS profit_share
FROM sales_by_category
ORDER BY 3;


-- Exploratory Data Analysis (EDA)
-- the top 10 products by total sales, including their category and sub_category
SELECT o.product_id,
	product_name,
	sub_category,
	category,
	ROUND(SUM(sales)::NUMERIC,2) AS total_sales
FROM orders o
JOIN products p
 ON o.product_id = p.product_id
GROUP BY 1, 2, 3, 4
ORDER BY total_sales DESC
LIMIT 10;

-- Category Sales Summary
SELECT category,
	SUM(sales) AS total_sales,
	AVG(discount) AS avg_discount,
	AVG(profit) AS avg_profit
FROM orders o 
JOIN products p
	ON o.product_id = p.product_id
GROUP BY 1 
ORDER BY 3 DESC;

-- Percent of Total
SELECT product_id,
	category,
	SUM(sales) AS sales,
	SUM(sales) / SELECT(SUM(sales) OVER(PARTITION BY category) FROM orders) AS percent_of_total
GROUP BY 1, 2
ORDER by 2, 4 DESC

-- products with sudden quantities spikes
WITH product_quantity AS(
	SELECT product_id,
		order_date,
		SUM(quantity) as daily_quantity
	FROM orders
	GROUP BY 1,2
)
,sparkes AS(
	SELECT product_id,
		order_date,
		daily_quantity,
		LAG(daily_quantity) OVER(PARTITION BY product_id ORDER BY order_date) AS prev_day,
		(daily_quantity - LAG(daily_quantity) OVER(PARTITION BY product_id ORDER BY order_date)) 
			/LAG(daily_quantity) OVER(PARTITION BY product_id ORDER BY order_date) AS spark_ratio
	FROM product_quantity
)
SELECT product_id,
	order_date,
	daily_quantity,
	prev_day,
	spark_ratio
FROM sparkes
WHERE daily_quantity > 2 * prev_day
	AND prev_day > 5;
    

-- Identify outliers in quantity using Z-score
WITH z_scores AS (
    SELECT 
        product_id,
        order_id,
        order_date,
        quantity,
	    CASE WHEN STDDEV(quantity) OVER (PARTITION BY product_id) = 0 THEN 0
        ELSE (quantity - AVG(quantity) OVER (PARTITION BY product_id))
        / STDDEV(quantity) OVER (PARTITION BY product_id) END AS z_score
    FROM orders
)
SELECT *
FROM z_scores
WHERE ABS(z_score) > 3
ORDER BY product_id, z_score DESC;


-- Data-Driven Business Decisions
-- Recommend which products to stop selling
SELECT o.product_id,
	SUM(o.sales) AS total_sales,
	SUM(o.profit) AS total_profit,
	COUNT(r.order_id)
FROM orders o
LEFT JOIN returned_orders r
ON o.order_id = r.order_id
GROUP BY 1
ORDER BY 3, 2, 4 DESC
LIMIT 10;

-- Compare profit vs. discount
SELECT product_id,
    CORR(discount, profit) AS profit_discount_corr
FROM orders
GROUP BY product_id
ORDER BY 2 DESC