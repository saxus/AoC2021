with recursive
  iter (line, col, chr, typ, stack, lastofstack, isvalid) as (
    select line, col, chr, typ, chr::text, chr, true
      from input10
      where col = 1
    union all
    select input10.line, input10.col, input10.chr, input10.typ, 
        case when input10.typ = -1 then substring(iter.stack from 1 for length(iter.stack) - 1)
             else iter.stack || input10.chr  
             end as stack,
        case when input10.typ = -1 then substring(iter.stack from length(iter.stack) - 1)::char
             else input10.chr           
             end as lastofstack,
        case when input10.typ = -1 then translate(iter.lastofstack, '<([{', '>)]}') = input10.chr
             else true
             end as isvalid
      from input10, iter
      where input10.line = iter.line AND input10.col = iter.col + 1
  ),
  iter_filtered as (
    select * 
    from iter i
    where exists(select * from iter v where not v.isvalid and v.line = i.line)
    order by line, col
  ),
  scored as (
    select row_number() over (partition by line) rn, 
           iter_filtered.*, 
           case when chr = '>' then 25137 
              when chr = '}' then 1197
              when chr = ']' then 57
              when chr = ')' then 3
              else null end as score
    from iter_filtered 
    where not isvalid
  )
  select sum(score)
  from scored where rn = 1
  

