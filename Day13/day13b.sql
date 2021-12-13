with recursive 
  iter as (
     select 0 r, x, y, '-' as fold, 0 num from input13dots
     union all
     (
       with 
         it as (
           select 
             i.r + 1 r, i.x, i.y, f.fold, f.num
           from iter i
             left join input13folds f on i.r + 1 = f.id
           where f.fold is not null
         )
       select distinct * from (
         select r,
           case when fold = 'x' and x > num 
                then 2*num - x 
                else x 
                end x,
           case when fold = 'y' and y > num 
                then 2*num - y 
                else y 
                end y,
           fold, 
           num
         from it
        ) tmp
     )
  ),
  dots (x, y) as (  
    select 
     x, y
    from
    (
      select *, max(r) over () mx from iter
    ) it
    where it.r = it.mx
  ),
  maxs (mx, my) as (
    select max(x) mx, max(y) my 
    from dots
  ),
  allcords (x, y) as (
    select x, y
    from 
     (select generate_series(0, mx) x from maxs) tx,
     (select generate_series(0, my) y from maxs) ty
  ),
  -- visualize as ascii art
  ascii (lines) as (  
    select string_agg(c, '') line
    from (
      select a.x, a.y, case when d.x is null then ' ' else '#' end c
      from allcords a
        left join dots d using(x,y)
      order by a.y, a.x
    ) tmp
    group by y
    order by y
  ),
  -- OCR approach
  combined (txt) as (
    select string_agg(line, E'\n') t
      from 
      (
        select x, string_agg(c, '') line
        from (
          select a.x, a.y, case when d.x is null then '.' else '#' end c
          from allcords a
            left join dots d using(x,y)
          order by a.y desc
        ) tmp
        group by x
        order by x
      ) tmp2
  ),
  linedelimiter (delim) as (
    select E'\n' || repeat('.', (select my from maxs) + 1) || E'\n' AS delim
  ),
  bigchars (rn, chr) as (  
    select row_number() over (), t
    from (
      select unnest(string_to_array(txt, delim)) t
      from combined, linedelimiter
    ) tmp
  ),
  rotatedchars (rn, chr) as (   
    with split as (
        select rn, x, row_number() over(partition by rn, x) y, c
        from (
          select rn, x, regexp_split_to_table(t, '') c
          from (
            select rn, row_number() over(partition by rn) x, t
            from bigchars, unnest(string_to_array(chr, E'\n')) u(t)
          ) tmp
        ) tmp2
        order by rn, x, y
    )
    select rn, string_agg(l, E'\n') as chr
    from (
      select rn, y, (select string_agg(c, '') from split s2 where s2.rn = s.rn and s2.y = s.y) l
      from (select distinct rn, y from split) s
      order by rn, y desc
    ) tmp
    group by rn
  ),
  charmap (code, chr) as (
    select *
    from ( values
        ('A', E'.##.\n#..#\n#..#\n####\n#..#\n#..#'),
        ('B', E'###.\n#..#\n###.\n#..#\n#..#\n###.'),
        ('C', E'.##.\n#..#\n#...\n#...\n#..#\n.##.'),
        ('D', E'###.\n#..#\n#..#\n#..#\n#..#\n###.'), -- unconfirmed
        ('E', E'####\n#...\n###.\n#...\n#...\n####'),
        ('F', E'####\n#...\n###.\n#...\n#...\n#...'),
        ('G', E'.##.\n#..#\n#...\n#.##\n#..#\n.###'),
        ('H', E'#..#\n#..#\n####\n#..#\n#..#\n#..#'),
        ('I', E''), -- unconfirmed
        ('J', E'..##\n...#\n...#\n...#\n#..#\n.##.'),
        ('K', E'#..#\n#.#.\n##..\n#.#.\n#.#.\n#..#'),
        ('L', E'#...\n#...\n#...\n#...\n#...\n####'),
        ('M', E''), -- unconfirmed
        ('N', E''), -- unconfirmed
        ('O', E'.##.\n#..#\n#..#\n#..#\n#..#\n.##.'), -- unconfirmed
        ('P', E'###.\n#..#\n#..#\n###.\n#...\n#...'),
        ('Q', E''), -- unconfirmed
        ('R', E'###.\n#..#\n#..#\n###.\n#.#.\n#..#'),        
        ('S', E''), -- unconfirmed
        ('T', E''), -- unconfirmed
        ('U', E'#..#\n#..#\n#..#\n#..#\n#..#\n.##.'),
        ('V', E''), -- unconfirmed
        ('W', E''), -- unconfirmed
        ('X', E''), -- unconfirmed
        ('Y', E''), -- unconfirmed
        ('Z', E'####\n...#\n..#.\n.#..\n#...\n####')
    ) as t(chr, img)
  ),
  translated (chr, rn, code) as (
    select chr, rn, coalesce(code, '?') from rotatedchars rc
      left join charmap cm using(chr)
  ),
  ocr (answer) as (
    select string_agg(code, '') answer
    from (select code from translated order by rn) tmp
  )
select * from ascii
union all
select * from ocr
union all
select 'Error: Missing character in charmap' 
from ocr where answer ilike '%?%'
  