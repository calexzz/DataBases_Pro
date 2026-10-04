-- каждый пользователь имеет одинаковое количество измерений?
select * from public.users as t1
left join
(
	-- Подзапрос
	select user_id, cnt_records from
	(
		-- Подзапрос
		select pk.user_id, count(*) as cnt_records
		from public.packs as pk
		inner join public.parameters as par on par.pack_id = pk.code
		group by pk.user_id
	) as t1
) as inner_t2 on t1.code = inner_t2.user_id;

-- у нас нет пустых пачек измерения?
select * from public.packs as t1
left join
(
	select pk.code from public.packs as pk
	inner join public.parameters as par on par.pack_id = pk.code
) as inner_t2 on t1.code = inner_t2.code
where inner_t2.code is null;

-- Каждая пачка измерений содержит полное количеситво параметров (5 шт)?
select * from public.packs as t1
inner join
(
	-- Подзапрос
	select pack_id, cnt_records from
	(
		-- Подзапрос
		select pack_id, count(*) as cnt_records
		from public.parameters as t1
		group by pack_id
	) as t1
	where cnt_records != 5
) as inner_t2 on t1.code = inner_t2.pack_id;

-- Все значения который сформировал корректны и в рамках нужного нам диаппазонов?
select * from public.parameters as t1
inner join
(
	select code, name_type_parameter, min_value, max_value
	from public.type_parameters
	where min_value is not null
) as inner_t2 on t1.type_parameter_code = inner_t2.code
where t1.value < inner_t2.min_value or t1.value > inner_t2.max_value;

-- Все единицы измерения верны и корректны по отношению к указанным параметрам?
select * from public.parameters as t1
inner join
(
	-- Подзапрос
	select tp.code, tp.name_type_parameter, um.name_unit, um.symbol
	from public.type_parameters as tp
	inner join public.units_of_measurement as um on tp.id_unit = um.code
) as inner_t2 on t1.type_parameter_code = inner_t2.code
where
	(inner_t2.name_unit = 'Деление угломера' and t1.value not between 0 and 59)
	or (inner_t2.name_unit = 'Градус Цельсия' and t1.value not between -58 and 58)
	or (inner_t2.name_unit = 'Миллиметр ртутного столба' and t1.value not between 500 and 900)
	or (inner_t2.name_unit = 'Метр в секунду' and t1.value not between 0 and 15);