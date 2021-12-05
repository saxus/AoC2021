with moving_sum (idx, num) as (
        select idx, sum(num) over (order by idx rows between 2 preceding and current row )
        from input1 i
        order by idx
        offset 2
)
select sum(case when coalesce((i.num - d.num), 0) > 0 then 1 else 0 end)
from moving_sum i
  left join moving_sum d on d.idx = (i.idx-1)

