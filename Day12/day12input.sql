do $$
declare 
  input text;
  r record;
begin
	drop table if exists input12;

	create table if not exists input12 (
               orig text,
               dest text
	);

	input := 'start-A
start-b
A-c
A-b
b-d
A-end
b-end';

	input := replace(input, E'\r', '');

	insert into input12 (orig, dest)
	SELECT a[1], a[2]
        FROM (
                SELECT string_to_array(trim(unnest(string_to_array(input, E'\n'))), '-') a
        ) arr;

	
end $$;

select * from input12;

