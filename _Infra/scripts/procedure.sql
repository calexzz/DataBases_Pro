create or replace procedure public.calc_meteo_bulletin(
    par_params public.meteo_params_type,
    par_equipment_type integer)
language plpgsql
as $body$
declare
    -- TT
    var_delta integer;
    var_abs integer;
    var_units integer;
    var_tens integer;
    var_type_id integer;
    var_header integer[];
    var_row integer[];
    var_sum integer;
    var_tt text;
    -- CC
    var_cc_type integer;
    var_cc_input numeric;
    var_cc_min integer;
    var_cc_header integer[];
    var_cc_x0 integer;
    var_cc_x1 integer;
    var_cc_pos0 integer;
    var_cc_pos1 integer;
    var_cc_row integer[];
    var_cc text;
    -- HH
    var_hh_type integer;
    var_hh_row integer[];
    var_hh text;

    var_height record;
begin
	-- создадим временную таблицу для отображения выходных данных
	drop table if exists meteo_bulletin_result;
	
    create temp table if not exists meteo_bulletin_result
    (
        height integer,
        tt text,
        hh text,
        cc text
    );

    -- dT0, считается один раз для всех высот
    var_delta := public.calc_meteo_delta_temperature(par_params.temperature);
    var_abs := abs(var_delta);

    -- 9 - отрицательные значения, 8 - положительные
    var_type_id := case when var_delta < 0 then 9 else 8 end;

    -- разложим на десятки и единицы
    var_units := var_abs % 10;
    var_tens := var_abs - var_units;

    -- заголовок Таблицы 2
    select h.h_values
    into var_header
    from public.calc_correction_types t
    join public.calc_correction_headers h on h.id = t.header_id
    where t.id = var_type_id;

    -- Таблица 3 по типу оборудования
    if par_equipment_type = 1 then -- ДМК: столбец по скорости ветра
        var_cc_type := 6;
        var_hh_type := 7;
        var_cc_input := par_params.wind_speed;
        var_cc_min := 3;
    elsif par_equipment_type = 2 then -- ВР: столбец по дальности сноса пуль
        var_cc_type := 4;
        var_hh_type := 5;
        var_cc_input := par_params.bullet_drift_range;
        var_cc_min := 40;
    else
        raise exception 'Неизвестный тип оборудования %', par_equipment_type;
    end if;

    if var_cc_input is null then
        raise exception 'Не задан параметр для расчета скорости ветра (тип оборудования %)', par_equipment_type;
    end if;

    if par_params.wind_direction is null
       or par_params.wind_direction < 0 or par_params.wind_direction > 59 then
        raise exception 'Направление ветра % вне диапазона 0-59', par_params.wind_direction;
    end if;

    if var_cc_input >= var_cc_min then
        select h.h_values
        into var_cc_header
        from public.calc_correction_types t
        join public.calc_correction_headers h on h.id = t.header_id
        where t.id = var_cc_type;

        -- ближайшие столбцы слева и справа от значения
        select max(v) filter (where v <= var_cc_input),
               min(v) filter (where v >= var_cc_input)
        into var_cc_x0, var_cc_x1
        from unnest(var_cc_header) as v;

        if var_cc_x0 is null or var_cc_x1 is null then
            raise exception 'Значение % выходит за пределы столбцов Таблицы 3', var_cc_input;
        end if;

        var_cc_pos0 := array_position(var_cc_header, var_cc_x0);
        var_cc_pos1 := array_position(var_cc_header, var_cc_x1);
    end if;
	
	-- цикл по типовым высотам и расчёт ТТ НН и СС
    for var_height in
        select id, height from public.calc_correction_heights order by height
    loop
        -- TT
        select c.row_values
        into var_row
        from public.calc_correction c
        where c.type_id = var_type_id
          and c.height_id = var_height.id;

        var_sum := 0;

        if var_tens > 0 then
            var_sum := var_sum + var_row[array_position(var_header, var_tens)];
        end if;

        if var_units > 0 then
            var_sum := var_sum + var_row[array_position(var_header, var_units)];
        end if;

        if var_sum is null then
            raise exception 'В Таблице 2 нет значения: высота %, отклонение %', var_height.height, var_delta;
        end if;

        if var_sum < 0 then
            var_sum := abs(var_sum) + public.get_meteo_constant('temperature_negative_offset');
        end if;

        var_tt := lpad(var_sum::text, 2, '0');

        if var_cc_input < var_cc_min then
            -- направление и скорость ветра нули
            var_cc := '00';
            var_hh := '00';
        else
            -- CC: интерполяция между соседними столбцами
            select c.row_values
            into var_cc_row
            from public.calc_correction c
            where c.type_id = var_cc_type
              and c.height_id = var_height.id;

            var_cc := lpad(
                round(public.calc_interpolation(
                    var_cc_input,
                    row(var_cc_x0, var_cc_row[var_cc_pos0], var_cc_x1, var_cc_row[var_cc_pos1])::public.interpolation_type
                ))::integer::text,
                2, '0');

            -- HH: направление ветра + приращение угла, по модулю 60
            select c.row_values
            into var_hh_row
            from public.calc_correction c
            where c.type_id = var_hh_type
              and c.height_id = var_height.id;

            var_hh := lpad(((round(par_params.wind_direction)::integer + var_hh_row[1]) % 60)::text, 2, '0');
        end if;

        insert into meteo_bulletin_result(height, tt, hh, cc)
        values (var_height.height, var_tt, var_hh, var_cc);
    end loop;
end
$body$;