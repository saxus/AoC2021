with adjacents as (
  select *,
    coalesce((select h from input9 up where cell.x = up.x - 1 and cell.y = up.y), 9) u,
    coalesce((select h from input9 down where cell.x = down.x + 1 and cell.y = down.y), 6) d,
    coalesce((select h from input9 lft where cell.x = lft.x and cell.y = lft.y - 1), 6) l,
    coalesce((select h from input9 rgt where cell.x = rgt.x and cell.y = rgt.y + 1), 9) r
  from input9 cell
)
select sum(h+1) as answer from adjacents
where h < least(u, d, l, r)

  