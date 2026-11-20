-- единицы измерения
select id, sizeid as name,
portionrate as factor from [size]

select 'insert into dim_ranges(external_id, name, factor) values (''' 
+ cast(id as varchar(max)) + ''',''' 
+ [sizeid] + ''','''
+ cast(portionrate as varchar(max)) + ''');' 
as [sql]
from [size]

-- категории
select * from
(
select id, description as name, 
    case when coalesce(ParentID,0) = 0 
        then null else parentId end as parent_id 
            from category
) t1
order by parent_id, name

select 'insert into dim_category(external_id, name, parent_id) values (''' 
+ cast(id as varchar(max)) + ''',''' 
+ [description] + ''','''
+ cast(ParentID as varchar(max)) + ''');' 
as [sql]
from [category]

-- поставщики
select * from
(
    select id, clientid as name, 
    clientgroup as parent_id,
    t2.[description] as parent_name
    from vendors t1
    inner join vendorgroup t2 on t1.clientgroup = t2.vendorgroupid
) as t1 order by parent_id

select 'insert into dim_vendors(external_id, name, parent_id, parent_name) values (''' 
+ cast(id as varchar(max)) + ''',''' 
+ [clientid] + ''','''
+ cast(clientgroup as varchar(max)) + ''','''
+ cast(t2.[description] as varchar(max)) + ''');' 
as [sql]
from [vendors] t1
inner join vendorgroup t2 on t1.clientgroup = t2.vendorgroupid

-- продукты 
select * from (
    select t1.id, productid, t1.[description] as product_name, 
    t1.CategoryID, t2.[description] as category_name,
    t1.SizeID, t3.[description] as size_name
    from product t1
    inner join category t2 on t1.CategoryID = t2.id
    inner join size t3 on t1.SizeID = t3.ID
) as t order by id

select 'insert into dim_product(external_id, productid, product_name, category_id, category_name, size_id, size_name) values (''' 
+ cast(t1.id as varchar(max)) + ''',''' 
+ cast([productid] as varchar(max)) + ''','''
+ cast(t1.[description] as varchar(max)) + ''','''
+ cast(t1.CategoryID as varchar(max)) + ''','''
+ cast(t2.[description] as varchar(max)) + ''','''
+ cast(t1.[SizeID] as varchar(max)) + ''','''
+ cast(t3.[description] as varchar(max)) + ''');' 
as [sql]
from [product] t1
inner join category t2 on t1.CategoryID = t2.id
inner join size t3 on t1.SizeID = t3.ID

-- сотрудники
select personid, concat_ws(' ', lastname, firstname, middlename) as fullname from personnel

select 'insert into dim_personnel(external_id, fullname) values (''' 
+ cast(personid as varchar(max)) + ''','''
+ cast(concat_ws(' ', lastname, firstname, middlename) as varchar(max)) + ''');' 
as [sql]
from personnel

-- тип действий
select transtypeid as id, transgroupid, [description] as transtype_name
from transtype

select 'insert into dim_transtype(external_id, transgroupid, transtype_name) values (''' 
+ cast(transtypeid as varchar(max)) + ''','''
+ cast(transgroupid as varchar(max)) + ''','''
+ cast([description] as varchar(max)) + ''');' 
as [sql]
from transtype

-- склад
select t1.ID, 
    t1.ProductID, t2.[description] as product_name,
    t1.VendorID, t3.clientid as vendor_name,
    t1.count,
    t1.RangeID, t4.[description] as range_name
from bm_StorageOperations t1
inner join product t2 on t1.ProductID = t2.id
inner join vendors t3 on t1.VendorID = t3.id
inner join size t4 on t1.RangeID = t4.ID

select 'insert into dim_storage(external_id, productid, product_name, vendor_id, vendor_name, product_count, range_id, range_name) values (''' 
+ cast(t1.ID as varchar(max)) + ''','''
+ cast(t1.ProductID as varchar(max)) + ''','''
+ cast(t2.[description] as varchar(max)) + ''','''
+ cast(t1.VendorID as varchar(max)) + ''','''
+ cast(t3.clientid as varchar(max)) + ''','''
+ cast(t1.[count] as varchar(max)) + ''','''
+ cast(t1.RangeID as varchar(max)) + ''','''
+ cast(t4.[description] as varchar(max)) + ''');' 
as [sql]
from bm_StorageOperations t1
inner join product t2 on t1.ProductID = t2.id
inner join vendors t3 on t1.VendorID = t3.id
inner join size t4 on t1.RangeID = t4.ID