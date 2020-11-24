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
	generic (runner_cfg : string);
end scheduler_lib_tb;

architecture simulation of scheduler_lib_tb is
	constant n_elements  : integer := 8;
	constant mode        : integer := 0;
  signal   clk_i       : std_logic := '0';
	signal   rst_i       : std_logic := '1';

	signal   fixed_request_i      : std_logic_vector(n_elements-1 downto 0);
	signal   fixed_ack_i          : std_logic_vector(n_elements-1 downto 0);
	signal   fixed_grant_o        : std_logic_vector(n_elements-1 downto 0);
	signal   fixed_index_o        : natural;

	signal   roundrobin_request_i : std_logic_vector(n_elements-1 downto 0);
	signal   roundrobin_ack_i     : std_logic_vector(n_elements-1 downto 0);
	signal   roundrobin_grant_o   : std_logic_vector(n_elements-1 downto 0);
	signal   roundrobin_index_o   : natural;

	signal   queueing_request_i   : std_logic_vector(n_elements-1 downto 0);
	signal   queueing_ack_i       : std_logic_vector(n_elements-1 downto 0);
	signal   queueing_grant_o     : std_logic_vector(n_elements-1 downto 0);
	signal   queueing_index_o     : natural;


begin

	clk_i <= not clk_i after 10 ns;
	rst_i <= '1', '0' after 40 ns;

		main : process
			variable j : integer := n_elements-1;
	  begin
	    test_runner_setup(runner, runner_cfg);

			if rst_i = '1' then
				fixed_request_i      <= (others=>'0');
				fixed_ack_i          <= (others=>'0');
				roundrobin_request_i <= (others=>'0');
				roundrobin_ack_i     <= (others=>'0');
				queueing_request_i   <= (others=>'0');
				queueing_ack_i       <= (others=>'0');
				j := n_elements-1;
				wait until rst_i = '0';
			end if;

			while test_suite loop
				 if run("Sanity check for system.") then
				 	report "System Sane. Begin tests.";
				 	check_true(true, result("Sanity check for system."));

				elsif run("Fixed Priority: Sequential Test") then
					wait until rising_edge(clk_i);
					fixed_request_i <= (others=>'1');
					for k in n_elements-1 downto 0 loop
						wait until fixed_grant_o(k) = '1';
						wait until rising_edge(clk_i);
						check_equal(fixed_index_o, k, "Index Error.");
						wait until rising_edge(clk_i);
						fixed_request_i(k) <= '0';
						fixed_ack_i(k)     <= '1';
						wait until fixed_grant_o(k) = '0';
						exit when fixed_request_i = (fixed_request_i'range => '0');
					end loop;
					check_passed("Fixed Priority: Sequential Test Pass.");

				elsif run("Round Robin: Sequential Test") then
					roundrobin_request_i <= (others=>'1');
					while true loop
						wait until roundrobin_grant_o /= (roundrobin_grant_o'range => '0');
						check_equal(roundrobin_index_o, j, "Idex Error.");
						wait until rising_edge(clk_i);
						roundrobin_ack_i(j)     <= '1';
						wait until roundrobin_grant_o(j) = '0';
						wait until rising_edge(clk_i);
						roundrobin_ack_i(j)     <= '0';
						j := j-1;
						exit when j = -1;
					end loop;
					j := 0;
					check_passed("Queueing Sequential Test Pass.");

				elsif run("Queueing 1: Sequential Test") then
					while true loop
			 			wait until rising_edge(clk_i);
			 			queueing_request_i(j) <= '1';
			 			wait until queueing_grant_o(j) = '1';
						check_equal(queueing_index_o, j, "Idex Error.");
						wait until rising_edge(clk_i);
			 			queueing_request_i(j) <= '0';
						queueing_ack_i(j)     <= '1';
						--check_true(index_o = j, result(string_replace("Index %r is correct. Pass.",to_string(j))));
						wait until queueing_grant_o(j) = '0';
						wait until rising_edge(clk_i);
						queueing_ack_i(j)     <= '0';
						j := j-1;
						exit when j = -1;
					end loop;
					j := 0;
					check_passed("Queueing Sequential Test Pass.");

				elsif run("Queueing 2: Sequential ACK Relief Test") then
					wait until rising_edge(clk_i);
					queueing_request_i <= (others=>'1');
					while true loop
						wait until queueing_grant_o /= (queueing_grant_o'range => '0');
						check_equal(queueing_index_o, index_of_1(queueing_grant_o), "Index Error.");
						j := index_of_1(queueing_grant_o);
						wait until rising_edge(clk_i);
						queueing_request_i(j) <= '0';
						queueing_ack_i(j)     <= '1';
						wait until queueing_grant_o(j) = '0';
						exit when queueing_request_i = (queueing_request_i'range => '0');
					end loop;
					check_passed("Sequential ACK Relief Test Pass.");
				end if;
			end loop;
    	test_runner_cleanup(runner); -- Simulation ends here
	  end process;

		fixed_priority_i : fixed_priority
			generic map (
			  n_elements => n_elements
			)
			port map (
			  clk_i     => clk_i,
			  rst_i     => rst_i,
			  request_i => fixed_request_i,
			  ack_i     => fixed_ack_i,
			  grant_o   => fixed_grant_o,
			  index_o   => fixed_index_o
			);

		round_robin_i : round_robin
			generic map (
			  n_elements => n_elements
			)
			port map (
			  clk_i     => clk_i,
			  rst_i     => rst_i,
			  request_i => roundrobin_request_i,
			  ack_i     => roundrobin_ack_i,
			  grant_o   => roundrobin_grant_o,
			  index_o   => roundrobin_index_o
			);

		queueing_dut : queueing
			generic map (
			  n_elements => n_elements
			)
			port map (
			  clk_i     => clk_i,
			  rst_i     => rst_i,
			  request_i => queueing_request_i,
			  ack_i     => queueing_ack_i,
			  grant_o   => queueing_grant_o,
			  index_o   => queueing_index_o
			);

end simulation;
