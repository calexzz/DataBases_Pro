select
	row_number() over (order by t.sort_order, t.name) as "№",
	t.name as "Наименование",
	t.type as "Тип"
from (
	-- подзапрос
	select table_name as name, 'Таблица' as type, 1 as sort_order
	from information_schema.tables
	where table_schema = 'public'
		and table_type = 'BASE TABLE'

	union all

	select sequence_name, 'Счётчик', 2
	from information_schema.sequences
	where sequence_schema = 'public'
) t
order by t.sort_order, t.name;