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
-- This block removes metastability from any asynchronous signal.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
library stdblocks;
    use stdblocks.sync_lib.all;


entity sync_r is
    generic (
      stages  : integer := 2
    );
    port (
      rst_i   : in  std_logic;
      mclk_i  : in  std_logic;
      din     : in  std_logic;
      dout    : out std_logic
    );
end sync_r;

architecture behavioral of sync_r is

  signal reg_s : std_logic_vector(stages-1 downto 0) := (others=>'0');

begin

    process(mclk_i,rst_i)

    begin
      if rst_i = '1' then
        reg_s <= (others => '0');
      elsif rising_edge(mclk_i) then
        reg_s <= reg_s(stages-2 downto 0) & din;
      end if;
     end process;
     dout  <= reg_s(stages-1);

end behavioral;
