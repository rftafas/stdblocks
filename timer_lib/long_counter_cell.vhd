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
	use IEEE.math_real.all;

entity long_counter_cell is
  generic (
    sr_size : integer   :=  32
  );
  port (
    rst_i       : in  std_logic;
    mclk_i      : in  std_logic;
    enable_i    : in  std_logic;
    enable_o    : out std_logic
  );
end long_counter_cell;

architecture behavioral of long_counter_cell is

  signal timer_sr : std_logic_vector(sr_size-1 downto 0) := (0=>'1', others=>'0');

begin

  cell_p : process(all)
  begin
    if mclk_i = '1' and mclk_i'event then
      if enable_i = '1' then
        timer_sr    <= timer_sr sll 1;
        timer_sr(0) <= timer_sr(sr_size-1);
      end if;
    end if;
  end process;

  enable_o <= timer_sr(sr_size-1) and enable_i;

end behavioral;
