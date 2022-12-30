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
	use IEEE.math_real.all;
library stdblocks;
    use stdblocks.timer_lib.all;

entity long_counter is
  generic (
    Fref_hz : real    := 100.0000e+6;
    Period  : real    :=  10.0000;
    sr_size : integer :=  32
  );
  port (
    rst_i       : in  std_logic;
    mclk_i      : in  std_logic;
    enable_i    : in  std_logic;
    clkout_o    : out std_logic
  );
end long_counter;

architecture behavioral of long_counter is

  constant sr_number : integer := cell_num_calc(Period/2.000,Fref_hz,sr_size);
  signal   sr_en     : std_logic_vector(sr_number-1 downto 0) := (others=>'0');
  signal   out_en    : std_logic_vector(sr_number-1 downto 0) := (others=>'0');

begin

  cell_gen : for j in 0 to sr_number-1 generate
    cell_u : long_counter_cell
      generic map(
        sr_size => sr_size
      )
      port map (
        rst_i    => rst_i,
        mclk_i   => mclk_i,
        enable_i => sr_en(j),
        enable_o => out_en(j)
      );
  end generate;

  sr_en(0) <= enable_i;

  en_gen : for j in 1 to sr_number-1 generate
    sr_en(j) <= out_en(j-1);
  end generate;

  process(all)
  begin
    if rst_i = '1' then
      clkout_o <= '0';
    elsif rising_edge(mclk_i) then
      if out_en(sr_number-1) = '1' then
        if clkout_o = '0' then
          clkout_o <= '1';
        else
          clkout_o <= '0';
        end if;
      end if;
    end if;
  end process;

end behavioral;
