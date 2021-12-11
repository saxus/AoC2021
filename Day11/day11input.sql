do $$
declare 
  input text;
  r record;
begin
	drop table if exists input11;

	create table if not exists input11 (
               x integer,
               y integer,
               h integer
	);

	create index input11_xy_idx on input11 (x,y);

input := '5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526';

	input := replace(input, E'\r', '');

	insert into input11 (x, y, h)
	select row_number() over (partition by y) x, y, t::int
        from (
          select row_number() over() y, regexp_split_to_table(t, '') t
          from unnest(string_to_array(input, E'\n')) r(t)
        ) a;
	
end $$;

select * from input11;

