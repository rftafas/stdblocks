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
	use expert.std_string.all;
library stdblocks;
  use stdblocks.sync_lib.all;
  use stdblocks.timer_lib.all;
library vunit_lib;
	context vunit_lib.vunit_context;

entity timer_lib_tb is
  generic (
		runner_cfg : string;
		entity_sel : string;
    run_time   : integer;
    period     : integer
	);
end timer_lib_tb;

architecture behavioral of timer_lib_tb is

  constant entity_padded : string(1 to 256) := string_padding(entity_sel,256);
  constant run_time_c    : time := run_time * 1 us;
  constant period_c      : time := period   * 1 ns;

  constant Fref_hz       : real := 100.0000e+6;
  constant clk_period_c  : time :=  10 ns;
  constant Fout_hz       : real :=  10.0000e+6;
  constant Resolution_hz : real :=  20.0000;
  constant Bandwidth_hz  : real := 500.0000e+3;

  --PWM
  constant threshold_c : std_logic_vector(7 downto 0) := to_std_logic_vector(5,8) - 1;

  signal   rst_i       : std_logic;
  signal   clk_i       : std_logic := '0';
  signal   clkin_s     : std_logic := '0';
  signal   gen_clk_s   : std_logic;

begin

  clk_i   <= not   clk_i after clk_period_c/2;
  clkin_s <= not clkin_s after 50 ns;

  main : process
  begin
    test_runner_setup(runner, runner_cfg);

    rst_i     <= '1';
    wait until rising_edge(clk_i);
    wait until rising_edge(clk_i);
    rst_i     <= '0';

    while test_suite loop
      if run("Free running simulation") then
        report "Will run for " & to_string(run_time_c);
        wait for run_time_c;
        check_true(true, result("Free running finished."));

      elsif run("Check Period") then
        wait until gen_clk_s = '1';
        wait until gen_clk_s = '0';
        for j in 0 to 99 loop
          wait until gen_clk_s = '1';
          wait for period_c;
          --note: the signal has not yet transitioned.
          --this will happen on next simulation cycle.
          check_equal(gen_clk_s,'1',"Period Test Pass.");
          --note: we align the date again.
          wait until gen_clk_s = '0';
          wait for period_c;
          --same as above, it has not yet changed.
          check_equal(gen_clk_s,'0',"Period Test Pass.");
          exit when string_match("long_counter",entity_sel);
          exit when string_match("precise_long_counter",entity_sel);
        end loop;

      end if;
    end loop;

    test_runner_cleanup(runner); -- Simulation ends here
  end process;

  --watchdog depends on the entity being tested.
  test_runner_watchdog(runner, run_time_c + 1 us );

  dut_gen : case entity_padded generate
    when string_padding("pwm",256) =>
      pwm_u : pwm
        generic map (
          Fref_hz  => Fref_hz,
          Fout_hz  => Fout_hz,
          PWM_size => 8
        )
        port map (
          rst_i       => rst_i,
          mclk_i      => clk_i,
          threshold_i => threshold_c,
          pwm_o       => gen_clk_s
        );

    when string_padding("nco",256) =>
      nco_u : nco
        generic map (
          Fref_hz         => Fref_hz,
          Fout_hz         => Fout_hz,
          Resolution_hz   => Resolution_hz,
          use_scaler      => false,
          adjustable_freq => false,
          NCO_size_c      => 16
        )
        port map (
          rst_i     => rst_i,
          mclk_i    => clk_i,
          scaler_i  => '1',
          sync_i    => '0',
          n_value_i => (15 downto 0 => '0'),
          clkout_o  => gen_clk_s
        );

    when string_padding("adpll",256) =>
      adpll_u : adpll
        generic map (
          Fref_hz       => Fref_hz,
          Fout_hz       => Fout_hz,
          Bandwidth_hz  => Bandwidth_hz,
          Resolution_hz => Resolution_hz
        )
        port map (
          rst_i    => rst_i,
          mclk_i   => clk_i,
          clkin_i  => clkin_s,
          clkout_o => gen_clk_s
        );

    when string_padding("frac_adpll",256) =>
      frac_adpll_u : adpll_fractional
        generic map(
          Fref_hz       => Fref_hz,
          Fout_hz       => Fout_hz,
          Bandwidth_hz  => Bandwidth_hz,
          Resolution_hz => Resolution_hz
        )
        port map(
          rst_i         => rst_i,
          mclk_i        => clk_i,
          multiplier_i  => 4,
          divider_i     => 4,
          clkin_i       => clkin_s,
          clkout_o      => gen_clk_s
        );

    when string_padding("long_counter",256) =>
      long_counter_u : long_counter
        generic map (
          fref_hz => Fref_hz,
          period  => 100.0000e-6,
          sr_size => 16
        )
        port map (
          rst_i    => rst_i,
          mclk_i   => clk_i,
          enable_i => '1',
          clkout_o => gen_clk_s
        );

    when string_padding("precise_long_counter",256) =>
      precise_long_counter_u : precise_long_counter
        generic map (
          fref_hz => fref_hz,
          period  => 100.0000e-6,
          sr_size => 8
        )
        port map (
          rst_i    => rst_i,
          mclk_i   => clk_i,
          enable_i => '1',
          clkout_o => gen_clk_s
        );

    when others =>
			assert false
				report "Invalid Entity Selection."
				severity failure;

		end generate;


end behavioral;
