with recursive
  inp as (
    select * from (
      select orig, dest from input12
      union all 
      select dest, orig from input12
    ) t
    where orig <> 'end' and dest <> 'start'
  ),
  iter as (
    select 
      0 round,     
      array['start'] as stack,
      'start'::text as lst,
      array[]::text[] as t
    union all
    select 
      iter.round + 1,
      array_append(stack, dest),
      inp.dest,

      (select array_agg(u) from unnest(stack) u
			where lower(u) = u and u not in ('start', 'end'))
    from inp, iter
    where inp.orig = iter.lst 
      and case when inp.dest = 'start' then false
               when inp.dest = 'end' then true
               when upper(inp.dest) = inp.dest then true
               when lower(inp.dest) = inp.dest then not exists(
			select * from unnest(stack) u
			where lower(u) = u and u not in ('start', 'end')
			group by u
			having count(*) > 1
                   ) 
                   or not exists(select * from unnest(stack) u where u = inp.dest)                   
          end

  )
select count(*), max(round) from iter
where lst = 'end'
