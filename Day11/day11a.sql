with recursive
    step_cte  as (
	select 0 step, 0 it, x, y, h, '.' flashes from input11
	union all	
	(
	  with recursive  
		  inp (step, x, y, h) as (
			select step + 1 as step, x, y, h from step_cte
	          ),		  
		  iter (step, it, x, y, h, flashes, inc) as (
			  select step, 0, x, y, 
					h,
					case when h + 1 > 9 then 'F' else '.' end flashes,
					(select count(*) +1
					from inp i2
					where i2.x between i.x - 1 and i.x + 1 
					  and i2.y between i.y - 1 and i.y + 1
					  and i2.h + 1 > 9)::int as inc
			  from inp i
			  union all
			  (
				 with rr (step, it, x, y, h, flashes, inc, newflashes) as (
				   select * ,
					 case when flashes = 'O' then 'O'
					 when flashes = 'F' then 'O'
					 when h + inc > 9 and flashes = '.' then 'F'
					 else '.' end newflashes        
				  from iter 
				)        
				select step, it + 1, x, y, 
					h + inc,
					newflashes,          
					(select count(*)
					from rr r2
					where r2.x between rr.x - 1 and rr.x + 1 
					  and r2.y between rr.y - 1 and rr.y + 1
					  and r2.newflashes = 'F')::int inc           
				from  rr
				where exists(select * from rr where inc > 0)
			 )
		  )
		  select step, it, x, y, h, flashes
		  from (
			select step, it, x, y, flashes,
			       case when h > 9 then 0 else h end h, 
			       max(it) over () last_it
			from (select * from iter) iter_cte
		  ) tmp
		  where last_it = it	
		  and step < 101
	  )
    )    
select count(*) from step_cte where flashes <> '.'

-- to visualize each steps
/*

select step, it, y, 
    string_agg((case when h > 9 then 0 else h end)::text, ''),
    string_agg(flashes::char, '') flashes
from step_cte
group by step, it, y
order by step, it, y

*/