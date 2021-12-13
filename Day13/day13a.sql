select count(*) as answer
from (
  select distinct
    case when fold = 'x' 
         then case when x < num then x 
                   when x > num then 2*num - x 
                   else null end
         else x 
         end x,
    case when fold = 'y' 
         then case when y < num then y 
                   when y > num then 2*num - y 
                   else null
                   end
         else y 
         end y,
    fold, 
    num                
  from  input13dots i
    left join input13folds f on f.id = 1
) tmp
