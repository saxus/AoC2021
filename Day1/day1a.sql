select sum(case when coalesce((i.num - d.num), 0) > 0 then 1 else 0 end)
from input1 i
  left join input1 d on d.idx = (i.idx-1)