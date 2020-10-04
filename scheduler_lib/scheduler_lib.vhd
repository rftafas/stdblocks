----------------------------------------------------------------------------------
--Copyright 2020 Ricardo F Tafas Jr

--Licensed under the Apache License, Version 2.0 (the "License"); you may not
--use this file except in compliance with the License. You may obtain a copy of
--the License at

--   http://www.apache.org/licenses/LICENSE-2.0

--Unless required by applicable law or agreed to in writing, software distributed
--under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
--OR CONDITIONS OF ANY KIND, either express or implied. See the License for
--the specific language governing permissions and limitations under the License.
----------------------------------------------------------------------------------
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
