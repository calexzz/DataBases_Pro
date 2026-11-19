-- единицы измерения
select id, sizeid as name,
portionrate as factor from [size]

select 'insert into dim_ranges(external_id, name, factor) values (''' 
+ cast(id as varchar(max)) + ''',''' 
+ [sizeid] + ''','''
+ cast(portionrate as varchar(max)) + ''');' 
as [sql]
from [size]

select 'insert into dim_vendors(external_id, name, parent_id, parent_name) values (''' 
+ cast(id as varchar(max)) + ''',''' 
+ [clientid] + ''','''
+ cast(clientgroup as varchar(max)) + ''','''
+ cast(t2.[description] as varchar(max)) + ''');' 
as [sql]
from [vendors] t1
inner join vendorgroup t2 on t1.clientgroup = t2.vendorgroupid

-- категории
select * from
(
select id, description as name, 
    case when coalesce(ParentID,0) = 0 
        then null else parentId end as parent_id 
            from category
) t1
order by parent_id, name

-- поставщики
select * from
(
    select id, clientid as name, 
    clientgroup as parent_id,
    t2.[description] as parent_name
    from vendors t1
    inner join vendorgroup t2 on t1.clientgroup = t2.vendorgroupid
) as t1 order by parent_id

-- продукты 
select * from product
select * from bm_StorageOperations


-- Анализ закупок
select * from 
(
    select t1.id, 
        OperationID as operation_id,
        t5.[Description] as operation_name,
        t1.ProductID as productid,
        t2.[description] as product_name,
        t1.VendorID as vendor_id,
        t3.clientid as vendor_name,
        t2.SizeID as size_id,
        t1.Count as product_count,
        t4.sizeid as size_name,
        Amount as amount
    from bm_StorageOperations t1
    inner join product t2 on t1.ProductID = t2.id
    inner join vendors t3 on t1.VendorID = t3.id
    inner join size t4 on t2.SizeID = t4.id
    inner join bm_StorageOperationsType t5 on t1.OperationID = t5.ID
    where OperationID = 1
) as t1
-- OperationID = 1 это поступления из StorageOperationTypes, если это закупки, то логично выбрать только то, что поступило на склад
-- вывел айди и наименование товара, айди и имя поставщика, кол-во закупленного и ед. измерения ну и итоговую стоимость
