do $do$
begin
	-- справочник ошибок
    create table if not exists public.errors (
        code integer primary key,
        description varchar(200) not null
    );

    comment on table public.errors is 'Справочник ошибок входных параметров';

    insert into public.errors (code, description)
    select v.code, v.description
    from (values
        (0, 'Отсутствует значение'),
        (1, 'Температура вне допустимого диапазона'),
        (2, 'Давление вне допустимого диапазона'),
        (3, 'Направление ветра вне допустимого диапазона'),
        (4, 'Скорость ветра вне допустимого диапазона'),
        (5, 'Дальность сноса пуль вне допустимого диапазона')
    ) as v(code, description)
    where not exists (select 1 from public.errors e where e.code = v.code);
	
    -- у каждого параметра свой код ошибки диапазона
    alter table public.type_parameters add column if not exists error_code integer;

    comment on column public.type_parameters.error_code is 'Код ошибки из errors при выходе значения за допустимый диапазон';

    update public.type_parameters set error_code = 1 where code = 2 and error_code is null;
    update public.type_parameters set error_code = 2 where code = 3 and error_code is null;
    update public.type_parameters set error_code = 3 where code = 4 and error_code is null;
    update public.type_parameters set error_code = 4 where code = 5 and error_code is null;
    update public.type_parameters set error_code = 5 where code = 6 and error_code is null;

	-- таблица применимых параметров
	create table if not exists public.equipment_type_parameters (
        equipment_type_code integer not null,
        type_parameter_code integer not null,
        primary key (equipment_type_code, type_parameter_code)
    );

    comment on table public.equipment_type_parameters is 'Какие входные параметры применимы к типу оборудования';

    insert into public.equipment_type_parameters (equipment_type_code, type_parameter_code)
    select te.code, tp.code
    from public.types_of_equipment te
    join public.type_parameters tp
      on (te.type = 'ДМК' and tp.code in (1, 2, 3, 4, 5))
      or (te.type = 'ВР'  and tp.code in (1, 2, 3, 4, 6))
    where not exists (
        select 1 from public.equipment_type_parameters x
        where x.equipment_type_code = te.code and x.type_parameter_code = tp.code
    );

    -- новый тип: список параметров
    drop function if exists public.check_meteo_params(public.meteo_params_type);
    drop type if exists public.meteo_params_type;

    create type public.meteo_params_type as (
        equipment_type_code integer,
        post_height numeric,
        temperature numeric,
        pressure numeric,
        wind_direction numeric,
        wind_speed numeric,
        bullet_drift_range numeric
    );

    execute $f$
        create or replace function public.check_meteo_params(p public.meteo_params_type)
        returns text
        language plpgsql
        as $body$
        declare
            v_result text;
        begin
            select string_agg(
				e.description || case when v.val is null then ' (' || t.name_type_parameter || ')' else '' end, 
				', ' order by t.code)
            into v_result
            from (values
                (1, p.post_height),
                (2, p.temperature),
                (3, p.pressure),
                (4, p.wind_direction),
                (5, p.wind_speed),
                (6, p.bullet_drift_range)
            ) as v(type_code, val)
            join public.equipment_type_parameters ep
              on ep.equipment_type_code = p.equipment_type_code
             and ep.type_parameter_code = v.type_code
            join public.type_parameters t on t.code = v.type_code
            join public.errors e on e.code = case when v.val is null then 0 else t.error_code end
            where v.val is null
               or v.val < t.min_value
               or v.val > t.max_value;

            return v_result;
        end
        $body$
    $f$;
end $do$;