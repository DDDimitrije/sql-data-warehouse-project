if OBJECT_ID('gold.dim_customers', 'U') is not null
	drop table gold.dim_customers;
go

create table gold.dim_customers
(
	customer_key int identity(1,1) not null,
	customer_id int not null,
	customer_number nvarchar(50) null,
	first_name nvarchar(50) null,
	last_name nvarchar(50) null,
	country nvarchar(50) null,
	marital_status nvarchar(50) null,
	gender nvarchar(50) null,
	birthdate date null,
	create_date date null,

	constraint PK_dim_customer
		primary key clustered(customer_key),
	constraint UQ_dim_customers_customer_id
		unique(customer_id)
);
go

if OBJECT_ID('gold.dim_products','U') is not null
	drop table gold.dim_products;
go

create table gold.dim_products
(
	product_key int identity(1,1) not null,
	product_id int not null,
	product_number nvarchar(50) not null,
	product_name nvarchar(50) null,
	category_id nvarchar(50) null,
	category nvarchar(100) null,
	subcategory nvarchar(100) null,
	maintenance nvarchar(100) null,
	cost decimal(18,2) null,
	product_line nvarchar(50) null,
	start_date date null,

	constraint PK_dim_products
		primary key clustered (product_key),

	constraint UQ_dim_products_product_number
		unique (product_number)
);
go

if OBJECT_ID('gold.dim_date','U') is not null
	drop table gold.dim_date;
go

create table gold.dim_date
(
	date_key int not null,
	full_date date not null,
	day_number int not null,
	day_name nvarchar(20) not null,
	month_number int not null,
	month_name nvarchar(20) not null,
	quarter_number int not null,
	year_number int not null,
	week_number int not null,
	is_weekend bit not null,

	constraint PK_dim_date
		primary key clustered (date_key),
	constraint UQ_dim_date_full_date
		unique (full_date)
);
go

if OBJECT_ID('gold.fact_sales','U') is not null
	drop table gold.fact_sales;
go

create table gold.fact_sales
(
	order_number nvarchar(50) not null,
	product_key int not null,
	customer_key int not null,
	order_date_key int null,
	shipping_date_key int null,
	due_date_key int null,
	sales_amount decimal(18,2) null,
	quantity int null,
	price decimal(18,2) null,

	constraint PK_fact_sales
		primary key clustered (order_number, product_key),
	constraint FK_fact_sales_customer
		foreign key (customer_key)
		references gold.dim_customers(customer_key),
	constraint FK_fact_sales_product
		foreign key (product_key)
		references gold.dim_products(product_key),
	constraint FK_fact_sales_order_date
		foreign key (order_date_key)
		references gold.dim_date(date_key),
	constraint FK_fact_sales_shipping_date
		foreign key (shipping_date_key)
		references gold.dim_date(date_key),
	constraint FK_fact_sales_due_date
		foreign key (due_date_key)
		references gold.dim_date(date_key)
)
