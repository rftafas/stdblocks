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
library vunit_lib;
  context vunit_lib.vunit_context;

entity sync_lib_tb is
  generic (
		runner_cfg : string;
		-- entity_sel : string;
    run_time   : integer --;
    -- period     : integer
	);
end sync_lib_tb;

architecture behavioral of sync_lib_tb is

  constant run_time_c    : time := run_time * 1 us;

  signal rst_i     : std_logic;
  signal mclk_i    : std_logic := '1';
  signal slowclk_i : std_logic := '1';

  signal align_i_s  : std_logic_vector(7 downto 0);
  signal align_o_s  : std_logic_vector(7 downto 0);
  signal det_up_s   : std_logic;
  signal det_down_s : std_logic;
  signal det_ud_s   : std_logic;
  signal syncr_s    : std_logic;
  signal stretch_s  : std_logic;

begin

  rst_i     <= '1',      '0' after 50 ns;
  mclk_i    <= not mclk_i    after 10 ns;
  slowclk_i <= not slowclk_i after 35 ns;

  main : process
  begin
    test_runner_setup(runner, runner_cfg);

    rst_i     <= '1';
    wait until rising_edge(mclk_i);
    wait until rising_edge(mclk_i);
    rst_i     <= '0';

    while test_suite loop
      if run("Free running simulation") then
        report "Will run for " & to_string(run_time_c);
        wait for run_time_c;
        check_true(true, result("Free running finished."));

      end if;
    end loop;

    test_runner_cleanup(runner); -- Simulation ends here
  end process;

  process
  begin
    align_i_s <= (others=>'0');
    wait until rst_i = '0';
    wait until rising_edge(mclk_i);
    for j in align_i_s'range loop
      align_i_s(j) <= '1';
      wait until rising_edge(mclk_i);
    end loop;
    wait until align_o_s = "11111111";
    wait until rising_edge(mclk_i);
    for j in align_i_s'range loop
      align_i_s(j) <= '0';
      wait until rising_edge(mclk_i);
    end loop;
    wait;
  end process;



  pulse_align_i : pulse_align
    generic map (
      port_size => 8
    )
    port map (
      rst_i  => rst_i,
      mclk_i => mclk_i,
      en_i   => align_i_s,
      en_o   => align_o_s
    );

    det_up_i : det_up
    port map (
      rst_i  => rst_i,
      mclk_i => mclk_i,
      din    => align_o_s(7),
      dout   => det_up_s
    );

    det_down_i : det_down
    port map (
      rst_i  => rst_i,
      mclk_i => mclk_i,
      din    => align_o_s(7),
      dout   => det_down_s
    );

    det_updown_i : det_updown
    port map (
      rst_i  => rst_i,
      mclk_i => mclk_i,
      din    => align_o_s(7),
      dout   => det_ud_s
    );

    sync_r_i : sync_r
      generic map (
        stages => 5
      )
      port map (
        rst_i  => rst_i,
        mclk_i => mclk_i,
        din    => align_o_s(7),
        dout   => syncr_s
      );

    async_capture_i : async_capture
    port map (
      clkin_i   => slowclk_i,
      clkout_i  => mclk_i,
      din       => det_up_s,
      dout      => stretch_s
    );


end behavioral;
