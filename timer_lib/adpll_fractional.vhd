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
-- ADPLL will filter any input clock and get it back to 50% duty cycle with error
-- To note:
-- * this PLL has a variable loop frequency : Lfreq = 2 * (Fout / Multiplier - Fin / Divider )
--   meaning the closest to lock, the slower it gets.
-- * Total jitter is equal to Fmclk and has an amplitude of 1/Fmclk + Fmclk Jitter
-- * Fout = Multiplier * Fin / Divider
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library expert;
  use expert.std_logic_expert.all;
library stdblocks;
  use stdblocks.sync_lib.all;
  use stdblocks.timer_lib.all;

entity adpll_fractional is
  generic (
    Fref_hz       : real := 100.0000e+6;
    Fout_hz       : real :=  10.0000e+6;
    Bandwidth_hz  : real := 500.0000e+3;
    Resolution_hz : real :=  20.0000
  );
  port (
    rst_i        : in  std_logic;
    mclk_i       : in  std_logic;
    multiplier_i : in  integer;
    divider_i    : in  integer;
    clkin_i      : in  std_logic;
    clkout_o     : out std_logic
  );
end adpll_fractional;

architecture behavioral of adpll_fractional is

  constant nco_size_c : integer := nco_size_calc(Fref_hz,Resolution_hz);
  constant start_c    : integer := increment_value_calc(Fref_hz,Fout_hz,nco_size_c);
  constant upper_c    : integer := increment_value_calc(Fref_hz,Fout_hz+Bandwidth_hz,nco_size_c);
  constant lower_c    : integer := increment_value_calc(Fref_hz,Fout_hz-Bandwidth_hz,nco_size_c);

  signal clkout_s   : std_logic;
  signal clkout_en  : std_logic;
  signal clkin_en   : std_logic;
  signal div_clk_s  : std_logic;
  signal mult_clk_s : std_logic;
  signal up_s       : std_logic;
  signal down_s     : std_logic;

  signal n_value_s : std_logic_vector(nco_size_c-1 downto 0) := to_std_logic_vector(start_c,nco_size_c);

begin

  clkin_div_u   : det_updown port map (rst_i,mclk_i, clkin_i, clkin_en);
  clkout_mult_u : det_updown port map (rst_i,mclk_i,clkout_s,clkout_en);

  mult_div_p : process(all)
    variable div_cnt  : integer := 0;
    variable mult_cnt : integer := 0;
  begin
    if rst_i = '1' then
      mult_cnt   := 0;
      div_cnt    := 0;
      div_clk_s  <= '0';
      mult_clk_s <= '0';
    elsif mclk_i = '1' and mclk_i'event then
      --divider
      if clkin_en = '1' then
        div_cnt := div_cnt + 1;
        if div_cnt = divider_i then
          div_clk_s <= '1';
        elsif div_cnt = 2*divider_i then
          div_clk_s <= '0';
          div_cnt := 0;
        end if;
      end if;
      --multiplier
      if clkout_en = '1' then
        mult_cnt := mult_cnt + 1;
        if mult_cnt = multiplier_i then
          mult_clk_s <= '1';
        elsif mult_cnt = 2*multiplier_i then
          mult_clk_s <= '0';
          mult_cnt := 0;
        end if;
      end if;

    end if;
  end process;

  up_u : det_updown port map (rst_i,mclk_i,div_clk_s,   up_s);
  dn_u : det_updown port map (rst_i,mclk_i,mult_clk_s,down_s);

  control_p : process(all)
  begin
    if rst_i = '1' then
      n_value_s <= to_std_logic_vector(start_c,nco_size_c);
    elsif mclk_i = '1' and mclk_i'event then
      if up_s then
        if n_value_s /= upper_c then
          n_value_s <= n_value_s + 1;
        end if;
      elsif down_s then
        if n_value_s /= lower_c then
          n_value_s <= n_value_s - 1;
        end if;
      end if;
    end if;
  end process;

  nco_u : nco_int
      generic map (
        NCO_size_c      => nco_size_c
      )
      port map (
        rst_i     => rst_i,
        mclk_i    => mclk_i,
        scaler_i  => '1',
        sync_i    => '0',
        n_value_i => n_value_s,
        clkout_o  => clkout_s
      );

  clkout_o <= clkout_s;

end behavioral;
