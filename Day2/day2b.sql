with recursive state (next, rn, op, num, position, depth, aim) as (
  select 1, 0, 'init'::varchar, 0::bigint, 0::bigint, 0::bigint, 0::bigint
  union all  
  select state.next + 1, input2.idx, input2.op, input2.num, 
        case when input2.op = 'forward' then state.position + input2.num
             else state.position 
             end as position,
        case when input2.op = 'forward' then state.depth + input2.num * state.aim
             else state.depth 
             end as depth,
        case when input2.op = 'down' then state.aim + input2.num 
             when input2.op = 'up' then state.aim - input2.num 
             else state.aim 
             end as aim
    from input2, state
    where state.next = input2.idx
)
-- select * from state
select position * depth as answer from state
order by rn desc limit 1;


