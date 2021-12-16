drop table if exists input15graph;


with input15b (xy, h) as (
        with 
          size as (
            select max(xy%1000)::integer nx from input15
          )
        select xy + dy * 1000 * s as xy, 
               case when h + dy > 9 then (h+dy) % 10 + 1 else h + dy end as h
        from
        (
                select xy + dx * s as xy, 
                       case when h + dx > 9 then (h+dx) % 10 + 1  else h + dx end as h
                from input15, generate_series(0, 4) dx, size s(s)
        ) tmpx, generate_series(0, 4) dy, size s(s)
        where (xy + dy * 1000 * s) / 1000 between ((xy + dy * 1000 * s) % 1000) - (s*1.4)::int and ((xy + dy * 1000 * s) % 1000) + (s*1.4)::int
)
select row_number() over () id, i.xy as source, nb as target, iii.h as cost 
into input15graph
from 
(
  select input15b.xy, unnest(array[/*xy - 1, */xy + 1, /*xy-1000, */xy+1000]) nb 
  from input15b
) i
left join input15b iii on (iii.xy = nb)
where exists(select * from input15b ii where ii.xy = i.nb);

SELECT max(cost) as answer
FROM pggraph.dijkstra('SELECT id, source, target, cost FROM public.input15graph', 
  (select min(source) from input15graph),
  (select max(source) from input15graph));

