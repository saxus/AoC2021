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
    ),
    allboardid (bid) as (
	select array_agg(distinct bid) from input4boards
    ),
    firstallboardwinning (iteration, lastboard) as (
	select iteration, bids
	from 
        (
	    select iteration, array_agg(distinct boardid) bids
	    from firstrow
	    group by iteration
        ) wins
        where bids @> (select bid from allboardid)
        order by iteration asc
        limit 1
    ),lastboardid (bid) as (
        select distinct bid from
        input4boards where bid not in (
	    select distinct boardid from firstrow
	    where iteration < (select iteration from firstallboardwinning)
        )
    ),
    lastwinneriteration (iteration, rndnumbers, boardid, boardrow) as (
	select * from firstrow, lastboardid
	where lastboardid.bid = firstrow.boardid
	order by iteration asc
	limit 1
    ),    
    boardnumbers (boardid, number) as (
	select distinct bid, n
	from input4boards, unnest(numbers) n
    ),
    nonmarkedsums (sum) as ( 
	select sum(bn.number)
	from lastwinneriteration lw, boardnumbers bn
	where lw.boardid = bn.boardid 
	  and bn.number not in (select unnest(rndnumbers) from lastwinneriteration)
    ),
    lastnumber (num) as (
        select rndnumbers[array_upper(rndnumbers, 1)]
        from lastwinneriteration
    )
select num * sum as answer from lastnumber, nonmarkedsums

