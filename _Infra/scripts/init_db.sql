-- ddl
create table if not exists types_of_equipment (
	code int primary key,
	type text not null
);
create table if not exists positions (
	code int primary key,
	title text not null
);
create table if not exists users (
	code int primary key,
	full_name text not null,
	position_id INT not null references positions(code)
);
create table if not exists packs (
	code int primary key,
	user_id int not null references users(code),
	position_id int not null references positions(code),
	equipment_type_id int not null references types_of_equipment(code),
	created_at timestamp not null default current_timestamp
);
create table if not exists parameters (
	code int primary key,
	pack_id int not null references packs(code),
	param_name text not null,
	value numeric not null
);

-- dml
-- types_of_equipment
INSERT INTO types_of_equipment(code, type) SELECT 1, 'ДМК'
WHERE NOT EXISTS (
    SELECT 1 FROM types_of_equipment WHERE code = 1
);

INSERT INTO types_of_equipment(code, type) SELECT 2, 'ВР'
WHERE NOT EXISTS (
    SELECT 1 FROM types_of_equipment WHERE code = 2
);

-- positions
INSERT INTO positions(code, title) SELECT 1, 'Рядовой'
WHERE NOT EXISTS (
    SELECT 1 FROM positions WHERE code = 1
);

INSERT INTO positions(code, title) SELECT 2, 'Сержант'
WHERE NOT EXISTS (
    SELECT 1 FROM positions WHERE code = 2
);

INSERT INTO positions(code, title) SELECT 3, 'Мл. Сержант'
WHERE NOT EXISTS (
    SELECT 1 FROM positions WHERE code = 3
);

INSERT INTO positions(code, title) SELECT 4, 'Ст. Сержант'
WHERE NOT EXISTS (
    SELECT 1 FROM positions WHERE code = 4
);

INSERT INTO positions (code, title) SELECT 5, 'Лейтенант'
WHERE NOT EXISTS (
    SELECT 1 FROM positions WHERE code = 5
);

-- users
INSERT INTO users (code, full_name, position_id)
SELECT 1, 'Иванов Иван Иванович', 1
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE code = 1
);

INSERT INTO users (code, full_name, position_id)
SELECT 2, 'Петров Пётр Петрович', 2
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE code = 2
);

INSERT INTO users (code, full_name, position_id)
SELECT 3, 'Сидоров Сидор Сидорович', 5
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE code = 3
);

INSERT INTO users (code, full_name, position_id)
SELECT 4, 'Попов Павел Павлович', 3
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE code = 4
);

-- packs
INSERT INTO packs (code, user_id, position_id, equipment_type_id)
SELECT 1, 1, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM packs WHERE code = 1);

INSERT INTO packs (code, user_id, position_id, equipment_type_id)
SELECT 2, 2, 2, 2
WHERE NOT EXISTS (SELECT 1 FROM packs WHERE code = 2);

-- parameters: пачка 1 (ДМК)
INSERT INTO parameters (code, pack_id, param_name, value)
SELECT 1, 1, 'Высота', 100
WHERE NOT EXISTS (SELECT 1 FROM parameters WHERE code = 1);

INSERT INTO parameters (code, pack_id, param_name, value)
SELECT 2, 1, 'Температура', 15
WHERE NOT EXISTS (SELECT 1 FROM parameters WHERE code = 2);

INSERT INTO parameters (code, pack_id, param_name, value)
SELECT 3, 1, 'Давление', 750
WHERE NOT EXISTS (SELECT 1 FROM parameters WHERE code = 3);

INSERT INTO parameters (code, pack_id, param_name, value)
SELECT 4, 1, 'Направление ветра', 0
WHERE NOT EXISTS (SELECT 1 FROM parameters WHERE code = 4);

INSERT INTO parameters (code, pack_id, param_name, value)
SELECT 5, 1, 'Скорость ветра', 0
WHERE NOT EXISTS (SELECT 1 FROM parameters WHERE code = 5);

-- parameters: пачка 2 (ВР)
INSERT INTO parameters (code, pack_id, param_name, value)
SELECT 6, 2, 'Высота', 100
WHERE NOT EXISTS (SELECT 1 FROM parameters WHERE code = 6);

INSERT INTO parameters (code, pack_id, param_name, value)
SELECT 7, 2, 'Температура', 15
WHERE NOT EXISTS (SELECT 1 FROM parameters WHERE code = 7);

INSERT INTO parameters (code, pack_id, param_name, value)
SELECT 8, 2, 'Давление', 750
WHERE NOT EXISTS (SELECT 1 FROM parameters WHERE code = 8);

INSERT INTO parameters (code, pack_id, param_name, value)
SELECT 9, 2, 'Направление ветра', 0
WHERE NOT EXISTS (SELECT 1 FROM parameters WHERE code = 9);

INSERT INTO parameters (code, pack_id, param_name, value)
SELECT 10, 2, 'Дальность сноса пуль', 0
WHERE NOT EXISTS (SELECT 1 FROM parameters WHERE code = 10);

SELECT
    parameters.code AS code,
    parameters.param_name,
    parameters.value,
    packs.code AS pack_code,
    packs.created_at,
    users.full_name,
    pos_user.title AS user_current_position,
    pos_pack.title AS pack_position,
    te.type AS equipment_type
FROM parameters
JOIN packs ON parameters.pack_id = packs.code
JOIN users ON packs.user_id = users.code
JOIN positions pos_user ON users.position_id = pos_user.code
JOIN positions pos_pack ON packs.position_id = pos_pack.code
JOIN types_of_equipment te ON packs.equipment_type_id = te.code;