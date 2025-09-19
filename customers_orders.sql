select *
from orders.orders;

alter table orders.orders
change `prouct_name` product_name text;

alter table orders.orders
modify column order_date date;

alter table orders.orders
add column o_date date;
UPDATE orders.orders 
SET o_date = STR_TO_DATE(order_date, '%m/%d/%Y');
select order_date, s_date
from orders.orders;
alter table orders.orders drop column o_date;
alter table orders.orders change column o_date order_date date;
alter table orders.orders add column s_date date;
UPDATE orders.orders
SET s_date = STR_TO_DATE(ship_date, '%m/%d/%Y');
alter table orders.orders drop column ship_date;
alter table orders.orders change column s_date ship_date date;

select *
from orders.orders;
-- total revenue
select round(sum(sales),3) as total_revenue
from orders.orders;
 
 -- Top customer by revenue
select 
	customer_id,
    customer_name,
    round(sum(sales),3) as revenue
from
	orders.orders
group by 1,2
order by 3 desc
limit 5;

-- product popularity
select 
	product_name,
    sum(quantity) as quantity
from
	orders.orders
group by 1
order by 2 desc
limit 10;

-- order fulfillment
select
	ship_mode,
    count(*) as number_orders
from 
	orders.orders
group by 1
order by 2 desc;

-- Discounted orders
select *
from orders.orders
where discount>0;

-- Revenue by region
select
	region,
    round(sum(sales),3) as revenue
from 
	orders.orders
group by 1
order by 2 desc;

-- Sales by product category 
select
	product_category,
    round(sum(sales),3) as revenue,
    round(sum(profit),3) as profit
from
	orders.orders
group by 1
order by 3 desc, 2 desc;

-- Order Prioritization
select 
	order_priority,
	round(avg(sales)) as revenue
from orders.orders
group by 1
order by 2 desc;

-- Customer Segment Analysis
select 
	customer_segment,
    round(avg(sales)) as revenue
from
	orders.orders
group by 1 order by 2 desc;

-- Customer Revenue Rank
select
	customer_name,
    region,
    round(sum(sales)) as revenue,
    RANK() OVER (PARTITION BY region ORDER BY round(sum(sales)) DESC) AS RevenueRank
from
	orders.orders
group by 
	1,2
order by 2 asc, 4 asc;

-- Sales trend analysis
with monthly as(
select
	product_category,
    month(order_date) as month,
    round(sum(sales),3) as monthly_sales
from
	orders.orders
group by 1,2
order by 3)
select
	product_category,
    month,
    monthly_sales,
    sum(monthly_sales) over (partition by product_category order by month) as com_sales
from 
	monthly
order by 2,1;

-- Shipping Cost Rank
select
	product_sub_category,
	round(sum(shipping_cost),3) as shipping_cost,
	rank() over(order by round(sum(shipping_cost),3) ) as rank_shop
from 
	orders.orders
group by 1
order by 3;

select *
from orders.orders;
-- Order shipping lag
alter table orders.orders
add column order_shipping_lag date;

alter table orders.orders
modify column order_shipping_lag int;
UPDATE orders.orders
set order_shipping_lag = datediff(ship_date ,order_date);

-- Monthly Sales Trends
select month(order_date) as month,
round(sum(sales),3) as total_sales
from orders.orders
group by 1
order by 1;

-- Profitability by Year
select
	year(order_date) as year,
    round(sum(sales),3) as sales,
    round(sum(profit),3) as profit,
    round(sum(discount),3) as discount
from
	orders.orders
group by 1 order by 1;

-- Customer Retention
select
	customer_id,
    customer_name,
    count(*) as orders,
    round(avg(sales),3) as ave_order_value
from
	orders.orders
group by 1,2
having count(*)>3
order by 4;

-- High-Margin Products
select
	distinct product_name,
    prouct_base_margin,
    unit_price,
    round(prouct_base_margin*unit_price,2) as profit,
    round(prouct_base_margin*100, 2) as profit_margin_prec
from orders.orders
where prouct_base_margin>0.3
order by profit_margin_prec;

-- Temporary Table for Profit
create temporary table temp_profit as
select
	product_category as category,
    round(sum(sales),3) as sales,
    round(sum(profit),3) as profit,
	round((sum(profit)/sum(sales))*100)  Profit_Margin_Percentage
from
	orders.orders
group by 1;

select *
from temp_profit;

select *
from orders.orders;
-- Top Performing Products
select
	*
from(
	select
		product_sub_category,
		product_name,
		round(sum(sales),3) as sales,
		rank() over(partition by product_sub_category order by sum(sales) desc) as rank_sub
	from orders.orders
	group by 1,2) as rank_sub_category
where rank_sub<=3
order by 1,4;

-- Sales Contribution by Region
select
	region,
    round(sum(sales),3) as revenue,
    round(sum(sales)/(select sum(sales) from orders.orders),3)*100 as prece
from orders.orders
group by 1 order by 3 desc;

-- Average Discount by Product Category:
select
	product_name,
    round(avg(discount),3) as avg_discount,
    case
		when avg(discount)>=0.07 then "hiegh"
        else "" end as hiegh
from orders.orders
group by 1 order by 2 desc;

select *
from orders.orders;
-- Shipping Cost Efficiency
select
	ship_mode,
    round(avg(shipping_cost),3) as avg_ship_cost
from orders.orders
group by 1 order by 2;

-- Customer Segment Profitability
select 
	customer_segment,
    round(sum(profit),3) as profit
from orders.orders
group by 1 order by 2 desc;

-- Order Priority Impact:
SELECT 
    Order_Priority AS Priority,
    AVG(Profit) AS Average_Profit
FROM 
    orders.orders -- Replace with your actual table name
GROUP BY 
    Order_Priority
ORDER BY 2 desc