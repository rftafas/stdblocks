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
library expert;
  use expert.std_logic_expert.all;
	use expert.std_string.all;
library stdblocks;
  use stdblocks.timer_lib.all;

entity nco is
    generic (
      Fref_hz         : real    := 100.0000e+6;
      Fout_hz         : real    :=  10.0000e+6;
      Resolution_hz   : real    :=  20.0000;
      use_scaler      : boolean :=   false;
      adjustable_freq : boolean :=   false;
      NCO_size_c      : natural :=   16
    );
    port (
      rst_i     : in  std_logic;
      mclk_i    : in  std_logic;
      scaler_i  : in  std_logic;
      n_value_i : in  std_logic_vector(NCO_size_c-1 downto 0);
      clkout_o  : out std_logic
    );
end nco;

architecture behavioral of nco is

  signal   scaler_s        : std_logic;
  constant internal_size_c : integer := nco_size_calc(Fref_hz,Resolution_hz,adjustable_freq,NCO_size_c);
  constant n_value_c       : unsigned(internal_size_c-1 downto 0) := to_unsigned(increment_value_calc(Fref_hz,Fout_hz,NCO_size_c),internal_size_c);
  signal   n_value_s       : unsigned(internal_size_c-1 downto 0) := (others=>'0');
  signal   nco_s           : unsigned(internal_size_c-1 downto 0) := (others=>'0');

begin

  assert NCO_size_c >= internal_size_c
    report string_replace("Minimum value for NCO_size_c is %r.",to_string(internal_size_c))
    severity failure;

  nvalue_gen : if adjustable_freq generate
    nvalue_p : process(mclk_i, rst_i)
    begin
      if rst_i = '1' then
        n_value_s  <= (others=>'0');
      elsif rising_edge(mclk_i) then
        n_value_s <= to_unsigned(n_value_i);
      end if;
    end process;

  else generate
    n_value_s <= n_value_c;

  end generate;

  scaler_s <= scaler_i when use_scaler else '1';

  nco_u : nco_int
    generic map(
      NCO_size_c => NCO_size_c
    )
    port map (
      rst_i     => rst_i,
      mclk_i    => mclk_i,
      scaler_i  => scaler_s,
      n_value_i => to_std_logic_vector(n_value_s),
      clkout_o  => clkout_o
    );

end behavioral;
