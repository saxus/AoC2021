do $$
declare 
  input text;
  input_numbers text;
  input_boards text;
  c int;
  r record;
begin
  drop table if exists input4numbers;
  drop table if exists input4boards;

  input := '7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7';

	input := replace(input, E'\r', '');

	select unnest(string_to_array(input, E'\n\n')) into input_numbers limit 1;

	select string_agg(line, E'\n\n') into input_boards
	from (select unnest(string_to_array(input, E'\n\n')) line offset 1) lines;

       -- input processing
        CREATE TABLE IF NOT EXISTS input4numbers (idx serial, num integer);
        CREATE TABLE IF NOT EXISTS input4boards (bid integer, numbers integer[]);

	-- numbers
        INSERT INTO input4numbers (num)
        SELECT a::integer from unnest(string_to_array(input_numbers, ',')) a;

        c := 1;

	-- boards (rows and columns into separated records)
        for r in select unnest(string_to_array(replace(input_boards, E'\r', ''), E'\n\n')) board
        loop
		insert into input4boards (bid, numbers)
		-- create rows and columns
                with board (arr) as (
			select string_to_array(regexp_replace(trim(unnest(string_to_array(replace(r.board, E'\r', ''), E'\n'))), '(( ){2,}|\t+)', ' ', 'g'), ' ')::int[]
		 )
		select c, * from board
		union
		select c, (select array_agg(arr[g]) from board) a
		from generate_series(1,5) g;

		c := c + 1;
        end loop;
end$$;

select * from input4numbers;
select * from input4boards;

