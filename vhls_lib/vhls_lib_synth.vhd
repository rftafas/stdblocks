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
library expert;
	use expert.std_string.all;
library stdblocks;
   use stdblocks.vhls_lib.all;

entity vhls_lib_synth is
  port (
    rst_i      : in  std_logic;
    clk_i      : in  std_logic;
    counter1_o : out integer;
    counter2_o : out integer;
    sequence_o : out integer
  );
end vhls_lib_synth;

architecture behavioral of vhls_lib_synth is

   type counter_t is record
     value  : integer;
   end record counter_t;

   type ffd_t is record
     d  : integer;
     q  : integer;
   end record ffd_t;

   type shiftregister_t is array (NATURAL RANGE <> ) of ffd_t;

  --we have to declare a signal on the format of the handler.
  signal counter_s : counter_t := (
    value => 0
  );
  signal sequence_s : counter_t := (
    value => 0
  );

  signal shiftregister_s : shiftregister_t(5 downto 0);

  --First, we write as many procedures we want.
  --We will have the status because we can do it several ways.
  procedure add_one ( signal add_io : inout counter_t; status : out procedure_status_t) is
  begin
    add_io.value <= add_io.value + 1;
    status := DONE; --single cycle action.
  end add_one;

  procedure add_two ( signal add_io : inout counter_t; status : out procedure_status_t) is
  begin
    add_io.value <= add_io.value + 2;
    status := DONE; --single cycle action.
  end add_two;

  procedure sub_one ( signal add_io : inout counter_t; status : out procedure_status_t) is
  begin
    add_io.value <= add_io.value - 1;
    status := DONE; --single cycle action.
  end sub_one;

  procedure flipflop_v ( dq_io : inout ffd_t; status : out procedure_status_t) is
  begin
    dq_io.q := dq_io.d;
    status  := DONE; --single cycle action.
  end flipflop_v;

  procedure add_one_v ( add_io : inout counter_t; status : out procedure_status_t) is
  begin
    add_io.value := add_io.value + 1;
    status := DONE; --single cycle action.
  end add_one_v;


 --declare the runners. We must create one runner for each procedure.
 procedure run1 is new stdblocks.vhls_lib.run
   generic map (
     process_name => "PROC1",
     my_procedure_handler_t => counter_t,
     my_procedure => add_one
   );

 procedure run2 is new stdblocks.vhls_lib.run
   generic map (
     process_name => "PROC2",
     my_procedure_handler_t => counter_t,
     my_procedure => add_one
   );

 procedure run3 is new stdblocks.vhls_lib.run
   generic map (
     process_name => "PROC3",
     my_procedure_handler_t => counter_t,
     my_procedure => add_one
   );

 procedure run4 is new stdblocks.vhls_lib.run
   generic map (
     process_name => "PROC4",
     my_procedure_handler_t => counter_t,
     my_procedure => add_two
   );

 procedure run5 is new stdblocks.vhls_lib.run
   generic map (
     process_name => "PROC5",
     my_procedure_handler_t => counter_t,
     my_procedure => sub_one
   );

 procedure run6 is new stdblocks.vhls_lib.runv
   generic map (
     process_name => "PROC6",
     my_procedure_handler_t => ffd_t,
     my_procedure => flipflop_v
   );

 procedure run7 is new stdblocks.vhls_lib.runv
   generic map (
     process_name => "PROCV1",
     my_procedure_handler_t => counter_t,
     my_procedure => add_one_v
   );

begin

  --this process is an example of a counter.
  --at each clock cycle just one of these functions is active.
  --It shows how to do things sequentially.
  counter_p : process(all)
    variable runner_v : handler_t := runner_start;
  begin
    if rst_i = '1' then
      counter_s.value <= 0;
    elsif rising_edge(clk_i) then
      scheduler_procedure(runner_v);
      run1(runner_v,counter_s);
      run2(runner_v,counter_s);
      run3(runner_v,counter_s);
    end if;
  end process;

  counter1_o <= counter_s.value;

  --this process is an example of a sequence generator.
  --It basically has the same function as process above,
  --it shows that same runner may be used more than once.
  sequence_p : process(all)
    variable runner_v : handler_t := runner_start;
  begin
    if rst_i = '1' then
      sequence_s.value <= 0;
    elsif rising_edge(clk_i) then
      scheduler_procedure(runner_v);
      run1(runner_v,sequence_s);
      run4(runner_v,sequence_s);
      run5(runner_v,sequence_s);
    end if;
  end process;
  sequence_o <= sequence_s.value;

  -- this is an example of a procedure that has a variable as
  -- handler. It is useful to be used with memory elements.
  -- Also, to avoid aditional cycles between them, both are runv.
  shift_p : process(all)
    variable runner_v  : handler_t := runner_start;
    variable counter_v : counter_t := (
      value => 0
    );
    variable ffd_v : ffd_t := (
      d => 0,
      q => 0
    );
  begin
    if rst_i = '1' then
    elsif rising_edge(clk_i) then
      --scheduler_procedure(runner_v);
      run6(runner_v,ffd_v);
      counter_v.value := ffd_v.q;
      --scheduler_procedure(runner_v);
      run7(runner_v,counter_v);
      ffd_v.d    := counter_v.value;
      counter2_o <= counter_v.value;
    end if;
  end process;

end behavioral;
