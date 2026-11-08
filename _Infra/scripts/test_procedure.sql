-- расчет ДМК
do $$
begin
	begin
		call public.calc_meteo_bulletin(row(1, 100, 25, 765, 15, 6, null)::public.meteo_params_type, 1);
	end;
	
end $$;

with p as (
	select row(1, 100, 25, 765, 15, 6, null)::public.meteo_params_type as v
)
select "Высота", "TT", "HH", "CC"
from (
	select
		'ДДЧЧМ / ВВВВ / БББТТ' as "Высота",
		public.calc_meteo_ddchhm(now()::timestamp) as "TT",
		public.calc_meteo_vvvv((p.v).post_height) as "HH",
		public.calc_meteo_bbbtt((p.v).temperature, (p.v).pressure) as "CC",
		0 as ord
	from p

	union all

	select r.height::text, r.tt, r.hh, r.cc, r.height
	from meteo_bulletin_result r
) t
order by ord;


-- расчёт ВР
do $$
begin
	call public.calc_meteo_bulletin(row(2, 100, 25, 765, 15, null, 100)::public.meteo_params_type, 2);
end $$;

with p as (
	select row(2, 100, 25, 765, 15, null, 100)::public.meteo_params_type as v
)
select "Высота", "TT", "HH", "CC"
from (
	select
		'ДДЧЧМ / ВВВВ / БББТТ' as "Высота",
		public.calc_meteo_ddchhm(now()::timestamp) as "TT",
		public.calc_meteo_vvvv((p.v).post_height) as "HH",
		public.calc_meteo_bbbtt((p.v).temperature, (p.v).pressure) as "CC",
		0 as ord
	from p

	union all

	select r.height::text, r.tt, r.hh, r.cc, r.height
	from meteo_bulletin_result r
) t
order by ord;