do $$
declare 
  input text;
begin
  drop table if exists input3;

  input := '00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010'; 
  
        -- input processing
        DROP TABLE IF EXISTS input3;
        CREATE TABLE IF NOT EXISTS input3 (idx serial, report varchar);

        INSERT INTO input3
        SELECT row_number() over() idx, a report
        FROM (
                SELECT trim(unnest(string_to_array(replace(input, E'\r', ''), E'\n'))) a
        ) arr;

end$$;