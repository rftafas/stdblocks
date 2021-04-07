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

entity queueing is
    generic (
      n_elements : positive := 8
    );
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      request_i    : in  std_logic_vector(n_elements-1 downto 0);
      ack_i        : in  std_logic_vector(n_elements-1 downto 0);
      grant_o      : out std_logic_vector(n_elements-1 downto 0);
      index_o      : out natural
    );
end queueing;

architecture behavioral of queueing is

  signal index_sr         : integer_vector(n_elements-1 downto 0) := start_queue(n_elements);
  signal moving_index_s   : natural := 0;
  signal priority_index_s : natural := 0;

begin

      -- Transmitters go last.
      -- priority is given to channels that are not trasmitting. this ensures no starvation.
      -- Packet order is lost.
      process(all)
      begin
        if rst_i = '1' then
          grant_o  <= (others=>'0');
          index_sr <= start_queue(n_elements);
          moving_index_s <= n_elements-1;
        elsif rising_edge(clk_i) then
          if grant_o(index_sr(moving_index_s)) = '1' then
            if ack_i(index_sr(moving_index_s)) = '1' then
              grant_o(index_sr(moving_index_s)) <= '0';
              moving_index_s <= n_elements-1;
              for j in n_elements-1 downto 0 loop
                if j = 0 then
                  index_sr(0) <= index_sr(moving_index_s);
                elsif j <= moving_index_s then
                  index_sr(j) <= index_sr(j-1);
                end if;
              end loop;
              --We should have been using the line below, but it won't synthesize. Oh, tools...
              --index_sr(moving_index_s downto 0) <= index_sr(moving_index_s downto 0) ror 1;
            end if;
          elsif request_i(index_sr(moving_index_s)) = '1' then
            if grant_o = std_logic_vector'( grant_o'range => '0' ) then
              index_o <= index_sr(moving_index_s);
              grant_o(index_sr(moving_index_s)) <= '1';
            end if;
          elsif moving_index_s = 0 then
            moving_index_s <= n_elements-1;
          else
            moving_index_s<=moving_index_s-1;
          end if;
        end if;
      end process;


end behavioral;
