select * from coffee_shop_sales;

describe coffee_shop_sales;

set sql_safe_updates = 0;
update coffee_shop_sales
set transaction_date = str_to_date(transaction_date,"%m/%d/%y");

alter table coffee_shop_sales
modify column transaction_date date;

update coffee_shop_sales
set transaction_time = time(transaction_time);

alter table coffee_shop_sales
modify column transaction_time time;

-- 1
select MONTH(transaction_date) AS month,concat(round(sum(transaction_qty * unit_price))/1000,"k") as Total_sales -- if we want to change to "k" we use concat function and divide by 1000
from coffee_shop_sales
where month(transaction_date) = 4
GROUP BY 
    MONTH(transaction_date);

-- 2
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(count(transaction_id)) AS total_orders,
    (count(transaction_id)-lag(count(transaction_id),1)
    over(order by month(transaction_date)))/lag(count(transaction_id),1)over(order by month(transaction_date)) * 100 as mom_as_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

-- 3
select
	month(transaction_date) as Month, round(sum(unit_price*transaction_qty)) as Total_Sales,
    (sum(unit_price*transaction_qty)- lag(sum(unit_price*transaction_qty),1) over (order by month(transaction_date))) as Difference_in_sales
from coffee_shop_sales
group by month(transaction_date)
order by month(transaction_date);

-- Daily sales for month

select 
	day(transaction_date) as day_of_month,
    sum(unit_price*transaction_qty) as total_sales
    from coffee_shop_sales
    where month(transaction_date) = 5
    group by day(transaction_date)
    order by day(transaction_date);
-- Comparing daily sales with average sale

select 
	day_of_month,
    case 
    when total_sales > avg_sales then "Above average"
    when total_sales < avg_sales then "Below Average"
    Else "Average"
    end as sales_status,
    total_sales
from(
select 
	day(transaction_date) as day_of_month,
    sum(unit_price*transaction_qty) as total_sales,
    avg(sum(unit_price*transaction_qty))over() as avg_sales
    from coffee_shop_sales
    where month(transaction_date) = 5
    group by day(transaction_date)
) as sales_data ; -- by default the order by is in ascending order 
-- -- --- ----- --- ---- -----
-- Sale by weekday / weekend
select
	case 
    when dayofweek(transaction_date) in (1,7) then "WeekEnd"
    else "WeekDay"
    end as day_type,
    round(sum(unit_price*transaction_qty),2) as total_Sales
    from coffee_shop_sales
    where month(transaction_date) = 5
    group by case 
    when dayofweek(transaction_date) in (1,7) then "Weekend"
    else "WeekDay"
    end;
-- Store Location
select
store_location,
sum(unit_price*transaction_qty)  as sales
from coffee_shop_sales
where month(transaction_date) = 5
group by store_location
order by sales desc;

-- sales by product (Limit 10)
select 
product_type,
round(sum(unit_price*transaction_qty),1)  as sales
from coffee_shop_sales
where month(transaction_date) = 5
group by product_type
order by sales desc
limit 10;
-- 
    









