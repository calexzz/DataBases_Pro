-- Список параметров с ошибками
with pack_params as (
    select
        pk.code as pack_code,
        pk.equipment_type_id,
        te.type as equipment_type,
        max(case when tp.name_type_parameter = 'Высота метеопоста' then p.value end) as altitude,
        max(case when tp.name_type_parameter = 'Температура' then p.value end) as temperature,
        max(case when tp.name_type_parameter = 'Давление' then p.value end) as pressure,
        max(case when tp.name_type_parameter = 'Направление ветра' then p.value end) as wind_direction,
        max(case when tp.name_type_parameter = 'Скорость ветра' then p.value end) as wind_speed,
        max(case when tp.name_type_parameter = 'Дальность сноса пуль' then p.value end) as bullet
    from packs pk
    left join types_of_equipment te on te.code = pk.equipment_type_id
    left join parameters p on p.pack_id = pk.code
    left join type_parameters tp on tp.code = p.type_parameter_code
    group by pk.code, pk.equipment_type_id, te.type
),
checked as (
    select
        pp.*,
        check_meteo_params(
            row(equipment_type_id, altitude, temperature, pressure, wind_direction, wind_speed, bullet)
            ::meteo_params_type
        ) as err
    from pack_params pp
)
select
    pack_code as "№",
    equipment_type as "Тип оборудования",
    altitude as "Высота метеопоста",
    temperature as "Температура",
    pressure as "Давление",
    wind_direction as "Направление ветра",
    wind_speed as "Скорость ветра",
    bullet as "Дальность сноса пуль",
    err is not null as "Флаг: Есть ошибка",
    err as "Описание ошибки"
from checked
order by pack_code;

-- лучший стрелок
with pack_params as (
    select
        pk.code as pack_code,
        pk.user_id,
        pk.equipment_type_id,
        max(case when tp.name_type_parameter = 'Высота метеопоста' then p.value end) as altitude,
        max(case when tp.name_type_parameter = 'Температура' then p.value end) as temperature,
        max(case when tp.name_type_parameter = 'Давление' then p.value end) as pressure,
        max(case when tp.name_type_parameter = 'Направление ветра' then p.value end) as wind_direction,
        max(case when tp.name_type_parameter = 'Скорость ветра' then p.value end) as wind_speed,
        max(case when tp.name_type_parameter = 'Дальность сноса пуль' then p.value end) as bullet
    from packs pk
    left join parameters p on p.pack_id = pk.code
    left join type_parameters tp on tp.code = p.type_parameter_code
    group by pk.code, pk.user_id, pk.equipment_type_id
),
checked as (
    select
        pp.pack_code,
        pp.user_id,
        check_meteo_params(
            row(equipment_type_id, altitude, temperature, pressure, wind_direction, wind_speed, bullet)
            ::meteo_params_type
        ) as err
    from pack_params pp
),
by_user as (
    select
        u.code,
        u.full_name,
        count(c.pack_code) as packs_count,
        count(c.pack_code) filter (where c.err is not null) as packs_with_errors,
        coalesce(sum(cardinality(string_to_array(c.err, ', '))), 0) as errors_count
    from users u
    left join checked c on c.user_id = u.code
    group by u.code, u.full_name
)
select
    rank() over (order by errors_count) as "Место",
    full_name        as "Пользователь",
    packs_count      as "Пачек",
    packs_with_errors as "Пачек с ошибками",
    errors_count     as "Количество ошибок"
from by_user
order by "Место", full_name;