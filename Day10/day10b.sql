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
    where not exists(select * from iter v where not v.isvalid and v.line = i.line)
    order by line, col
  ),
  laststacks as (
    select line, stack
    from (
      select row_number() over (partition by line) rn, line, stack 
      from (
        select line, stack
        from iter_filtered
        order by line asc, col desc
      ) ord
    ) t 
    where rn = 1
  ),
  rawscores as (
    select line, 
         row_number() over (partition by line) idx, 
         chr,
         case when chr = '<' then 4 
              when chr = '{' then 3
              when chr = '[' then 2
              when chr = '(' then 1
              else null end as score 
    from (select line, regexp_split_to_table(stack, '') chr from laststacks) t
  ),
  scores2 as (  
    select line, max(idx) + 1 as idx, 0::bigint as score, ' ' chr
    from rawscores
    group by line
    union all 
    select r.line, r.idx, s.score * 5 + r.score, r.chr
    from scores2 s, rawscores r
      where s.line = r.line and r.idx = s.idx - 1
  ),
  orderedscores as (
    select row_number() over(), score 
    from (
        select score 
        from scores2 
        where idx = 1 
        order by score        
    ) ordr
  )
  select score as answer
  from orderedscores
  where row_number =  (select count(*)/2+1 from (select distinct line from iter_filtered) t)
  