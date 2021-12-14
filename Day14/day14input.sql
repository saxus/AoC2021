do $$
declare 
  input text;
  parts text[];
  r record;
begin
	drop table if exists input14template;
	drop table if exists input14insertions;

	create table if not exists input14template (
               template text
	);

	create table if not exists input14insertions (
               whr text,
               ins char
	);

	input := 'NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C';

	input := replace(input, E'\r', '');

	parts := string_to_array(input, E'\n\n');

        insert into input14template 
        select parts[1];

        insert into input14insertions
        select t[1], t[2]::char from (
          select string_to_array(t, ' -> ') t from regexp_split_to_table(parts[2], E'\n') s(t)
        ) tmp;
end $$;

select * from input14template;
select * from input14insertions;


