do $$
begin
	drop table if exists temperature_deviations;
	drop table if exists wind_speeds;
	drop table if exists wind_angle_increments;
	
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
	
end $$;