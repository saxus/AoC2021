do $$
declare 
  input text;
  r record;
begin
	drop table if exists input7;

	create table if not exists input7 (
               pos integer
	);

	input := '16,1,2,0,4,2,7,1,2,14';

	input := replace(input, E'\r', '');

	insert into input7 (pos)
	select num::integer 
        from unnest(string_to_array(input, ',')) s(num);
	
end $$;

select * from input7;

