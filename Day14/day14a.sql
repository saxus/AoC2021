with recursive
   pairs as (
      select 0 iteration,
         substring(template from i for 1)::char lft,
         substring(template from i + 1 for 1)::char rgt,
         1::bigint cnt
      from
        generate_series(1, (select length(template) from input14template) - 1) g(i),
        input14template        
  ),
  iter (iteration, lft, rgt, cnt) as (
    select * from pairs
    union all
    (
      select 
        iteration,
        lft,
        rgt,
        sum(cnt)::bigint as cnt
      from (
          with pp as (
            select * from iter left join input14insertions using (lft, rgt)
          )
          select 
            iteration + 1 as iteration,
            lft as lft,  
            ins as rgt,
            cnt as cnt
          from pp        
          union all
          select 
            iteration + 1 as iteration,
            ins as lft,  
            rgt as rgt,
            cnt as cnt
          from pp
      ) newpairs
      where iteration < 11
      group by iteration, lft, rgt      
    )
  ),
  lastiter as (
    select * from (
      select *, max(iteration) over () mx from iter 
    ) tmp
    where iteration = mx
  ),
  lastchar as (
    select substring(template from length(template) for 1)::char, 1 from input14template
  ),
  summarized as (
    select lft, sum(cnt)
    from (
      select lft, cnt
      from lastiter
      union all
      select * from lastchar
    ) tmp
    group by lft
  )
  select max(sum) - min(sum) as answer
  from summarized