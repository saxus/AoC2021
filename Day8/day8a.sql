select count(*) as answer
from (select length(unnest(string_to_Array(numbers, ' '))) w from input8) t
where w in (2, 4, 3, 7)