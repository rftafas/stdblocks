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

  --we have to define some static stuff for procedures to save.
  --we use records ans inside them, store as many stuff as possible.
   type arit_t is record
     input_1 : integer;
     input_2 : integer;
     result  : integer;
   end record arit_t;

  --we have to declare a signal on the format of the handler.
   signal artit_runner_s : arit_t := (
     input_1 => 0,
     input_2 => 0,
     result  => 0
   );

  --First, we write as many procedures we want.
  --We will have the status because we can do it several ways.
  procedure add_one ( signal add_io : inout arit_t; status : out procedure_status_t) is
  begin
    add_io.result <= add_io.input_1 + 1;
    status := PROC_DONE; --single cycle action.
  end add_one;

  procedure add_two ( signal add_io : inout arit_t; status : out procedure_status_t) is
  begin
    add_io.result <= add_io.input_1 + 2;
    status := PROC_DONE; --single cycle action.
  end add_two;

 procedure set_to_one ( signal add_io : inout arit_t; status : out procedure_status_t) is
 begin
   add_io.result <= 1;
   status := PROC_DONE; --single cycle action.
 end set_to_one;

 --declare the runners. We must create one runner for each procedure.
 procedure run1 is new run
   generic map (
     process_name => "PROC1",
     my_procedure_handler_t => arit_t,
     my_procedure => add_one
   );

 procedure run2 is new run
   generic map (
     process_name => "PROC2",
     my_procedure_handler_t => arit_t,
     my_procedure => add_two
   );

 procedure run3 is new run
   generic map (
     process_name => "PROC3",
     my_procedure_handler_t => arit_t,
     my_procedure => set_to_one
   );

begin

  --using a runner: will run according set sequence.
  process
   variable runner_v : runner_t := runner_start;
  begin
    scheduler_procedure(runner_v);
    run1(runner_v,artit_runner_s);
    run2(runner_v,artit_runner_s);
    run3(runner_v,artit_runner_s);
    wait for 10 ns;
  end process;

end behavioral;
