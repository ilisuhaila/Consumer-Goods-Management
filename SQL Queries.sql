-- [MySQL] Consumer Goods Management

-- Generate a yearly report for 'croma' customer where the output contains fiscal_year and yearly_gross_sales fields. 
-- Make sure that yearly_gross_sales are in millions.

select s.fiscal_year,
round(sum(g.gross_price * s.sold_quantity)/1000000,2) as yearly_gross_sales
from fact_sales_monthly s
join fact_gross_price g
on
s.fiscal_year = g.fiscal_year and s.product_code = g.product_code
where customer_code = 90002002
group by fiscal_year
order by fiscal_year 

-- Generate a report which contain fiscal year and also the number of unique products sold in
-- that year. This helps Atliq hardwares regarding the development of new products and its
-- growth year on year

select fiscal_year,
count(distinct(product_code)) as unique_product_count
from fact_sales_monthly
group by fiscal_year

-- Provide the list of markets in which customer "Atliq Exclusive" operates its 
-- business in the APAC region.

select distinct market
from dim_customer
where customer = 'Atliq Exclusive' and region = 'APAC'

-- What is the percentage of unique product increase in 2021 vs. 2020? 
-- The final output contains  unique_products_2020, unique_products_2021, and percentage_chg

select 
count(distinct case when fiscal_year = 2020 then product_code end) as unique_products_2020,
count(distinct case when fiscal_year = 2021 then product_code end) as unique_products_2021,
((count(distinct case when fiscal_year = 2021 then product_code end)) - (count(distinct case when fiscal_year = 2020 then product_code end)))
/((count(distinct case when fiscal_year = 2020 then product_code end))) * 100
as percentage_chg
from fact_sales_monthly

-- Provide a report with all the unique product counts for each segment and sort them in
-- descending order of product counts. The final output contains 2 fields, 
-- segment, product_count

select 
p.segment,
sum(s.sold_quantity) as product_count
from dim_product p
join fact_sales_monthly s
on s.product_code=p.product_code
group by segment
order by product_count desc

-- Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final
-- output contains these fields, segment product_count_2020 product_count_2021 difference

select 
p.segment,
count(distinct case when s.fiscal_year = 2020 then s.product_code end) as unique_products_2020,
count(distinct case when s.fiscal_year = 2021 then s.product_code end) as unique_products_2021,
((count(distinct case when s.fiscal_year = 2021 then s.product_code end)) - (count(distinct case when s.fiscal_year = 2020 then s.product_code end)))
/ (count(distinct case when s.fiscal_year = 2020 then s.product_code end)) * 100 as percentage_chg
from fact_sales_monthly s
join dim_product p
on s.product_code = p.product_code
group by segment
order by percentage_chg desc ;

-- Get the products that have the highest and lowest manufacturing costs. The final 
-- output should contain these fields, product_code product manufacturing_cost

select m.product_code, p.product, m.manufacturing_cost
from fact_manufacturing_cost m
join dim_product p
on m.product_code = p.product_code
order by manufacturing_cost desc ;

-- Generate a report which contains the top 5 customers who received an average high 
-- pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market. The final output 
-- contains these fields, customer_code customer average_discount_percentage

select c.customer_code, c.customer,
avg(case when i.fiscal_year = 2021 then i.pre_invoice_discount_pct end) as average_discount_percentage
from fact_pre_invoice_deductions i
join dim_customer c
on c.customer_code = i.customer_code
where c.market = 'India'
group by c.customer_code, c.customer
order by average_discount_percentage desc
limit 5;

-- Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each 
-- month. This analysis helps to get an idea of low and high-performing months and take 
-- strategic decisions. The final report contains these columns: Month Year Gross sales Amount 

select 
date_format(s.date, '%M') as Month,
g.fiscal_year as Year,
sum(g.gross_price * s.sold_quantity) as 'Gross Sales Amount'
from fact_gross_price g
join fact_sales_monthly s 
on g.fiscal_year = s.fiscal_year
and g.product_code = s.product_code
join dim_customer c 
on c.customer_code = s.customer_code
where c.customer = 'Atliq Exclusive'
group by Month, Year
order by Year, Month;

-- In which quarter of 2020, got the maximum total_sold_quantity? The final output contains 
-- these fields sorted by the total_sold_quantity : Quarter, total_sold_quantity 

select 
quarter(date) as Quarter,
sum(sold_quantity) as Total_Sold_Quantity
from fact_sales_monthly
where fiscal_year = 2020
group by quarter
order by Total_Sold_Quantity desc;

-- Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of 
-- contribution? The final output contains channel gross_sales_mln percentage

select c.channel,
round(sum(g.gross_price * s.sold_quantity)/1000000, 2) as gross_sales_mln,
round(sum(g.gross_price * s.sold_quantity)
/ ( select sum(g2.gross_price * s2.sold_quantity)
	  from fact_gross_price g2
    join fact_sales_monthly s2
    on g2.product_code = s2.product_code and g2.fiscal_year = s2.fiscal_year
    where g2.fiscal_year = 2021 ) * 100, 2)
as 'percentage'
from fact_gross_price g
join fact_sales_monthly s
on g.product_code = s.product_code and g.fiscal_year = s.fiscal_year
join dim_customer c 
on c.customer_code = s.customer_code
where g.fiscal_year = 2021
group by channel
order by gross_sales_mln desc;

-- Get the Top 3 products in each division that have a high total_sold_quantity in the 
-- fiscal_year 2021? The final output contains division, product_code, product, 
-- total_sold_quantity, rank_order

with ProductSales as (
	select 
		p.division, p.product_code, p.product,
    sum(s.sold_quantity) as total_sold_quantity,
    row_number() over (partition by p.division 
      order by sum(s.sold_quantity) desc) as rank_order
  from 
		dim_product p
	join fact_sales_monthly s
    on p.product_code = s.product_code
    where s.fiscal_year = 2021
    group by p.division, p.product_code, p.product
)
select
	division, product_code, product, total_sold_quantity, rank_order
from
	ProductSales
where
	rank_order <=3
order by
	division, rank_order

