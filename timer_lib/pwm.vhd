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

entity pwm is
  generic (
    Fref_hz  : frequency := 100 MHz;
    Fout_hz  : frequency :=  10 MHz;
    PWM_size : positive  :=   8
  );
  port (
    rst_i       : in  std_logic;
    mclk_i      : in  std_logic;
    threshold_i : in  std_logic_vector(PWM_size-1 downto 0);
    pwm_o       : out std_logic
  );
end pwm;

architecture behavioral of pwm is

  constant maxvalue_c : natural := integer(Fref_hz/Fout_hz)-1;
  constant PWMsize_c  : natural := size_of(maxvalue_c);
  signal   pwm_cnt    : unsigned(PWMsize_c-1 downto 0) := (others=>'0');

begin

  assert 2**PWM_size >= maxvalue_c
    report string_replace("Increase PWM_size to at least %r.",to_string(PWMsize_c))
    severity failure;

  assert false
    report string_replace("PWM will count from 0 to %r. Set threshold_i accordingly.",to_string(maxvalue_c))
    severity note;

  pwm_p : process(all)
  begin
    if rst_i = '1' then
      pwm_o   <= '0';
      pwm_cnt <= (others=>'0');
    elsif mclk_i = '1' and mclk_i'event then
      if pwm_cnt = maxvalue_c then
        pwm_cnt <= (others=>'0');
        pwm_o   <= '1';
      else
        pwm_cnt <= pwm_cnt + 1;
        if pwm_cnt = threshold_i then
          pwm_o   <= '0';
        end if;
      end if;
    end if;
  end process;

end behavioral;
