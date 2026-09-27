-- Справочник базовых единиц измерения
create table if not exists base_units_of_measurement (
	code int primary key,
	name_base_unit varchar(100) not null,
	symbol_base varchar(12) not null
);

comment on table base_units_of_measurement is 'Справочник базовых единиц измерения';
comment on column base_units_of_measurement.code is 'Уникальный код базовой единицы';
comment on column base_units_of_measurement.name_base_unit is 'Наименование базовой величины';
comment on column base_units_of_measurement.symbol_base is 'Обозначение базовой величины';

-- Заполняем данные
insert into base_units_of_measurement(code, name_base_unit, symbol_base) values 
(1, 'Длина', 'м'),
(2, 'Температура', '°C'),
(3, 'Давление', 'мм рт. ст.'),
(4, 'Скорость', 'м/с'),
(5, 'Угол', 'д.у.');

-- Справочник единиц измерения
create table if not exists units_of_measurement(
	code int primary key,
	name_unit varchar(100) not null,
	symbol varchar(10),
	base_unit_code integer
);

comment on table units_of_measurement is 'Справочник единиц измерения';
comment on column units_of_measurement.code is 'Уникальный код единицы измерения';
comment on column units_of_measurement.name_unit is 'Наименование единицы измерения';
comment on column units_of_measurement.symbol is 'Обозначение единицы';
comment on column units_of_measurement.base_unit_code is 'Код базовой единицы измерения';

-- Заполняем данные
insert into units_of_measurement(code,name_unit,symbol,base_unit_code) values
(1, 'Метр', 'м', 1),
(2, 'Градус Цельсия', '°C', 2),
(3, 'Миллиметр ртутного столба', 'мм рт. ст.', 3),
(4, 'Метр в секунду', 'м/с', 4),
(5, 'Деление угломера', 'д.у.', 5);

-- Справочник типов параметров
create table if not exists type_parameters (
	code int primary key,
	name_type_parameter varchar(100) not null,
	id_unit integer not null,
	min_value numeric,
	max_value numeric
);

comment on table type_parameters is 'Справочник типов параметров';
comment on column type_parameters.code is 'Уникальный код типа параметра';
comment on column type_parameters.name_type_parameter is 'Наименование параметра';
comment on column type_parameters.id_unit is 'Код единицы измерения';
comment on column type_parameters.min_value is 'Минимальное значение';
comment on column type_parameters.max_value is 'Максимальное значение';

-- Заполняем данные
insert into type_parameters(code,name_type_parameter,id_unit,min_value,max_value) values
(1, 'Высота метеопоста', 1, null, null),
(2, 'Температура', 2, -58, 58),
(3, 'Давление', 3, 500, 900),
(4, 'Направление ветра', 5, 0, 59),
(5, 'Скорость ветра', 4, 0, 15),
(6, 'Дальность сноса пуль', 1, 0, 150);

alter table parameters add column if not exists type_parameter_code integer;
comment on column parameters.type_parameter_code is 'Код типа параметра';

update parameters set type_parameter_code = 1 where code in (1, 6);
update parameters set type_parameter_code = 2 where code in (2, 7);
update parameters set type_parameter_code = 3 where code in (3, 8);
update parameters set type_parameter_code = 4 where code in (4, 9);
update parameters set type_parameter_code = 5 where code = 5;
update parameters set type_parameter_code = 6 where code = 10;

alter table parameters drop column if exists param_name;

-- Убрал связь должности с пачками
alter table packs drop column if exists position_id;

-- Прокомментировал таблицы
comment on table types_of_equipment is 'Справочник типов оборудования';
comment on column types_of_equipment.code is 'Уникальный код типа оборудования';
comment on column types_of_equipment.type is 'Наименование типа оборудования';

comment on table positions is 'Справочник должностей';
comment on column positions.code is 'Уникальный код должности';
comment on column positions.title is 'Наименование должности';

comment on table users is 'Пользователи';
comment on column users.code is 'Уникальный код пользователя';
comment on column users.full_name is 'ФИО пользователя';
comment on column users.position_id is 'Код должности пользователя';

comment on table packs is 'Пачки измерений';
comment on column packs.code is 'Уникальный код пачки';
comment on column packs.user_id is 'Код пользователя, заведшего пачку';
comment on column packs.equipment_type_id is 'Код типа оборудования';
comment on column packs.created_at is 'Дата и время создания пачки';

comment on table parameters is 'Измеренные значения параметров';
comment on column parameters.code is 'Уникальный код записи параметра';
comment on column parameters.pack_id is 'Код пачки';
comment on column parameters.value is 'Значение параметра';

select
	packs.created_at,
	packs.code,
	users.full_name,
	type_parameters.name_type_parameter || ' (' || units_of_measurement.symbol || ')',
	parameters.value
from
	parameters,
	packs,
	users,
	type_parameters,
	units_of_measurement
where
	parameters.pack_id = packs.code
	and packs.user_id = users.code
	and parameters.type_parameter_code = type_parameters.code
	and type_parameters.id_unit = units_of_measurement.code;