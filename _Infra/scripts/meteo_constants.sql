do $do$
begin
    create table if not exists public.meteo_constants (
        code           text primary key,
        constant_value numeric(10,2) not null,
        description    text
    );

    comment on table public.meteo_constants is 'Константы для расчета Метео приближенный';
    comment on column public.meteo_constants.code is 'Код константы';
    comment on column public.meteo_constants.constant_value is 'Значение';
    comment on column public.meteo_constants.description is 'Описание';

    insert into public.meteo_constants (code, constant_value, description)
    select v.code, v.constant_value, v.description
    from (values
        ('normal_pressure', 750, 'Табличное давление, мм рт. ст.'),
        ('normal_temperature', 15.9, 'Табличная виртуальная температура, градусы Цельсия'),
        ('pressure_negative_offset', 500, 'Признак отрицательного отклонения давления: к модулю прибавляется это число'),
        ('temperature_negative_offset', 50, 'Признак отрицательного отклонения температуры: к модулю прибавляется это число'),
        ('minutes_step', 10, 'Шаг минут в ДДЧЧМ: последняя цифра это десятки минут')
    ) as v(code, constant_value, description)
    where not exists (select 1 from public.meteo_constants c where c.code = v.code);

    execute $f$
        create or replace function public.get_meteo_constant(par_code text)
        returns numeric
        language plpgsql
        stable
        as $body$
        declare
            var_value numeric;
        begin
            select c.constant_value into var_value
            from public.meteo_constants c
            where c.code = par_code;

            if not found then
                raise exception 'Константа % не найдена', par_code;
            end if;

            return var_value;
        end
        $body$
    $f$;
end $do$;