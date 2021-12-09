do $$
declare 
  input text;
  r record;
begin
	drop table if exists input9;

	create table if not exists input9 (
               x integer,
               y integer,
               h integer
	);

	create index input9_xy_idx on input9 (x,y);

	input := '2199943210
3987894921
9856789892
8767896789
9899965678';

	input := replace(input, E'\r', '');

	insert into input9 (x, y, h)
	select row_number() over (partition by y) x, y, t::int
        from (
          select row_number() over() y, regexp_split_to_table(t, '') t
          from unnest(string_to_array(input, E'\n')) r(t)
        ) a;
	
end $$;

select * from input9;

