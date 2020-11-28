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

entity precise_long_counter is
  generic (
    fref_hz : real    := 100.0000e6;
    period  : real    :=  10.0000;
    sr_size : integer :=  32
  );
  port (
    rst_i       : in  std_logic;
    mclk_i      : in  std_logic;
    enable_i    : in  std_logic;
    clkout_o    : out std_logic
  );
end precise_long_counter;

architecture behavioral of precise_long_counter is

  constant div_mod_size : integer  := 8;

  constant half_period   : real    := period / 2.0000;
  constant frac_period   : real    := half_period / real(div_mod_size);
  constant sr_num        : integer := cell_num_calc(frac_period,fref_hz,sr_size);
  constant actual_period : real    := time_check(sr_size,sr_num,fref_hz);
  constant err_period    : real    := (frac_period - actual_period)*real(div_mod_size);
  constant cnt_limit     : integer := integer(err_period*fref_hz);

  signal sr_en      : std_logic_vector(sr_num-1 downto 0) := (others=>'0');
  signal out_en     : std_logic_vector(sr_num-1 downto 0) := (others=>'0');
  signal start_en   : std_logic;
  signal counter_en : std_logic;
  signal counter_s  : integer := 0;

  signal enable_s   : std_logic;

begin

  assert timer_valid_check(period,fref_hz)
    report "Timer Constraints invalid."
    severity failure;

  cell_gen : for j in 0 to sr_num-1 generate
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

  sr_en(0) <= not counter_en;

  en_gen : for j in 1 to sr_num-1 generate
    sr_en(j) <= out_en(j-1);
  end generate;

  x1_u : long_counter_cell
    generic map(
      sr_size => div_mod_size
    )
    port map (
      rst_i    => rst_i,
      mclk_i   => mclk_i,
      enable_i => out_en(sr_num-1),
      enable_o => start_en
    );

    counter_p : process(all)
    begin
      if rst_i = '1' then
        counter_s  <= 0;
        counter_en <= '0';
        enable_s   <= '0';
      elsif rising_edge(mclk_i) then
        if start_en = '1' then
          counter_s  <= 0;
          counter_en <= '1';
          enable_s   <= '0';
        elsif counter_s = cnt_limit-1 then
          counter_en <= '0';
          counter_s  <= 0;
          enable_s   <= '1';
        elsif counter_en = '1' then
          counter_s  <= counter_s  + 1;
          enable_s   <= '0';
        else
          enable_s   <= '0';
        end if;
      end if;
    end process;

    process(all)
    begin
      if rst_i = '1' then
        clkout_o <= '0';
      elsif rising_edge(mclk_i) then
        if enable_s = '1' then
          if clkout_o = '0' then
            clkout_o <= '1';
          else
            clkout_o <= '0';
          end if;
        end if;
      end if;
    end process;

end behavioral;
