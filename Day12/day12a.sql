with recursive
  inp as (
    select * from (
      select orig, dest from input12
      union all 
      select dest, orig from input12
    ) t
    where orig <> 'end'
  ),
  iter as (
    select 
      0 round,     
      array['start'] as stack,
      'start'::text as lst
    union all
    select 
      iter.round + 1,
      array_append(stack, dest),
      inp.dest
    from inp, iter
    where inp.orig = iter.lst 
      and case when inp.dest = 'start' then false
               when inp.dest = 'end' then true
               when upper(inp.dest) = inp.dest then true
               when lower(inp.dest) = inp.dest then not stack @> array[inp.dest] 
          end
  )
select count(*) from iter
where lst = 'end'