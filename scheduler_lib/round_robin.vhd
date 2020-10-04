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

entity round_robin is
    generic (
      n_elements : integer := 8;
      mode       : integer := 0
    );
    port (
      --general
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      --python script port creation starts
      request_i    : in  std_logic_vector(n_elements-1 downto 0);
      ack_i        : in  std_logic_vector(n_elements-1 downto 0);
      grant_o      : out std_logic_vector(n_elements-1 downto 0);
      index_o      : out natural
    );
end round_robin;

architecture behavioral of round_robin is

  function integer_count ( input : integer; limit : integer; up_cnt : boolean) return integer is
    variable tmp : integer;
  begin
    if up_cnt then
      if input = limit then
        tmp := 0;
      else
        tmp := input+1;
      end if;
    else
      if input = 0 then
        tmp := limit-1;
      else
        tmp := input-1;
      end if;
    end if;
    return tmp;
  end integer_count;

  signal index_sr         : integer_vector(n_elements-1 downto 0) := (others=>0);
  signal moving_index_s   : natural := 0;
  signal priority_index_s : natural := 0;

begin

  rr_p : process(all)
    variable grant_v : std_logic_vector(grant_o'range);
  begin
    if rst_i = '1' then
      grant_o        <= (others=>'0');
      moving_index_s <= 0;
    elsif rising_edge(clk_i) then
      if grant_o(moving_index_s) = '1' then --we test VHDL2008 hability to read out ports.
        if ack_i(moving_index_s) = '1' then
            moving_index_s <= integer_count(moving_index_s,n_elements-1,true);
            grant_o        <= (others=>'0');
        end if;
      elsif request_i(moving_index_s) = '1' then
        grant_v                 := (others=>'0');
        grant_v(moving_index_s) := '1';
        grant_o <= grant_v;
      else
        moving_index_s <= integer_count(moving_index_s,n_elements-1,true);
      end if;
    end if;
  end process;
  index_o <= moving_index_s;

end behavioral;
