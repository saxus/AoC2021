do $$
declare 
  input text;
begin
  input := '199
200
208
210
200
207
240
269
260
263';
  
        -- input processing
		DROP TABLE IF EXISTS input1;
        CREATE TABLE input1 (idx serial, num integer);

        INSERT INTO input1 (num)
        SELECT trim(unnest(string_to_array(input, E'\n')))::integer;

end$$