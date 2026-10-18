do $do$
begin
    drop type if exists public.interpolation_type cascade;

    create type public.interpolation_type as (
        x0 numeric,
        y0 numeric,
        x1 numeric,
        y1 numeric
    );

    create or replace function public.get_interpolation_params(t_in numeric)
    returns public.interpolation_type
    language sql
    as $body$
        select
            coalesce(
                (select max(t1.temperature)
                   from public.calc_temperature_correction t1
                  where t1.temperature <= t_in),
                t_in
            ) as x0,

            coalesce(
                (select t3.correction
                   from public.calc_temperature_correction t3
                  where t3.temperature = (select max(t1.temperature)
                                            from public.calc_temperature_correction t1
                                           where t1.temperature <= t_in)),
                (select t4.correction
                   from public.calc_temperature_correction t4
                  where t4.temperature = (select min(t2.temperature)
                                            from public.calc_temperature_correction t2))
            ) as y0,

            coalesce(
                (select min(t1.temperature)
                   from public.calc_temperature_correction t1
                  where t1.temperature >= t_in),
                t_in
            ) as x1,

            coalesce(
                (select t3.correction
                   from public.calc_temperature_correction t3
                  where t3.temperature = (select min(t1.temperature)
                                            from public.calc_temperature_correction t1
                                           where t1.temperature >= t_in)),
                (select t4.correction
                   from public.calc_temperature_correction t4
                  where t4.temperature = (select max(t2.temperature)
                                            from public.calc_temperature_correction t2))
            ) as y1;
    $body$;

    create or replace function public.calc_interpolation(x numeric, p public.interpolation_type)
    returns numeric
    language plpgsql
    as $body$
    begin
        if p.x1 = p.x0 then
            return p.y0;
        end if;

        return p.y0 + (x - p.x0) * (p.y1 - p.y0) / (p.x1 - p.x0);
    end
    $body$;
end
$do$;