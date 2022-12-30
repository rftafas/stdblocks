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

entity nco_int is
    generic (
      NCO_size_c : natural := 16
    );
    port (
      rst_i     : in  std_logic;
      mclk_i    : in  std_logic;
      scaler_i  : in  std_logic;
      sync_i    : in  std_logic;
      n_value_i : in  std_logic_vector(NCO_size_c-1 downto 0);
      clkout_o  : out std_logic
    );
end nco_int;

architecture behavioral of nco_int is

  signal   nco_s      : unsigned(NCO_size_c-1 downto 0) := (others=>'0');

begin

  nco_p : process(mclk_i, rst_i)
    variable sync_sr : std_logic_vector(1 downto 0);
  begin
    if rst_i = '1' then
      nco_s  <= (others=>'0');
    elsif rising_edge(mclk_i) then
      if sync_i = '1' then
        nco_s <= (others=>'0');
      elsif scaler_i = '1' then
        nco_s <= nco_s + n_value_i;
      end if;
    end if;
   end process;

   clkout_o <= nco_s(nco_s'high);

end behavioral;
