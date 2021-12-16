drop table if exists input15graph;

select row_number() over () id, i.xy as source, nb as target, iii.h as cost 
into input15graph
from 
(
  select input15.xy, unnest(array[xy - 1, xy + 1, xy-1000, xy+1000]) nb 
  from input15
) i
left join input15 iii on (iii.xy = nb)
where exists(select * from input15 ii where ii.xy = i.nb);


SELECT max(cost) as answer
FROM pggraph.dijkstra('SELECT id, source, target, cost FROM public.input15graph', 
  (select min(source) from input15graph),
  (select max(source) from input15graph));