do $$
declare 
  input text;
  r record;
begin
	drop table if exists input10;

	create table if not exists input10 (
               line integer,
               col integer,
               chr char,
               typ char,
               primary key (line, col)
	);

	input := '[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]';

	input := replace(input, E'\r', '');

	insert into input10 (line, col, chr, typ)
	select line, row_number() over (partition by line), t,
          case when t in ('<', '(', '[', '{') then 'o'
             when t in ('>', ')', ']', '}') then 'c'
             else 'X' end as dir
        from (
          select row_number() over() line, regexp_split_to_table(t, '') t
          from unnest(string_to_array(input, E'\n')) u(t)
        ) tt;
	
end $$;

select * from input10;