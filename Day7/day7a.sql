with pos (p) as (
 select generate_series(min(pos), max(pos)) from input7
)
select sum(abs(pos - p)) answer from input7, pos
group by p
order by sum(abs(pos - p)) asc
limit 1
