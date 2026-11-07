do $$
-- создадим переменные для удобства заполнения таблиц в дальнейшем
declare
	var_dmk int;
	var_vr int;
begin
	drop table if exists temperature_deviations;
	drop table if exists wind_speeds;
	drop table if exists wind_angle_increments;

	-- создадим таблицы
	create table temperature_deviations(
		height int,
		delta_tau int,
		value_pos int,
		value_neg int not null,
		constraint pk_temperature_deviations primary key (height, delta_tau)
	);
	comment on table temperature_deviations is 
		'Таблица 2: среднее отклонение температуры по стандартным высотам (общая для ДМК и ВР) Ищет по высоте и отклонению приземной виртуальной температуры';
	comment on column temperature_deviations.height is
		'Высота бюллетеня, м';
	comment on column temperature_deviations.delta_tau is
		'Модуль отклонения приземной виртуальной темературы';
	comment on column temperature_deviations.value_pos is
		'Среднее отклонение при положительном delta_tau, null для 40 и 50';
	comment on column temperature_deviations.value_neg is
		'Среднее отклонение при отрицательном delta_tau';
	
	create table wind_speeds(
		equipment_type_code int,
		height int,
		input_value int,
		speed int not null,
		constraint pk_wind_speeds 
			primary key (equipment_type_code, height, input_value),
		constraint fk_wind_speeds_eqp_type
			foreign key (equipment_type_code) references public.types_of_equipment(code)
	);

	comment on table wind_speeds is 
		'Таблица 3: скорость среднего ветра, поиск по обороудованию, высоте и входному параметру (V0 для ДМК и Дг для ВР)';
	comment on column wind_speeds.equipment_type_code is
		'Код типа оборудования, ссылка на types_of_equipment';
	comment on column wind_speeds.height is
		'Высота бюллетеня, м';
	comment on column wind_speeds.input_value is
		'Входной параметр: V0 в м/с для ДМК или Дг в м для ВР';
	comment on column wind_speeds.speed is
		'Скорость среднего ветра, м/с';

	create table wind_angle_increments(
		equipment_type_code int,
		height int,
		delta_angle int not null,
		constraint pk_wind_angle_increments 
			primary key (equipment_type_code, height),
		constraint fk_wind_angle_increments_eqp_type
			foreign key (equipment_type_code) references public.types_of_equipment(code)
	);
	comment on table wind_angle_increments is 
		'Таблица 3: приращение дирекционного угла относительно приземного ветра';
	comment on column wind_angle_increments.equipment_type_code is
		'Код типа оборудования, ссылка на types_of_equipment';
	comment on column wind_angle_increments.height is
		'Высота бюллетеня, м';
	comment on column wind_angle_increments.delta_angle is
		'Приращение дирекционного угла (1-00 хранится как 1)';
		
	-- заполним данными таблицы
	select code into var_dmk from types_of_equipment where type = 'ДМК';
	select code into var_vr from types_of_equipment where type = 'ВР';

	-- Таблица 2, высота 200
	insert into temperature_deviations (height, delta_tau, value_neg, value_pos)
	values
		(200, 1, -1, 1), (200, 2, -2, 2), (200, 3, -3, 3), (200, 4, -4, 4),
		(200, 5, -5, 5), (200, 6, -6, 6), (200, 7, -7, 7), (200, 8, -8, 8),
		(200, 9, -8, 9), (200, 10, -9, 10), (200, 20, -20, 20), (200, 30, -29, 30),
		(200, 40, -39, null), (200, 50, -49, null);

	-- Таблица 2, высота 400
	insert into temperature_deviations (height, delta_tau, value_neg, value_pos)
	values
		(400, 1, -1, 1), (400, 2, -2, 2), (400, 3, -3, 3), (400, 4, -4, 4),
		(400, 5, -5, 5), (400, 6, -6, 6), (400, 7, -6, 7), (400, 8, -7, 8),
		(400, 9, -8, 9), (400, 10, -9, 10), (400, 20, -19, 20), (400, 30, -29, 30),
		(400, 40, -38, null), (400, 50, -48, null);

	-- Таблица 2, высота 800
	insert into temperature_deviations (height, delta_tau, value_neg, value_pos)
	values
		(800, 1, -1, 1), (800, 2, -2, 2), (800, 3, -3, 3), (800, 4, -4, 4),
		(800, 5, -5, 5), (800, 6, -6, 6), (800, 7, -6, 7), (800, 8, -7, 8),
		(800, 9, -7, 9), (800, 10, -8, 10), (800, 20, -18, 20), (800, 30, -28, 30),
		(800, 40, -37, null), (800, 50, -46, null);

	-- Таблица 2, высота 1200
	insert into temperature_deviations (height, delta_tau, value_neg, value_pos)
	values
		(1200, 1, -1, 1), (1200, 2, -2, 2), (1200, 3, -3, 3), (1200, 4, -4, 4),
		(1200, 5, -4, 5), (1200, 6, -5, 6), (1200, 7, -5, 7), (1200, 8, -6, 8),
		(1200, 9, -7, 9), (1200, 10, -8, 10), (1200, 20, -17, 20), (1200, 30, -26, 30),
		(1200, 40, -35, null), (1200, 50, -44, null);

	-- Таблица 2, высота 1600
	insert into temperature_deviations (height, delta_tau, value_neg, value_pos)
	values
		(1600, 1, -1, 1), (1600, 2, -2, 2), (1600, 3, -3, 3), (1600, 4, -3, 4),
		(1600, 5, -4, 5), (1600, 6, -4, 6), (1600, 7, -5, 7), (1600, 8, -6, 8),
		(1600, 9, -7, 9), (1600, 10, -7, 10), (1600, 20, -17, 20), (1600, 30, -25, 30),
		(1600, 40, -34, null), (1600, 50, -42, null);

	-- Таблица 2, высота 2000
	insert into temperature_deviations (height, delta_tau, value_neg, value_pos)
	values
		(2000, 1, -1, 1), (2000, 2, -2, 2), (2000, 3, -3, 3), (2000, 4, -3, 4),
		(2000, 5, -4, 5), (2000, 6, -4, 6), (2000, 7, -5, 7), (2000, 8, -6, 8),
		(2000, 9, -6, 9), (2000, 10, -7, 10), (2000, 20, -16, 20), (2000, 30, -24, 30),
		(2000, 40, -32, null), (2000, 50, -40, null);

	-- Таблица 2, высота 2400
	insert into temperature_deviations (height, delta_tau, value_neg, value_pos)
	values
		(2400, 1, -1, 1), (2400, 2, -2, 2), (2400, 3, -2, 3), (2400, 4, -3, 4),
		(2400, 5, -4, 5), (2400, 6, -4, 6), (2400, 7, -5, 7), (2400, 8, -5, 8),
		(2400, 9, -6, 9), (2400, 10, -7, 10), (2400, 20, -15, 20), (2400, 30, -23, 30),
		(2400, 40, -31, null), (2400, 50, -38, null);

	-- Таблица 2, высота 3000
	insert into temperature_deviations (height, delta_tau, value_neg, value_pos)
	values
		(3000, 1, -1, 1), (3000, 2, -2, 2), (3000, 3, -2, 3), (3000, 4, -3, 4),
		(3000, 5, -4, 5), (3000, 6, -4, 6), (3000, 7, -4, 7), (3000, 8, -5, 8),
		(3000, 9, -5, 9), (3000, 10, -6, 10), (3000, 20, -15, 20), (3000, 30, -22, 30),
		(3000, 40, -30, null), (3000, 50, -37, null);

	-- Таблица 2, высота 4000
	insert into temperature_deviations (height, delta_tau, value_neg, value_pos)
	values
		(4000, 1, -1, 1), (4000, 2, -2, 2), (4000, 3, -2, 3), (4000, 4, -3, 4),
		(4000, 5, -4, 5), (4000, 6, -4, 6), (4000, 7, -4, 7), (4000, 8, -4, 8),
		(4000, 9, -5, 9), (4000, 10, -6, 10), (4000, 20, -14, 20), (4000, 30, -20, 30),
		(4000, 40, -27, null), (4000, 50, -34, null);

	-- Таблица 3, ДМК, высота 200
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_dmk, 200, 3, 4), (var_dmk, 200, 4, 6), (var_dmk, 200, 5, 8),
		(var_dmk, 200, 6, 9), (var_dmk, 200, 7, 10), (var_dmk, 200, 8, 12),
		(var_dmk, 200, 9, 14), (var_dmk, 200, 10, 15), (var_dmk, 200, 11, 16),
		(var_dmk, 200, 12, 18), (var_dmk, 200, 13, 20), (var_dmk, 200, 14, 21),
		(var_dmk, 200, 15, 22);

	-- Таблица 3, ДМК, высота 400
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_dmk, 400, 3, 5), (var_dmk, 400, 4, 7), (var_dmk, 400, 5, 10),
		(var_dmk, 400, 6, 11), (var_dmk, 400, 7, 12), (var_dmk, 400, 8, 14),
		(var_dmk, 400, 9, 17), (var_dmk, 400, 10, 18), (var_dmk, 400, 11, 20),
		(var_dmk, 400, 12, 22), (var_dmk, 400, 13, 23), (var_dmk, 400, 14, 25),
		(var_dmk, 400, 15, 27);

	-- Таблица 3, ДМК, высота 800
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_dmk, 800, 3, 5), (var_dmk, 800, 4, 8), (var_dmk, 800, 5, 10),
		(var_dmk, 800, 6, 11), (var_dmk, 800, 7, 13), (var_dmk, 800, 8, 15),
		(var_dmk, 800, 9, 18), (var_dmk, 800, 10, 19), (var_dmk, 800, 11, 21),
		(var_dmk, 800, 12, 23), (var_dmk, 800, 13, 25), (var_dmk, 800, 14, 27),
		(var_dmk, 800, 15, 28);

	-- Таблица 3, ДМК, высота 1200
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_dmk, 1200, 3, 5), (var_dmk, 1200, 4, 8), (var_dmk, 1200, 5, 11),
		(var_dmk, 1200, 6, 12), (var_dmk, 1200, 7, 13), (var_dmk, 1200, 8, 16),
		(var_dmk, 1200, 9, 19), (var_dmk, 1200, 10, 20), (var_dmk, 1200, 11, 22),
		(var_dmk, 1200, 12, 24), (var_dmk, 1200, 13, 26), (var_dmk, 1200, 14, 28),
		(var_dmk, 1200, 15, 30);

	-- Таблица 3, ДМК, высота 1600
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_dmk, 1600, 3, 6), (var_dmk, 1600, 4, 8), (var_dmk, 1600, 5, 11),
		(var_dmk, 1600, 6, 13), (var_dmk, 1600, 7, 14), (var_dmk, 1600, 8, 17),
		(var_dmk, 1600, 9, 20), (var_dmk, 1600, 10, 21), (var_dmk, 1600, 11, 23),
		(var_dmk, 1600, 12, 25), (var_dmk, 1600, 13, 27), (var_dmk, 1600, 14, 29),
		(var_dmk, 1600, 15, 32);

	-- Таблица 3, ДМК, высота 2000
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_dmk, 2000, 3, 6), (var_dmk, 2000, 4, 9), (var_dmk, 2000, 5, 11),
		(var_dmk, 2000, 6, 13), (var_dmk, 2000, 7, 14), (var_dmk, 2000, 8, 17),
		(var_dmk, 2000, 9, 20), (var_dmk, 2000, 10, 21), (var_dmk, 2000, 11, 24),
		(var_dmk, 2000, 12, 26), (var_dmk, 2000, 13, 28), (var_dmk, 2000, 14, 30),
		(var_dmk, 2000, 15, 32);

	-- Таблица 3, ДМК, высота 2400
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_dmk, 2400, 3, 6), (var_dmk, 2400, 4, 9), (var_dmk, 2400, 5, 12),
		(var_dmk, 2400, 6, 14), (var_dmk, 2400, 7, 15), (var_dmk, 2400, 8, 18),
		(var_dmk, 2400, 9, 21), (var_dmk, 2400, 10, 22), (var_dmk, 2400, 11, 25),
		(var_dmk, 2400, 12, 27), (var_dmk, 2400, 13, 29), (var_dmk, 2400, 14, 32),
		(var_dmk, 2400, 15, 34);

	-- Таблица 3, ДМК, высота 3000
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_dmk, 3000, 3, 6), (var_dmk, 3000, 4, 9), (var_dmk, 3000, 5, 12),
		(var_dmk, 3000, 6, 14), (var_dmk, 3000, 7, 15), (var_dmk, 3000, 8, 18),
		(var_dmk, 3000, 9, 21), (var_dmk, 3000, 10, 23), (var_dmk, 3000, 11, 25),
		(var_dmk, 3000, 12, 28), (var_dmk, 3000, 13, 30), (var_dmk, 3000, 14, 32),
		(var_dmk, 3000, 15, 36);

	-- Таблица 3, ДМК, высота 4000
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_dmk, 4000, 3, 6), (var_dmk, 4000, 4, 10), (var_dmk, 4000, 5, 12),
		(var_dmk, 4000, 6, 14), (var_dmk, 4000, 7, 16), (var_dmk, 4000, 8, 19),
		(var_dmk, 4000, 9, 22), (var_dmk, 4000, 10, 24), (var_dmk, 4000, 11, 26),
		(var_dmk, 4000, 12, 29), (var_dmk, 4000, 13, 32), (var_dmk, 4000, 14, 34),
		(var_dmk, 4000, 15, 36);

	-- Таблица 3, ВР, высота 200
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_vr, 200, 40, 3), (var_vr, 200, 50, 4), (var_vr, 200, 60, 5),
		(var_vr, 200, 70, 6), (var_vr, 200, 80, 7), (var_vr, 200, 90, 7),
		(var_vr, 200, 100, 8), (var_vr, 200, 110, 9), (var_vr, 200, 120, 10),
		(var_vr, 200, 130, 11), (var_vr, 200, 140, 12), (var_vr, 200, 150, 12);

	-- Таблица 3, ВР, высота 400
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_vr, 400, 40, 4), (var_vr, 400, 50, 5), (var_vr, 400, 60, 6),
		(var_vr, 400, 70, 7), (var_vr, 400, 80, 8), (var_vr, 400, 90, 9),
		(var_vr, 400, 100, 10), (var_vr, 400, 110, 11), (var_vr, 400, 120, 12),
		(var_vr, 400, 130, 13), (var_vr, 400, 140, 14), (var_vr, 400, 150, 15);

	-- Таблица 3, ВР, высота 800
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_vr, 800, 40, 4), (var_vr, 800, 50, 5), (var_vr, 800, 60, 6),
		(var_vr, 800, 70, 7), (var_vr, 800, 80, 8), (var_vr, 800, 90, 9),
		(var_vr, 800, 100, 10), (var_vr, 800, 110, 11), (var_vr, 800, 120, 13),
		(var_vr, 800, 130, 14), (var_vr, 800, 140, 15), (var_vr, 800, 150, 16);

	-- Таблица 3, ВР, высота 1200
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_vr, 1200, 40, 4), (var_vr, 1200, 50, 5), (var_vr, 1200, 60, 7),
		(var_vr, 1200, 70, 8), (var_vr, 1200, 80, 8), (var_vr, 1200, 90, 9),
		(var_vr, 1200, 100, 11), (var_vr, 1200, 110, 12), (var_vr, 1200, 120, 13),
		(var_vr, 1200, 130, 15), (var_vr, 1200, 140, 15), (var_vr, 1200, 150, 16);

	-- Таблица 3, ВР, высота 1600
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_vr, 1600, 40, 4), (var_vr, 1600, 50, 6), (var_vr, 1600, 60, 7),
		(var_vr, 1600, 70, 8), (var_vr, 1600, 80, 9), (var_vr, 1600, 90, 10),
		(var_vr, 1600, 100, 11), (var_vr, 1600, 110, 13), (var_vr, 1600, 120, 14),
		(var_vr, 1600, 130, 15), (var_vr, 1600, 140, 17), (var_vr, 1600, 150, 17);

	-- Таблица 3, ВР, высота 2000
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_vr, 2000, 40, 4), (var_vr, 2000, 50, 6), (var_vr, 2000, 60, 7),
		(var_vr, 2000, 70, 8), (var_vr, 2000, 80, 9), (var_vr, 2000, 90, 10),
		(var_vr, 2000, 100, 11), (var_vr, 2000, 110, 13), (var_vr, 2000, 120, 14),
		(var_vr, 2000, 130, 16), (var_vr, 2000, 140, 17), (var_vr, 2000, 150, 18);

	-- Таблица 3, ВР, высота 2400
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_vr, 2400, 40, 4), (var_vr, 2400, 50, 6), (var_vr, 2400, 60, 8),
		(var_vr, 2400, 70, 9), (var_vr, 2400, 80, 9), (var_vr, 2400, 90, 10),
		(var_vr, 2400, 100, 12), (var_vr, 2400, 110, 14), (var_vr, 2400, 120, 15),
		(var_vr, 2400, 130, 16), (var_vr, 2400, 140, 18), (var_vr, 2400, 150, 19);

	-- Таблица 3, ВР, высота 3000
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_vr, 3000, 40, 5), (var_vr, 3000, 50, 6), (var_vr, 3000, 60, 8),
		(var_vr, 3000, 70, 9), (var_vr, 3000, 80, 10), (var_vr, 3000, 90, 11),
		(var_vr, 3000, 100, 12), (var_vr, 3000, 110, 14), (var_vr, 3000, 120, 15),
		(var_vr, 3000, 130, 17), (var_vr, 3000, 140, 18), (var_vr, 3000, 150, 19);

	-- Таблица 3, ВР, высота 4000
	insert into wind_speeds (equipment_type_code, height, input_value, speed)
	values
		(var_vr, 4000, 40, 5), (var_vr, 4000, 50, 6), (var_vr, 4000, 60, 8),
		(var_vr, 4000, 70, 9), (var_vr, 4000, 80, 10), (var_vr, 4000, 90, 11),
		(var_vr, 4000, 100, 12), (var_vr, 4000, 110, 14), (var_vr, 4000, 120, 16),
		(var_vr, 4000, 130, 18), (var_vr, 4000, 140, 19), (var_vr, 4000, 150, 20);

	-- Таблица 3, приращение угла
	insert into wind_angle_increments (equipment_type_code, height, delta_angle)
	values
		(var_dmk, 200, 1), (var_dmk, 400, 2), (var_dmk, 800, 3),
		(var_dmk, 1200, 3), (var_dmk, 1600, 4), (var_dmk, 2000, 4),
		(var_dmk, 2400, 4), (var_dmk, 3000, 5), (var_dmk, 4000, 5),
		(var_vr, 200, 0), (var_vr, 400, 1), (var_vr, 800, 2),
		(var_vr, 1200, 2), (var_vr, 1600, 3), (var_vr, 2000, 3),
		(var_vr, 2400, 3), (var_vr, 3000, 4), (var_vr, 4000, 4);
end $$;