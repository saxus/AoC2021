with recursive
  days (dy, count) as (
	select t, count(*)
	from (select unnest(timers) t from input6) a
	group by t
  ),
  initials as (
    select 0 as dy,
    coalesce((select count from days where dy = 0), 0) as d0,
    coalesce((select count from days where dy = 1), 0) as d1,
    coalesce((select count from days where dy = 2), 0) as d2,
    coalesce((select count from days where dy = 3), 0) as d3,
    coalesce((select count from days where dy = 4), 0) as d4,
    coalesce((select count from days where dy = 5), 0) as d5,
    coalesce((select count from days where dy = 6), 0) as d6,
    coalesce((select count from days where dy = 7), 0) as d7,
    coalesce((select count from days where dy = 8), 0) as d8
  ),
  nxt as (
    select * 
    from initials
    union
    select dy + 1,
      d1 as d0, 
      d2 as d1, 
      d3 as d2, 
      d4 as d3,  
      d5 as d4,
      d6 as d5,
      d7 + d0 as d6,
      d8 as d7,
      d0 as d8
    from nxt
  ),
  iterations as (
	select *, d0+d1+d2+d3+d4+d5+d6+d7+d8 as sum from nxt
	limit 257
  )
select sum from iterations where dy = 256