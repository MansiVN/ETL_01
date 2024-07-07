drop table df_orders;

CREATE table df_orders (
[order_id]         int primary key,
[order_date]      date,
[ship_mode]       varchar(20),
[segment]                     varchar(20),
[country]                     varchar(20),
[city]                        varchar(20),
[state]                       varchar(30),
[postal_code]                  int,
[region]                      varchar(10),
[category]                    varchar(20),
[sub_category]                varchar(20),
[product_id]                  varchar(20),
[cost_price]                   int,
[list_price]                   int,
[quantity]                     int,
[discount_percent]             int,
[discount]                  decimal(7,2),
[sale_price]                 decimal(7,2),
[profit]                     decimal(7,2)
)

Select * from df_orders;


-- Find the top highest revenue generating products

SELECT Top 10 product_id, sum(sale_price) as revenue from df_orders 
group by product_id
order by revenue desc;


-- Top 5 highest selling product in each region
with cte as (
SELECT region, product_id, sum(sale_price) as sales, rank() over(partition by region order by sum(sale_price) desc) as rnk from df_orders
group by product_id, region
) 
Select region, product_id, sales from cte 
where rnk<6
order by region, sales desc;

-- Find month over month growth comparison for 2022 and 2023 sales  eg : jan'22 vs jan'24
Select *, t1.sales-t2.sales as growth from 
(Select month(order_date) as months, year(order_date) as years, sum(sale_price)  as sales
from df_orders 
group by month(order_date), year(order_date)
having year(order_date)='2023'
) t1
inner join 
(Select month(order_date) as months, year(order_date) as years, sum(sale_price)  as sales
from df_orders 
group by month(order_date), year(order_date)
having year(order_date)='2022'
) t2
on t1.months=t2.months
order by t1.months;

-----Alternate query for above question 

Select month(order_date) as months, 
sum(case when year(order_date)=2023 then sale_price else 0 end) as sales_2023,
sum(case when year(order_date)=2022 then sale_price  else 0 end) as sales_2022
from df_orders 
group by month(order_date) 
order by months;



-- For each category which month had highest sales
With cte as (
Select category, month(order_date) as month_of_sale, sum(sale_price) sales, rank() over(partition by category order by sum(sale_price) desc) as rnk
from df_orders
group by category, month(order_date)
)
Select category, month_of_sale from cte 
where rnk=1;


--Which sub category had highest growth  by profit in 2023 compare to 2022

-- growth with respect to sale_price

Select top 1 sub_category, 
(sum(case when year(order_date)=2023 then sale_price else 0 end) -
sum(case when year(order_date)=2022 then sale_price  else 0 end)) as growth
from df_orders 
group by sub_category
order by growth desc;

-- growth percent wise

Select top 1 sub_category, 
(sum(case when year(order_date)=2023 then sale_price else 0 end) -
sum(case when year(order_date)=2022 then sale_price  else 0 end))/ 
sum(case when year(order_date)=2022 then sale_price  else 0 end)*100 as percentage_growth
from df_orders 
group by sub_category
order by percentage_growth desc;





