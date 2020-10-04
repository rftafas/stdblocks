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
library stdblocks;
  use stdblocks.sync_lib.all;
  use stdblocks.timer_lib.all;

entity timer_lib_tb is
end timer_lib_tb;

architecture behavioral of timer_lib_tb is

  constant Fref_hz : frequency := 100 MHz;
  constant Fout_hz : frequency :=  10 MHz;

  constant PWM_size    : integer := 8;
  signal   rst_i       : std_logic;
  signal   mclk_i      : std_logic := '0';
  signal   threshold_i : std_logic_vector(PWM_size-1 downto 0);
  signal   pwm_o       : std_logic;

begin

  rst_i  <= '0', '1'   after 30 ns;
  mclk_i <= not mclk_i after  5 ns;

  threshold_i <= (PWM_size-1 =>'1', others=>'0');

  pwm_i : pwm
  generic map (
    Fref_hz  => Fref_hz,
    Fout_hz  => Fout_hz,
    PWM_size => PWM_size
  )
  port map (
    rst_i       => rst_i,
    mclk_i      => mclk_i,
    threshold_i => threshold_i,
    pwm_o       => pwm_o
  );



end behavioral;
