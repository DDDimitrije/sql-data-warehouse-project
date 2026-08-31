
create or alter procedure silver.load_silver as
begin
	declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime
	begin try
	set @batch_start_time = GETDATE();
	print 'Loading Silver Layer';
	print 'Loading CRM Tables';
	print '=====================================';

	set @start_time = GETDATE();
	print 'Truncating Table: silver.crm_cust_info';
	truncate table silver.crm_cust_info;
	print 'Inserting Data: silver.crm_cust_info';
	insert into silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date)

	select
	cst_id,
	cst_key,
	TRIM(cst_firstname) as cst_firstname,
	TRIM(cst_lastname) as cst_lastname,
	case when UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
		 when UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
		 else 'n/a'
	end cst_marital_status,
	case when UPPER(TRIM(cst_gndr)) = 'F' then 'Female'
		 when UPPER(TRIM(cst_gndr)) = 'M' then 'Male'
		 else 'n/a'
	end cst_gndr,
	cst_create_date
	from(
	select
	*,
	ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
	from bronze.crm_cust_info
	where cst_id is not null
	)t where flag_last = 1
	set @end_time = GETDATE();
	print 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as nvarchar) + ' seconds.';
	print '=====================================';


	set @start_time = GETDATE();
	print 'Truncating Table: silver.crm_prd_info';
	truncate table silver.crm_prd_info;
	print 'Inserting Data: silver.crm_prd_info';
	insert into silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	select
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') as cat_id,
		SUBSTRING(prd_key, 7, LEN(prd_key)) as prd_key,
		prd_nm,
		ISNULL(prd_cost, 0) as prd_cost,
		case when UPPER(TRIM(prd_line)) = 'M' then 'Mountain'
			 when UPPER(TRIM(prd_line)) = 'R' then 'Road'
			 when UPPER(TRIM(prd_line)) = 'S' then 'Other Sales'
			 when UPPER(TRIM(prd_line)) = 'T' then 'Touring'
			 else 'n/a'
		end as prd_line,
		CAST(prd_start_dt as date) as prd_start_dt,
		CAST(LEAD(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
	from bronze.crm_prd_info
	set @end_time = GETDATE();
	print 'Loading Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as nvarchar) + ' seconds';
	print '=====================================';


	set @start_time = GETDATE();
	print 'Truncating Table: silver.crm_sales_details';
	truncate table silver.crm_sales_details;
	print 'Inserting Data: silver.crm_sales_details';
	insert into silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)
	select
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	case when sls_order_dt = 0 or LEN(sls_order_dt) != 8 then null
		 else CAST(CAST(sls_order_dt as varchar) as date)
	end as sls_order_dt,
	case when sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 then null
		 else CAST(CAST(sls_ship_dt as varchar) as date)
	end as sls_ship_dt,
	case when sls_due_dt = 0 or LEN(sls_due_dt) != 8 then null
		 else CAST(CAST(sls_due_dt as varchar) as date)
	end as sls_due_dt,
	case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
			then sls_quantity * ABS(sls_price)
		 else sls_sales
	end as sls_sales,
	sls_quantity,
	case when sls_price is null or sls_price <= 0
			then sls_sales / NULLIF(sls_quantity,0)
		 else sls_price
	end as sls_price
	from bronze. crm_sales_details
	set @end_time = GETDATE();
	print 'Loading Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as nvarchar) + ' seconds';
	print '=====================================';



	print 'Loading ERP Tables';
	print '=====================================';
	set @start_time = GETDATE();
	print 'Truncating Table: silver.erp_cust_az12';
	truncate table silver.erp_cust_az12;
	print 'Inserting Data: silver.erp_cust_az12';
	insert into silver.erp_cust_az12 (
		cid, 
		bdate, 
		gen
	)
	select
	case when cid like 'NAS%' then SUBSTRING(cid, 4, LEN(cid))
		 else cid
	end as cid,
	case when bdate > GETDATE() then null
		 else bdate
	end as bdate,
	case when UPPER(TRIM(gen)) in ('F', 'FEMALE') then 'Female'
		 when UPPER(TRIM(gen)) in ('M', 'MALE') then 'Male'
		 else 'n/a'
	end as gen
	from bronze.erp_cust_az12
	set @end_time = GETDATE();
	print 'Loading Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as nvarchar) + ' seconds';
	print '=====================================';


	set @start_time = GETDATE();
	print 'Truncating Table: silver.erp_loc_a101';
	truncate table silver.erp_loc_a101;
	print 'Inserting Data: silver.erp_loc_a101';
	insert into silver.erp_loc_a101
	(
		cid,
		cntry
	)
	select
	REPLACE(cid, '-', '') as cid,
	case when TRIM(UPPER(cntry)) = 'DE' then 'Germany'
		 when TRIM(UPPER(cntry))  in ('US', 'USA') then 'United States'
		 when TRIM(cntry) = '' or cntry is null then 'n/a'
		 else TRIM(cntry)
	end as cntry
	from bronze.erp_loc_a101
	set @end_time = GETDATE();
	print 'Loading Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as nvarchar) + ' seconds';
	print '=====================================';



	set @start_time = GETDATE();
	print 'Truncating Table: silver.erp_px_cat_g1v2';
	truncate table silver.erp_px_cat_g1v2;
	print 'Inserting Data: silver.erp_px_cat_g1v2';
	insert into silver.erp_px_cat_g1v2
	(
		id,
		cat,
		subcat,
		maintenance
	)
	select
	id,
	cat,
	subcat,
	maintenance
	from bronze.erp_px_cat_g1v2
	set @end_time = GETDATE();
	print 'Loading Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as nvarchar) + ' seconds';
	print '=====================================';
	set @batch_end_time = GETDATE();
	print 'Loading Silver Layer is Completed';
	print 'Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) as nvarchar) + ' seconds';

	end try

	begin catch
		print 'Error occured during loading silver layer';
		print 'Error Message ' + ERROR_MESSAGE();
		print 'Error Message ' + CAST(ERROR_NUMBER() as nvarchar);
		print 'Error Message ' + CAST(ERROR_STATE() as nvarchar);
	end catch

end
