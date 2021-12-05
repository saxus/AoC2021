with recursive
  oxigen (ch, report, mc) as (
    select 0 as ch, report,
        CASE WHEN sum(case when substring(report from 1 for 1) = '1' THEN 1 ELSE 0 END) over ()::double precision >= count(*) over ()/2::double precision
           THEN '1'
           ELSE '0' END as mc
    from input3

    union all
    
    select ch + 1, oxigen.report, 
        CASE WHEN sum(case when substring(report from ch+2 for 1) = '1' THEN 1 ELSE 0 END) over ()::double precision >= count(*) over ()/2::double precision
             THEN '1'
             ELSE '0' END as mc
    from oxigen
    where substring(report from ch + 1 for 1) = mc 
  ),
  co2 (ch, report, mc) as (
    select 0 as ch, report,
        CASE WHEN sum(case when substring(report from 1 for 1) = '1' THEN 1 ELSE 0 END) over ()::double precision < count(*) over ()/2::double precision
           THEN '1'
           ELSE '0' END as mc
    from input3

    union all
    
    select ch + 1, co2.report, 
        CASE WHEN sum(case when substring(report from ch+2 for 1) = '1' THEN 1 ELSE 0 END) over ()::double precision < count(*) over ()/2::double precision
             THEN '1'
             ELSE '0' END as mc
    from co2
    where substring(report from ch + 1 for 1) = mc 
  ),
  bin_results (oxigen, co2) as (
    select 
        (select report from oxigen order by ch desc limit 1) oxigen,
        (select report from co2 order by ch desc limit 1) co2
  ),
  results (oxigen, co2) as (
    select (select lpad(oxigen, 31, '0')::bit(31)::int) oxigen,
           (select lpad(co2, 31, '0')::bit(31)::int) co2
    from bin_results    
  )
select oxigen * co2 as answer from results
