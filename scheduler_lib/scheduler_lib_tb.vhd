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
library stdblocks;
	use stdblocks.scheduler_lib.all;
library vunit_lib;
	context vunit_lib.vunit_context;


entity scheduler_lib_tb is
	generic (runner_cfg : string);
end scheduler_lib_tb;

architecture simulation of scheduler_lib_tb is
	constant n_elements : integer := 8;
	constant mode       : integer := 0;
  signal   clk_i      : std_logic := '0';
	signal   rst_i      : std_logic := '1';
	signal   request_i  : std_logic_vector(n_elements-1 downto 0);
	signal   ack_i      : std_logic_vector(n_elements-1 downto 0);
	signal   grant_o    : std_logic_vector(n_elements-1 downto 0);
	signal   index_o    : natural;

begin

	clk_i <= not clk_i after 10 ns;
	rst_i <= '1', '0' after 40 ns;

		main : process
			variable j : integer := 0;
	  begin
	    test_runner_setup(runner, runner_cfg);

			while test_suite loop
				if run("Sanity check for system.") then
					report "System Sane. Begin tests.";
					check_true(true, result("Sanity check for system."));
				elsif run("Select Channel") then
					--for j in 0 to n_elements-1 loop
						-- request_i(j) <= '1';
						-- wait until grant_o(j) = '1';
						-- wait until rising_edge(clk_i);
						check_true( 0    = j  , result("Pass."));
						-- check_true( grant_o(j) = '1', result("Pass."));
					--end loop;
				end if;
			end loop;
    	test_runner_cleanup(runner); -- Simulation ends here
	  end process;

		queueing_i : queueing
			generic map (
			  n_elements => n_elements,
			  mode       => mode
			)
			port map (
			  clk_i     => clk_i,
			  rst_i     => rst_i,
			  request_i => request_i,
			  ack_i     => ack_i,
			  grant_o   => grant_o,
			  index_o   => index_o
			);


end simulation;
