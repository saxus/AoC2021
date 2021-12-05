with
    droutes (x1, y1, x2, y2, dist, dx, dy) as (
	select origin[0]::integer, origin[1]::integer,
	       target[0]::integer, target[1]::integer,
	       greatest(
	           abs(target[0]::integer - origin[0]::integer),
	           abs(target[1]::integer - origin[1]::integer)
	       ),
	       sign(target[0] - origin[0]),
	       sign(target[1] - origin[1])
        from input5 
        where direction in ('horiz', 'vert')
    ),
    allpoints (x, y) as (
	select x1 + dx * t AS x, y1 + dy * t AS y 
        from droutes, unnest((select array_agg(t) from generate_series(0, dist) t)) ts(t)
    ),
    overlps (x, y, count) as (    
	select x, y, count(*)
	from allpoints
	group by x, y
    )
select count(*)
from overlps 
where count > 1

    

