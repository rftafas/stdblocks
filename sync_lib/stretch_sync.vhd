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

entity stretch_sync is
    port (
      rst_i  : in  std_logic;
      mclk_i : in  std_logic;
      da_i   : in  std_logic;
      db_i   : in  std_logic;
      dout_o : out std_logic
    );
end stretch_sync;

architecture behavioral of stretch_sync is

  --for the future: include attributes for false path.

  signal dout_s        : std_logic := '0';
  signal reg_forward_s : std_logic := '0';
  signal reg_out_s     : std_logic_vector(2 downto 0) := (others=>'0');
  signal reg_back_s    : std_logic_vector(1 downto 0) := (others=>'0');

begin

  process(mclk_i)
    variable da_tmp : std_logic := '0';
    variable db_tmp : std_logic := '0';
  begin
    if rst_i = '1' then
      da_tmp := '0';
      db_tmp := '0';
      dout_o <= '0';
    elsif rising_edge(mclk_i) then
      dout_o <= '0';

      if da_i = '1' then
        da_tmp := '1';
      end if;

      if db_i = '1' then
        db_tmp := '1';
      end if;

      if da_tmp = '1' and db_tmp = '1' then
        da_tmp := '0';
        db_tmp := '0';
        dout_o <= '1';
      end if;

    end if;
  end process;

end behavioral;
