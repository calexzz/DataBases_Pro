drop table if exists test_results;

do
$test$
declare
    r record;
    pts public.interpolation_type;
    actual numeric;
    status text;
begin
    create temp table test_results (
        description text,
		t numeric,
        x0 numeric,
        y0 numeric,
        x1 numeric,
        y1 numeric,
        expected numeric,
        actual numeric,
        status text
    );

    for r in
        select *
          from (values
              ('t=0', 0::numeric, 0.5::numeric),
              ('t=10', 10, 1),
              ('t=15', 15, 1),
              ('t=23', 23, 1.8),
              ('t=25', 25, 2),
              ('t=28', 28, 2.9),
              ('t=40', 40, 4.5),
              ('t = -5', -5, 0.5),
              ('t=45', 45, 4.5)
          ) as v(description, t, expected)
    loop
        pts := public.get_interpolation_params(r.t);
        actual := public.calc_interpolation(r.t, pts);

        if abs(actual - r.expected) < 0.001 then
            status := 'TRUE';
        else
            status := 'FALSE';
        end if;

        insert into test_results
        values (r.description, r.t, pts.x0, pts.y0, pts.x1, pts.y1, r.expected, actual, status);
    end loop;
end
$test$;

select description, x0,y0,x1,y1, actual, status from test_results order by t;