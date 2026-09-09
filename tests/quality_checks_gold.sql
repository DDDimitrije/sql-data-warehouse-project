-- check for uniqueness of customer key
select
	customer_key,
	COUNT(*) as duplicat_count
from gold.dim_customers
group by customer_key
having COUNT(*) > 1

-- check for uniqness of product key
select
	product_key,
	COUNT(*) as duplicate_count
from gold.dim_products
group by product_key
having COUNT(*) >1

-- check the data model connectivity between fact and dimensions
select *
from gold.fact_sales as f
left join gold.dim_customers as c
on c.customer_key = f.customer_key
left join gold.dim_products as p
on p.product_key = f.prodcut_key
where p.product_key is null or c.customer_key is null
