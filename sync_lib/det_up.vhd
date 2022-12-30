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
library stdblocks;
    use stdblocks.sync_lib.all;

entity det_up is
    port (
      rst_i   : in  std_logic;
      mclk_i  : in  std_logic;
      din     : in  std_logic;
      dout    : out std_logic
    );
end det_up;

architecture behavioral of det_up is

  signal reg_s : std_logic;

begin

    process(mclk_i, rst_i)
    begin
      if rst_i = '1' then
        reg_s <= '0';
      elsif rising_edge(mclk_i) then
        reg_s <= din;
      end if;
    end process;

    dout <= not reg_s and din;

end behavioral;
