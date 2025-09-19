select *
from superstore.sales;

alter table sales
modify column `profit` double;

alter table sales
change `Profit` profit int;

alter table sales
add column new_ship_date date;

update sales
set new_ship_date = str_to_date(ship_date,'%d/%m/%Y');

select new_ship_date, ship_date
from sales;

alter table sales drop column ship_date;
alter table sales change new_ship_date ship_date date;


update sales s
join sales2 s2 on s.id = s2.`Row Id`
set s.profit = s2.Profit;

select *
from superstore.sales;

select sum(profit) as total
from sales;

select round(sum(sales),3) as total
from sales;

select customer_name, count(*) number_purches
from sales
group by 1
order by 2 desc
limit 5;

select distinct category
from sales;

select category, round(sum(sales),4) as total
from sales
group by 1;

select a.customer_name, a.order_id order1, b.order_id order2, a.sales sales1, b.sales sales2, b.product_id
from sales a
join sales b on a.customer_id = b.customer_id
where a.order_id != b.order_id
order by 1;

select customer_id, sum(sales) as total, rank() over(order by sum(sales) desc ) as rank_sales
from sales
group by 1
order by 3;

select customer_id, sum(sales) as total, count(*) as number_order
from sales
group by 1
order by 2 desc;

select customer_id, round(avg(sales),4) as total, count(*) as number_order
from sales
group by 1
having count(*) >3
order by 2 desc;

with customer as (
	select customer_id, customer_name, sum(sales) as total, 
		rank() over(order by sum(sales) desc) as sales_rank
	from sales
    group by 1,2)
select * from customer order by sales_rank;

select date_format(order_date, '%Y-%m') as month, round(sum(sales),4) as total_sales
from sales
group by 1
order by 1; 
