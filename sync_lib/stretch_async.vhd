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

entity stretch_async is
    port (
        clkin_i    : in  std_logic;
        clkout_i   : in  std_logic;
        din        : in  std_logic;
        dout       : out std_logic
    );
end stretch_async;

architecture behavioral of stretch_async is

  --for the future: include attributes for false path.

  signal dout_s        : std_logic := '0';
  signal reg_forward_s : std_logic := '0';
  signal reg_out_s     : std_logic_vector(2 downto 0) := (others=>'0');
  signal reg_back_s    : std_logic_vector(1 downto 0) := (others=>'0');

begin

  process(clkin_i)
  begin
    if rising_edge(clkin_i) then
      reg_back_s <= reg_back_s(0) & reg_out_s(1);
      if reg_back_s(1) = '1' then
        reg_forward_s <= '0';
      elsif din = '1' then
        reg_forward_s <= '1';
      end if;
    end if;
  end process;

  process(clkout_i)
    variable lock_v : boolean := false;
  begin
    if rising_edge(clkout_i) then
      reg_out_s  <= reg_out_s(1 downto 0) & reg_forward_s;
    end if;
  end process;

  dout <= reg_out_s(2) and not reg_out_s(1);

end behavioral;
