do $$
declare 
  input text;
  parts text[];
  r record;
begin
	drop table if exists input13dots;
	drop table if exists input13folds;

	create table if not exists input13dots (
               x int,
               y int
	);

	create table if not exists input13folds (
               id int,
               fold text,
               num int
	);

	input := '6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5';

	input := replace(input, E'\r', '');

	parts := string_to_array(input, E'\n\n');

	insert into input13dots (x, y)
	SELECT a[1]::int, a[2]::int
        FROM (
                SELECT string_to_array(trim(unnest(string_to_array(parts[1], E'\n'))), ',') a
        ) arr;

        insert into input13folds (id, fold, num)
        select row_number() over(), a[1], a[2]::int
        from (
                select string_to_array(replace(trim(unnest(string_to_array(parts[2], E'\n'))), 'fold along ', ''), '=') a
        ) arr;
	
end $$;

select * from input13dots;
select * from input13folds;

