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
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library stdblocks;
    use stdblocks.vhls_lib.all;

entity vhls_lib_tb is
end vhls_lib_tb;

architecture behavioral of vhls_lib_tb is

  type arit_t is record
    input_1 : integer;
    input_2 : integer;
    result  : integer;
  end record arit_t;

  procedure add_one ( signal add_io : inout arit_t) is
  begin
    add_io.result <= add_io.input_1 + 1;
  end add_one;

  procedure run1 is new run
    generic map (
      process_name => "AAAA",
      my_procedure_handler_t => arit_t,
      my_procedure => add_one
    );

  signal artit_s : arit_t := (
    input_1 => 0,
    input_2 => 0,
    result  => 0
  );

begin

  process
    variable runner_v : runner_t := (
      program_counter => 0,
      current_process => "AAAA"
    );
  begin
    run1(runner_v,artit_s);
    wait for 10 ns;
  end process;

end behavioral;
