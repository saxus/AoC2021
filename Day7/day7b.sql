with recursive 
  pos (p) as (
    select generate_series(min(pos), max(pos)) from input7
  ),
  fuel (pos, fuel) as (
    select 0, 0
    union all
    select f.pos + 1, f.fuel + f.pos + 1
    from fuel f
    where f.pos < (select max(pos) from input7)
  ),
  deltas (originpos, targetpos, delta) as (
    select pos, p, abs(pos - p)
    from input7, pos
  )
select sum(fuel) answer
from deltas
  left join fuel on fuel.pos = deltas.delta
group by targetpos
order by sum(fuel) asc
limit 1