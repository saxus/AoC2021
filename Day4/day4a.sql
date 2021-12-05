with recursive 
    series (idx, nums) as (
	select 0 idx, '{}'::int[] nums
	union all
	select s.idx + 1, array_append(s.nums, n.num)
	from series s, input4numbers n
	where s.idx + 1 = n.idx	
    ),	
    firstrow (iteration, rndnumbers, boardid, boardrow) as (
	select * from series s, input4boards b
	where b.numbers <@ s.nums
	order by idx asc
	limit 1
    ),
    boardnumbers (boardid, number) as (
	select distinct bid, n
	from input4boards, unnest(numbers) n
    ),
    nonmarkessums (sum) as ( 
	select sum(bn.number)
	from firstrow fr, boardnumbers bn
	where fr.boardid = bn.boardid 
	  and bn.number not in (select unnest(rndnumbers) from firstrow)
    ),
    lastnumber (num) as (
        select rndnumbers[array_upper(rndnumbers, 1)]
        from firstrow
    )
select num * sum as answer from lastnumber, nonmarkessums