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

entity fixed_priority is
    generic (
      n_elements : integer := 8
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
end fixed_priority;

architecture behavioral of fixed_priority is

begin

  fix_p : process(all)
      variable index : integer := 0;
      variable grant_v : std_logic_vector(grant_o'range);
  begin
    if rst_i = '1' then
      index   := 0;
      index_o <= 0;
      grant_o <= (others=>'0');
    elsif rising_edge(clk_i) then
      if grant_o(index) = '1' then
        if ack_i(index) = '1' then
          grant_o <= (others=>'0');
        end if;
      else
        index          := index_of_1(request_i);
        grant_v        := (others=>'0');
        grant_v(index) := '1';
        grant_o <= grant_v;
        index_o <= index;
      end if;
    end if;
  end process;

end behavioral;
