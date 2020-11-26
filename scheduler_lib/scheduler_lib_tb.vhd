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
-- altera vhdl_input_version vhdl_2008
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
library expert;
	use expert.std_logic_expert.all;
	use expert.std_string.all;
library stdblocks;
	use stdblocks.scheduler_lib.all;
library vunit_lib;
	context vunit_lib.vunit_context;


entity scheduler_lib_tb is
	generic (
		runner_cfg : string;
		n_elements : integer := 8;
		entity_sel : string
	);
end scheduler_lib_tb;

architecture simulation of scheduler_lib_tb is
	constant entity_padded : string(1 to 256) := string_padding(entity_sel,256);
	constant mode          : integer := 0;
  signal   clk_i         : std_logic := '0';
	signal   rst_i         : std_logic := '1';

	signal   request_i     : std_logic_vector(n_elements-1 downto 0);
	signal   ack_i         : std_logic_vector(n_elements-1 downto 0);
	signal   grant_o       : std_logic_vector(n_elements-1 downto 0);
	signal   index_o       : natural;
	signal   k_checkup     : integer;

begin

	clk_i <= not clk_i after 10 ns;

	main : process
  begin
    test_runner_setup(runner, runner_cfg);

		rst_i     <= '1';
		request_i <= (others=>'0');
		ack_i     <= (others=>'0');
		wait until rising_edge(clk_i);
		wait until rising_edge(clk_i);
		rst_i     <= '0';

		while test_suite loop
			 if run("Sanity check for system.") then
			 	report "System Sane. Begin tests.";
			 	check_true(true, result("Sanity check for system."));

			elsif run("Stand Still Test") then
				for k in 0 to 100 loop
					--do nothing. Obey the nine.
					check_equal(index_o, 0, "Index Error.");
					check_true(grant_o = (grant_o'range => '0'), "Provision Error.");
				end loop;
				check_passed("Stand Still Test Pass.");

			elsif run("Sequential Test") then
				for k in n_elements-1 downto 0 loop
					request_i(k) <= '1';
					wait until rising_edge(clk_i);
					wait until grant_o(k) = '1';
					wait until rising_edge(clk_i);
					check_equal(index_o, k, "Index Error.");
					wait until rising_edge(clk_i);
					request_i(k) <= '0';
					ack_i(k) <= '1';
					wait until grant_o(k) = '0';
					wait until rising_edge(clk_i);
					ack_i(k) <= '0';
				end loop;
				check_passed("Fixed Priority: Sequential Test Pass.");

			elsif run("All Request Test") then
				request_i <= (others=>'1');
				for k in n_elements-1 downto 0 loop
					wait until rising_edge(clk_i);
					while grant_o(k) /= '1' loop
						wait for 1 ps;
					end loop;
					wait until rising_edge(clk_i);
					check_equal(index_o, k, "Index Error.");
					wait until rising_edge(clk_i);
					request_i(k) <= '0';
					ack_i(k) <= '1';
					wait until grant_o(k) = '0';
					wait until rising_edge(clk_i);
					ack_i(k) <= '0';
					wait until rising_edge(clk_i);
				end loop;
				check_passed("All Request Test");

			elsif run("Persistent All Request Test") then
				request_i <= (others=>'1');
				for k in n_elements-1 downto 0 loop
					exit when string_match(entity_sel,"fixed_priority"); --fixed priprity will always favor the highest channel.
		 			wait until rising_edge(clk_i);
					while grant_o(k) /= '1' loop
						wait for 1 ps;
					end loop;
					wait until rising_edge(clk_i);
					check_equal(index_o, k, "Index Error.");
					wait until rising_edge(clk_i);
					ack_i(k) <= '1';
					wait until grant_o(k) = '0';
					wait until rising_edge(clk_i);
					ack_i(k)     <= '0';
				end loop;
				check_passed("Persistent All Request Test Pass.");

			end if;
		end loop;
  	test_runner_cleanup(runner); -- Simulation ends here
  end process;

	test_runner_watchdog(runner, 2 us);

		dut_gen : case entity_padded generate
			when string_padding("fixed_priority",256) =>
				dut_u : fixed_priority
					generic map (
					  n_elements => n_elements
					)
					port map (
					  clk_i     => clk_i,
					  rst_i     => rst_i,
					  request_i => request_i,
					  ack_i     => ack_i,
					  grant_o   => grant_o,
					  index_o   => index_o
					);

			when string_padding("round_robin",256) =>
				dut_u : round_robin
					generic map (
					  n_elements => n_elements
					)
					port map (
					  clk_i     => clk_i,
					  rst_i     => rst_i,
					  request_i => request_i,
					  ack_i     => ack_i,
					  grant_o   => grant_o,
					  index_o   => index_o
					);

			when string_padding("round_robin_hard",256) =>
				dut_u : round_robin_hard
					generic map (
					  n_elements => n_elements
					)
					port map (
					  clk_i     => clk_i,
					  rst_i     => rst_i,
					  request_i => request_i,
					  ack_i     => ack_i,
					  grant_o   => grant_o,
					  index_o   => index_o
					);

			when string_padding("queueing",256) =>
				dut_u : queueing
					generic map (
					  n_elements => n_elements
					)
					port map (
					  clk_i     => clk_i,
					  rst_i     => rst_i,
					  request_i => request_i,
					  ack_i     => ack_i,
					  grant_o   => grant_o,
					  index_o   => index_o
					);

			when string_padding("fast_queueing",256) =>
				dut_u : fast_queueing
					generic map (
					  n_elements => n_elements
					)
					port map (
					  clk_i     => clk_i,
					  rst_i     => rst_i,
					  request_i => request_i,
					  ack_i     => ack_i,
					  grant_o   => grant_o,
					  index_o   => index_o
					);

			when others =>

		end generate;

end simulation;
