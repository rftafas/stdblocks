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

entity resource_controller is
    generic (
      n_elements  : integer := 8;
      n_resources : integer := 8;
      mode        : integer := 0
    );
    port (
      --general
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      --python script port creation starts
      request_i  : in  std_logic_vector(n_elements-1 downto 0);
      ack_i      : in  std_logic_vector(n_elements-1 downto 0);
      grant_o    : out std_logic_vector(n_elements-1 downto 0);
      resource_o : out   integer_vector(n_elements-1 downto 0);
      index_o    : out   integer
    );
end resource_controller;

architecture behavioral of resource_controller is

  signal resource_pool_s  : integer_vector(n_resources-1 downto 0) := start_queue(n_resources);
  alias  free_resource_a  : integer is resource_pool_s(n_resources-1);

  signal index_s          : natural := 0;
  signal free_index_s     : natural := 0;
  signal moving_index_s   : natural := 0;
  signal priority_index_s : natural := 0;

begin

  rr_p : process(all)
  begin
    if rst_i = '1' then
      resource_pool_s <= start_queue(n_resources);
      grant_o         <= (others=>'0');
      moving_index_s  <= 0;
      free_index_s    <= 0;
    elsif rising_edge(clk_i) then
      index_s <= integer_count(index_s,n_elements-1,true);
      if grant_o(index_s) = '1' then
        if ack_i(index_s) = '1' then
          resource_pool_s <= resource_pool_s rol 1;
          free_resource_a <= resource_o(index_s);
          free_index_s    <= free_index_s - 1;
        end if;
      elsif request_i(index_s) = '1' then
        if free_index_s < n_resources then
          resource_pool_s     <= resource_pool_s rol 1;
          resource_o(index_s) <= free_resource_a;
          free_index_s        <= free_index_s + 1;
        end if;
      end if;
    end if;
  end process;
  index_o <= index_s;

end behavioral;
