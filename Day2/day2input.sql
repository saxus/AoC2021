do $$
declare 
  input text;
begin
  input := 'forward 5
down 5
forward 8
up 3
down 8
forward 2';
  
        -- input processing
        DROP TABLE IF EXISTS input2;
        CREATE TABLE IF NOT EXISTS input2 (idx serial, op varchar, num bigint);

        INSERT INTO input2
        SELECT row_number() over() idx, a[1] op, a[2]::integer num
        FROM (
                SELECT string_to_array(trim(unnest(string_to_array(input, E'\n'))), ' ') a
        ) arr;

end$$;