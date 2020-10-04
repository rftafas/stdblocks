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

entity debounce is
    port (
      rst_i  : in  std_logic;
      mclk_i  : in  std_logic;
      din     : in  std_logic;
      dout    : out std_logic
    );
end debounce;

architecture behavioral of debounce is

begin

    process(mclk_i, rst_i)
      variable reg_v : unsigned(4 downto 0);
    begin
      if rst_i = '1' then
        dout  <= '0';
        reg_v := (others=>'0');
      elsif rising_edge(mclk_i) then
        if din = '0' then
          if reg_v > 0 then
            reg_v := reg_v - 1;
          else
            dout <= '0';
          end if;
        else
          if reg_v < (reg_v'range => '1') then
            reg_v := reg_v + 1;
          else
            dout <= '1';
          end if;
        end if;
      end if;
     end process;

end behavioral;
