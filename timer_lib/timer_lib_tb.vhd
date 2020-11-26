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
    run_time   : time := 100 us
	);
end timer_lib_tb;

architecture behavioral of timer_lib_tb is

  constant clk_period_c  : time := 10 ns;
  constant entity_padded : string(1 to 256) := string_padding(entity_sel,256);
  constant Fref_hz       : frequency := 100 MHz;
  constant Fout_hz       : frequency :=  10 MHz;
  constant Resolution_hz : frequency :=  20  Hz;
  constant Bandwidth_hz  : frequency := 500 kHz;

  constant PWM_size    : integer := 8;
  signal   rst_i       : std_logic;
  signal   clk_i       : std_logic := '0';
  signal   clkin_s     : std_logic := '0';
  signal   threshold_c : std_logic_vector(PWM_size-1 downto 0) := to_std_logic_vector(5,PWM_size) - 1;
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
        report "Will run for " & to_string(run_time);
        wait for run_time;
        check_true(true, result("Free running finished."));

      elsif run("Check Period") then
        wait until gen_clk_s = '1';
        wait until gen_clk_s = '0';
        for j in 0 to 99 loop
          wait until gen_clk_s = '1';
          wait for 5 * clk_period_c;
          --note: the signal has not yet transitioned.
          --this will happen on next simulation cycle.
          check_equal(gen_clk_s,'1',"Period Test Pass.");
          --note: we align the date again.
          wait until gen_clk_s = '0';
          wait for 5 * clk_period_c;
          --same as above, it has not yet changed.
          check_equal(gen_clk_s,'0',"Period Test Pass.");
        end loop;

      end if;
    end loop;

    test_runner_cleanup(runner); -- Simulation ends here
  end process;

  --watchdog depends on the entity being tested.
	test_runner_watchdog(runner, run_time+1 us);

  dut_gen : case entity_padded generate
    when string_padding("pwm",256) =>
      pwm_i : pwm
        generic map (
          Fref_hz  => Fref_hz,
          Fout_hz  => Fout_hz,
          PWM_size => PWM_size
        )
        port map (
          rst_i       => rst_i,
          mclk_i      => clk_i,
          threshold_i => threshold_c,
          pwm_o       => gen_clk_s
        );

    when string_padding("nco",256) =>
      nco_i : nco
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
          n_value_i => (15 downto 0 => '0'),
          clkout_o  => gen_clk_s
        );

    when string_padding("adpll",256) =>
      adpll_i : adpll
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

    when others =>
			assert false
				report "Invalid Entity Selection."
				severity failure;

		end generate;


end behavioral;
