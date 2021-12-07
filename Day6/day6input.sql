do $$
declare 
  input text;
  r record;
begin
	drop table if exists input6;

	create table if not exists input6 (
		timers integer[]
	);

	input := 
'3,4,3,1,2';

	input := replace(input, E'\r', '');

	insert into input6 (timers)
	select string_to_array(input, ',')::integer[] s;
	
end $$;

select * from input6;


