do $$
begin
create sequence seq_dim_ranges;

-- РЕСУРСЫ единицы измерения
create table dim_ranges
(
	-- внутренний код
	id bigint primary key default nextval('public.seq_dim_ranges'),
	external_id bigint,
	name text,
	factor float,
	-- дата добавления
	date_add timestamp default now()
);

-- поставщики
create sequence seq_dim_vendors;

create table dim_vendors
(
	-- внутренний код
	id bigint primary key default nextval('public.seq_dim_vendors'),
	external_id bigint,
	name text,
	parent_id text,
	parent_name text,
	-- дата добавления
	date_add timestamp default now()
);

-- категории
create sequence seq_dim_category;

create table dim_category
(
	-- внутренний код
	id bigint primary key default nextval('public.seq_dim_category'),
	external_id bigint,
	name text,
	parent_id text,
	-- дата добавления
	date_add timestamp default now()
);

-- продукты 
create sequence seq_dim_product;

create table dim_product
(
	-- внутренний код
	id bigint primary key default nextval('public.seq_dim_product'),
	external_id bigint,
	productid bigint,
	product_name text,
	category_id bigint,
	category_name text,
	size_id bigint,
	size_name text,
	-- дата добавления
	date_add timestamp default now()
);

-- сотрудники
create sequence seq_dim_personnel;

create table dim_personnel
(
	-- внутренний код
	id bigint primary key default nextval('public.seq_dim_personnel'),
	external_id bigint,
	fullname text,
	-- дата добавления
	date_add timestamp default now()
);

-- тип действий
create sequence seq_dim_transtype;

create table dim_transtype
(
	-- внутренний код
	id bigint primary key default nextval('public.seq_dim_transtype'),
	external_id bigint,
	transgroupid bigint,
	transtype_name text,
	-- дата добавления
	date_add timestamp default now()
);

-- склад
create sequence seq_dim_storage;

create table dim_storage
(
	-- внутренний код
	id bigint primary key default nextval('public.seq_dim_storage'),
	external_id bigint,
	productid bigint,
	product_name text,
	vendor_id bigint,
	vendor_name text,
	product_count decimal(10,4),
	range_id bigint,
	range_name text,
	-- дата добавления
	date_add timestamp default now()
);
end $$;