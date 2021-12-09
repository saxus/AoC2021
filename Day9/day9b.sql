drop table if exists input9adj;

-- some speed optimization
with adjacents as (
  select *,
    coalesce((select h from input9 up where cell.x = up.x - 1 and cell.y = up.y), 9) u,
    coalesce((select h from input9 down where cell.x = down.x + 1 and cell.y = down.y), 6) d,
    coalesce((select h from input9 lft where cell.x = lft.x and cell.y = lft.y - 1), 6) l,
    coalesce((select h from input9 rgt where cell.x = rgt.x and cell.y = rgt.y + 1), 9) r
  from input9 cell
)
select * into input9adj from adjacents;
alter table input9adj add primary key (x,y);

-- answering the question
with recursive 
  lowpoints as (
    select row_number() over () rn, x, y, h
    from input9adj
    where h < least(u, d, l, r)
  ),
  basins as (
    select * from lowpoints
    union
    select rn, a.x, a.y, a.h 
    from basins b, input9adj a
      where a.h <> 9
        and a.h > b.h
        and ((a.x = b.x and (a.y = b.y+1 or a.y = b.y-1))
         or ((a.x = b.x + 1 or a.x = b.x - 1) and a.y = b.y))         
  ),
  basin_sizes as (
    select rn, count(*) from basins
    group by rn
    order by count(*) desc
    limit 3
  ),
  basin_arr as (
    select array_agg(count) a from basin_sizes
  )
  select a[1] * a[2] * a[3] answer
  from basin_arr
  
  