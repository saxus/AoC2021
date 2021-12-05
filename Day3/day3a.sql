with 
        -- columns
        numbers (num) as (
                select generate_series(1, (select length(report) from input3 limit 1))
        ),
        -- split to columns
        spl (row, ch, rep) as (
                select idx as row, num as ch, substring(report from num for 1) rep
                from numbers, input3  
        ),
        -- count
        commons (ch, rep, count) as (
                select ch, rep, count(*)
                from spl
                group by ch, rep
        ),
        ordered (ch, rep, count, ordr) as (
                select ch, rep, count, row_number() over (partition by ch order by count desc)
                from commons
                order by ch
        ),
        results (gamma, epsilon) as (
                select (select lpad(string_agg(rep, ''), 31, '0')::bit(31)::int from ordered where ordr = 1) as gamma,
                       (select lpad(string_agg(rep, ''), 31, '0')::bit(31)::int from ordered where ordr = 2) as epsilon
        )
select gamma*epsilon as result
from results;