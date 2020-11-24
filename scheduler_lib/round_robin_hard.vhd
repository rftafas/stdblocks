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
  use expert.std_logic_expert.all;
library stdblocks;
  use stdblocks.scheduler_lib.all;

entity round_robin_hard is
    generic (
      n_elements : integer := 8
    );
    port (
      clk_i     : in  std_logic;
      rst_i     : in  std_logic;
      request_i : in  std_logic_vector(n_elements-1 downto 0);
      ack_i     : in  std_logic_vector(n_elements-1 downto 0);
      grant_o   : out std_logic_vector(n_elements-1 downto 0);
      index_o   : out natural
    );
end round_robin_hard;

architecture behavioral of round_robin_hard is

  signal moving_index_s   : natural := 0;
  signal priority_index_s : natural := 0;

begin

    rr_p : process(all)
    begin
      if rst_i = '1' then
        grant_o        <= (others=>'0');
        moving_index_s <= n_elements-1;
        index_o        <= 0;
      elsif rising_edge(clk_i) then
        if grant_o(moving_index_s) = '1' then
          if ack_i(moving_index_s) = '1' then
              moving_index_s <= integer_count(moving_index_s,n_elements-1,false);
              grant_o        <= (others=>'0');
          end if;
        elsif request_i(moving_index_s) = '1' then
          grant_o                 <= (others=>'0');
          grant_o(moving_index_s) <= '1';
          index_o <= moving_index_s;
        end if;
      end if;
    end process;


end behavioral;
