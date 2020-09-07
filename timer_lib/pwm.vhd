----------------------------------------------------------------------------------
-- timer_lib  by Ricardo F Tafas Jr
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
	use IEEE.math_real.all;
library stdblocks;
  use stdblocks.timer_lib.all;

entity pwm is
  generic (
    Fref_hz  : frequency := 100 MHz;
    Fout_hz  : frequency :=  10 MHz;
    PWM_size : integer   :=  16
  );
  port (
    rst_i       : in  std_logic;
    mclk_i      : in  std_logic;
    threshold_i : in  std_logic_vector(PWM_size-1 downto 0);
    pwm_o       : out std_logic
  );
end pwm;

architecture behavioral of pwm is

  constant maxvalue_c : integer := integer(Fref_hz/Fout_hz);
  signal   pwm_cnt    : unsigned(PWM_size-1 downto 0) := (others=>'0');

begin

  assert 2**PWM_size > maxvalue_c
    report "Unreachable value on PWM. Increase PWM_size."
    severity warning;

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
        if pwm_cnt = unsigned(threshold_i) then
          pwm_o   <= '0';
        end if;
      end if;
    end if;
  end process;

end behavioral;
