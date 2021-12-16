with recursive
  binstring as (
        select string_agg(binstr, '') str
        from 
        (
          select *
          from (select row_number() over () rn, chr
            from (
              select regexp_split_to_table(transmission, '') chr
              from input16
            ) t
          ) tmp(rn, chr)
          left join input16hex using(chr)
          order by rn
        ) hex
  ),
  packets (pid, versionid, typeid, rec, str, literalval, operatorcnt, operatorlg) as (
    select 0, 
           null::int,
           null::text, 
           'init' rec,
           str,
           null::text,
           null::int,
           null::int
    from binstring
    union all

    select
      pid,
      versionid::bit(3)::integer,
      typeid,

      case when typeid = '100' /* literal*/
           then 'literal'
           
           when typeid <> '100' /* operator */
           then case 
                  when substring(tmp.str from 7 for 1) = '0'
                  then 'op (length)'
                  else 'op (count)'
                  end
           end,
      
      case when typeid = '100' /* literal*/
           --then substring(tmp.str from 6 + (ceil(length(literalval) *5 / 4.0)::integer * 4 + 1)::integer)
           then substring(tmp.str from 6 + (length(literalval)/4*5) + 1)
           
           when typeid <> '100' /* operator */
           then case 
                  when substring(tmp.str from 7 for 1) = '0'
                    then substring(tmp.str from 8+15)
                    else substring(tmp.str from 8+11)
                  end
           end,
      literalval,
      operatorcnt,
      operatorlg
    from (
      select 
           /* pid        */ p.pid + 1 as pid,           
           /* versionid  */ substring(p.str from 1 for 3) as versionid,
           /* typeid     */ substring(p.str from 4 for 3) as typeid,
           /* orig string*/ p.str str,

           /* LITERAL VALUE */
           case 
                -- literal value
                when substring(p.str from 4 for 3) = '100' then
                (
                with recursive 
                  inputstr as (select substring(p.str from 7) str),
                  literals (literal, remaining) as (
                    select substring(str from 2 for 4),
                           case when substring(str from 1 for 1) = '1' then substring(str from 6)
                                else null
                                end                
                    from inputstr
                    union all
                    select substring(remaining from 2 for 4),
                           case when substring(remaining from 1 for 1) = '1' then substring(remaining from 6)
                                else null
                                end                
                    from literals
                    where remaining is not null    
                    )  
                  select string_agg(literal, '') as literal
                  from literals 
                )                
                else null end as literalval,

           /* OPERATOR COUNT */
           case when substring(p.str from 4 for 3) <> '100'
                 and substring(p.str from 7 for 1) = '1' 
                then substring(p.str from 8 for 11)::bit(11)::int                
                else null 
           end as operatorcnt,

           /* OPERATOR LENGTH */
           case when substring(p.str from 4 for 3) <> '100'
                 and substring(p.str from 7 for 1) = '0' 
                then substring(p.str from 8 for 15)::bit(15)::int                
                else null 
           end as operatorlg
           
      from packets p
      where replace(str, '0', '') <> ''
    ) tmp    
  )
select sum(versionid) from packets