with 
  line (line, word) as (
    select row_number() over() line, unnest(string_to_array(digits, ' ')) word from input8
  ),
  numbers (line, num, chr) as (
      select line, row_number() over (partition by line), regexp_split_to_table(word, '')::char
      from line
  ),
  digit_e (line, chr) as (
     select line, chr
     from numbers
     group by line, chr
     having count(*) = 4
  ),
  digit_b (line, chr) as (
     select line, chr
     from numbers
     group by line, chr
     having count(*) = 6
  ),
  digit_f (line, chr) as (
     select line, chr
     from numbers
     group by line, chr
     having count(*) = 9
  ),
  digit_a (line, chr) as (
     select line, chr
     from numbers 
     where chr not in (select regexp_split_to_table(word, '') ch from line l where length(word) = 2 and l.line = numbers.line)
     group by line, chr
     having count(*) = 8     
  ),
  digit_c (line, chr) as (
     select line, chr
     from numbers 
     where chr in (select regexp_split_to_table(word, '') ch from line l where length(word) = 2 and l.line = numbers.line)
     group by line, chr
     having count(*) = 8     
  ),
  digit_d (line, chr) as (
     select line, chr
     from numbers 
     where chr in (select regexp_split_to_table(word, '') ch from line l where length(word) = 4 and l.line = numbers.line)
     group by line, chr
     having count(*) = 7    
  ),
  digit_g (line, chr) as (
     select line, chr
     from numbers 
     where chr not in (select regexp_split_to_table(word, '') ch from line l where length(word) = 4 and l.line = numbers.line)
     group by line, chr
     having count(*) = 7    
  ),
  digit_mapping as (
    select line, a.chr || b.chr || c.chr || d.chr || e.chr || f.chr || g.chr mapfrom
     from digit_a a 
       left join digit_b b using(line)
       left join digit_c c using(line)
       left join digit_d d using(line)
       left join digit_e e using(line)
       left join digit_f f using(line)
       left join digit_g g using(line)
   ),
   line_question (line, word) as (
    select row_number() over() line, unnest(string_to_array(numbers, ' ')) word from input8
   ),
   translated (line, wordno, word) as (
     select line, row_number() over() wordno, translate(word, mapfrom, 'abcdefg') word
     from line_question
       left join digit_mapping using(line)
   ),
   translated_and_ordered (line, wordno, word) as (
     select line, wordno, (select string_agg(ch, '') from (select ch from regexp_split_to_table(word, '') t(ch) order by ch) tt)
     from translated
     order by wordno asc
   ),
   numbermapping (word, num) as (
      select * from ( values
        ('abcefg', 0),
        ('cf', 1),
        ('acdeg', 2),
        ('acdfg', 3),
        ('bcdf', 4),
        ('abdfg', 5),
        ('abdefg', 6),
        ('acf', 7),
        ('abcdefg', 8),
        ('abcdfg', 9) ) as w (word, numeric)
   ),
   numeric_values (line, num) as (
     select line, string_agg(num::char, '')::integer
     from translated_and_ordered
       left join numbermapping using (word) 
     group by line
     order by line
   )
   select sum(num) as answer
   from numeric_values
   