do $$
declare 
  input text;
  r record;
begin
	drop table if exists input5;

	create table if not exists input5 (
		origin point,
		target point,
		direction varchar
	);

	input := 
'0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2';

	input := replace(input, E'\r', '');

	insert into input5
	with raw (rec) as (
		select string_to_array(a, ' -> ') rec from unnest(string_to_array(input, E'\n')) a
	),
	points (origin, target) as (
		select rec[1]::point, rec[2]::point from raw
	)
	select
		origin, target, 
		case when origin[0] = target[0] then 'horiz'
		     when origin[1] = target[1] then 'vert'
                     else 'diag' end direction
        from points;
end $$;

select * from input5;