create or alter procedure gold.load_procedure as
begin
	set nocount on;
	set xact_abort on;
	 begin try
		begin transaction
		print '==============================';
		print 'Loading Gold Layer.';
		print '==============================';

		print 'Loading gold.dim_customers...';
		truncate table gold.dim_customers
		insert into gold.dim_customers(
			customer_id,
			customer_number,
			first_name,
			last_name,
			country,
			marital_status,
			gender,
			birthdate,
			create_date
		)
		select
			ci.cst_id,
			ci.cst_key,
			ci.cst_firstname,
			ci.cst_lastname,
			la.cntry,
			ci.cst_marital_status,
			case 
				when ci.cst_gndr != 'n/a'
					then ci.cst_gndr
				else ca.gen
			end as gender,
			ca.bdate,
			ci.cst_create_date
		from silver.crm_cust_info as ci
		left join silver.erp_cust_az12 as ca
			on ci.cst_key = ca.cid
		left join silver.erp_loc_a101 as la
			on ci.cst_key = la.cid

		print 'Loading gold.dim_products...';
		truncate table gold.dim_products;
		insert into gold.dim_products(
			product_id,
			product_number,
			product_name,
			category_id,
			category,
			subcategory,
			maintenance,
			cost,
			product_line,
			start_date
		)
		select
			pn.prd_id,
			pn.prd_key,
			pn.prd_nm,
			pn.cat_id,
			pc.cat,
			pc.subcat,
			pc.maintenance,
			pn.prd_cost,
			pn.prd_line,
			pn.prd_start_dt
		from silver.crm_prd_info as pn
		left join silver.erp_px_cat_g1v2 as pc
			on pn.cat_id = pc.id
		where pn.prd_end_dt is null

		print 'Loading gold.fact_sales...';
		truncate table gold.fact_sales;
		insert into gold.fact_sales(
			order_number,
			product_key,
			customer_key,
			order_date_key,
			shipping_date_key,
			due_date_key,
			sales_amount,
			quantity,
			price
		)
		select
			sd.sls_ord_num,
			p.product_key,
			c.customer_key,
			od.date_key as order_date_key,
			sh.date_key as shipping_date_key,
			dd.date_key as due_date_key,
			sd.sls_sales,
			sd.sls_quantity,
			sd.sls_price
		from silver.crm_sales_details as sd
		left join gold.dim_products as p
			on sd.sls_prd_key = p.product_number
		left join gold.dim_customers as c
			on sd.sls_cust_id = c.customer_id
		left join gold.dim_date as od
			on sd.sls_order_dt = od.full_date
		left join gold.dim_date as sh
			on sd.sls_ship_dt = sh.full_date
		left join gold.dim_date as dd
			on sd.sls_due_dt = dd.full_date

		print 'Loading gold.dim_date...';
		truncate table gold.dim_date;
		declare @StartDate date, @EndDate date;
		select
			@StartDate = MIN(sls_order_dt),
			@EndDate = MAX(sls_order_dt)
		from silver.crm_sales_details;
		;with DateRange as 
		(
			select @StartDate as full_date
			union all
			select DATEADD(DAY,1,full_date)
			from DateRange
			where full_date < @EndDate
		)
		insert into gold.dim_date
		(
			date_key,
			full_date,
			day_number,
			day_name,
			month_number,
			month_name,
			quarter_number,
			year_number,
			week_number,
			is_weekend
		)
		select
			CONVERT(int, CONVERT(char(8),full_date,112)) as date_key,
			full_date,
			DAY(full_date),
			DATENAME(WEEKDAY, full_date),
			DATEPART(QUARTER, full_date),
			YEAR(full_date),
			DATEPART(QUARTER, full_date),
			YEAR(full_date),
			DATEPART(WEEK, full_date),
			case
				when DATENAME(WEEKDAY, full_date) in ('Saturday','Sunday')
					then 1
				else 0
			end
		from DateRange
		option (MAXRECURSION 0);

		commit transaction;

		print '==============================';
		print 'Gold Layer loaded successfully';
		print '==============================';
	 end try
	 begin catch
		if @@TRANCOUNT > 0
			rollback transaction;
		print '==============================';
		print 'ERROR loading Gold Layer';
		print '==============================';

		print ERROR_MESSAGE();
		throw;
	 end catch
end;
GO


