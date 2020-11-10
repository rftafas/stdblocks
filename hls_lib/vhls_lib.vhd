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

package vhls_lib is

  type runner_t is record
    program_counter : natural;
    current_process : string(1 to 4);
  end record runner_t;

  procedure run
    generic (
      process_name : string(1 to 4);
      type          my_procedure_handler_t;
      procedure     my_procedure(signal my_procedure_data : inout my_procedure_handler_t)
    )
    parameter (
      runner : inout runner_t;
      signal my_procedure_data : inout my_procedure_handler_t
    );

end package;

package body vhls_lib is

  procedure run
    generic (
      process_name : string(1 to 4);
      type          my_procedure_handler_t;
      procedure     my_procedure(signal my_procedure_data : inout my_procedure_handler_t)
    )
    parameter (
      runner       : inout runner_t;
      signal my_procedure_data : inout my_procedure_handler_t
    ) is
  begin
    if runner.current_process = process_name then
      my_procedure(my_procedure_data);
    end if;
  end procedure;



end package body;
