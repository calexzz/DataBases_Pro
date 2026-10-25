select
	row_number() over (),
	temperature as x0, 
	correction as y0,
	lead(temperature) over (order by temperature) as x1,
	lead(correction)  over (order by temperature) as y1
	from calc_temperature_correction

select
	row_number() over (order by x0) as id,
	x0, y0, x1, y1,
	round((x0 + x1) / 2, 2) as x,
	round(calc_interpolation((x0 + x1) / 2, (x0, y0, x1, y1)::interpolation_type),2) as y
from (
	select
		temperature as x0,
		correction  as y0,
		lead(temperature, 1, temperature) over (order by temperature) as x1,
		lead(correction, 1, correction)  over (order by temperature) as y1
	from calc_temperature_correction
) t;


select * from errors;

insert into errors (code, description) values
(0, 'Отсутсвует значение');


select
	row_number() over (order by pack_code) as id,
	pack_code, equipment_type, altitude, temperature, pressure,
	wind_direction, wind_speed, bullet,
	err.code is not null as has_error,
	err.description
from (
	select
		pk.code as pack_code,
		te.type as equipment_type,
		max(case when tp.name_type_parameter = 'Высота метеопоста' then p.value end) as altitude,
		max(case when tp.name_type_parameter = 'Температура' then p.value end) as temperature,
		max(case when tp.name_type_parameter = 'Давление' then p.value end) as pressure,
		max(case when tp.name_type_parameter = 'Направление ветра' then p.value end) as wind_direction,
		max(case when tp.name_type_parameter = 'Скорость ветра' then p.value end) as wind_speed,
		max(case when tp.name_type_parameter = 'Дальность сноса пуль' then p.value end) as bullet
	from packs pk
	join types_of_equipment te on te.code = pk.equipment_type_id
	join parameters p on p.pack_id = pk.code
	join type_parameters tp on tp.code = p.type_parameter_code
	group by pk.code, te.type
) t
left join errors err on err.code = coalesce(
	check_param('Температура', temperature, 1),
	check_param('Давление', pressure, 2),
	check_param('Направление ветра', wind_direction, 3),
	check_param('Скорость ветра', wind_speed, 4),
	check_param('Дальность сноса пуль', bullet, 5)
)
order by id;


