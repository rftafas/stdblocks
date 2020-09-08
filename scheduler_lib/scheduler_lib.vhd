library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;
  use IEEE.math_real.all;
library expert;
  use expert.std_logic_expert.all;
library stdblocks;
    use stdblocks.ram_lib.all;
    use stdblocks.fifo_lib.all;

package scheduler_lib is

  function integer_count (
    input : integer;
    limit : integer;
    up_cnt : boolean
  ) return integer;
  
  function start_queue ( input: integer ) return integer_vector;

end package;

package body scheduler_lib is

function start_queue (input: integer) return integer_vector is
  variable tmp : integer_vector(input-1 downto 0);
begin
  for j in input-1 downto 0 loop
    tmp(j) := j;
  end loop;
  return tmp;
end start_queue;

function integer_count ( input : integer; limit : integer; up_cnt : boolean) return integer is
  variable tmp : integer;
begin
  if up_cnt then
    if input = limit then
      tmp := 0;
    else
      tmp := input+1;
    end if;
  else
    if input = 0 then
      tmp := limit-1;
    else
      tmp := input-1;
    end if;
  end if;
  return tmp;
end integer_count;

end package body;
