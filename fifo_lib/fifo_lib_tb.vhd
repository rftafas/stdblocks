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
    use stdblocks.ram_lib.all;
library stdblocks;

library vunit_lib;
    context vunit_lib.vunit_context;
    context vunit_lib.com_context;
    context vunit_lib.vc_context;

    use work.fifo_lib.all;
    use work.fifo_vci_pkg.all;

entity fifo_lib_tb is
  generic (
		runner_cfg : string;
		entity_sel : string;
        run_time   : integer
	);
end fifo_lib_tb;

architecture behavioral of fifo_lib_tb is

    constant dut_sel    : string(1 to 256) := string_padding(entity_sel,256);
    constant port_size  : integer := 8;
    constant fifo_size  : integer := 4;
    constant run_time_c : time := run_time * 1 us;
    constant sim_cycles : time := 10 ps;

    signal clka_i       : std_logic := '0';
    signal rsta_i       : std_logic := '1';
    signal clkb_i       : std_logic := '0';
    signal rstb_i       : std_logic := '1';

    signal dataa_i      : std_logic_vector(port_size-1 downto 0);
    signal datab_o      : std_logic_vector(port_size-1 downto 0);
    signal ena_i        : std_logic;
    signal enb_i        : std_logic;

    signal addr_s       : std_logic_vector(fifo_size-1 downto 0) := (others => '0');
    signal stack_data_s : std_logic_vector(port_size-1 downto 0);

    signal fifo_status_o   : fifo_status;
    signal fifo_status_b_o : fifo_status;

    shared variable fifo_vci : fifo_vci_t;

    constant clka_c : time := 10 ns;
    constant clkb_c : time := 22 ns;

    procedure wait_cycles ( signal clock : in std_logic; cycles : in positive ) is
    begin
        for j in 0 to cycles-1 loop
            wait until rising_edge(clock);
        end loop;
    end procedure;

    procedure wait_until( condition : in boolean ) is
    begin
        loop
            exit when condition;
            wait for 100 ps;
        end loop;
    end procedure;

    signal write_flag    : boolean := false;
    signal read_flag     : boolean := false;

begin

    clk_gen : if dut_sel = string_padding("stdfifo2ck",256) generate
        clka_i <= not clka_i after clka_c;
        clkb_i <= not clkb_i after clkb_c;
    else generate
        clka_i <= not clka_i after clka_c;
        clkb_i <= not clkb_i after clka_c;
    end generate;

    main : process
        variable timer_v    : time;
        variable counter_v  : integer := 0;
        variable rdata_v    : std_logic_vector(port_size-1 downto 0);
        variable wdata_v    : std_logic_vector(port_size-1 downto 0);
    begin
        test_runner_setup(runner, runner_cfg);
        rsta_i <= '1';
        rstb_i <= '1';
        fifo_vci.reset(net);
        wait for 30 ns;
        rsta_i <= '0';
        rstb_i <= '0';
        wait until rising_edge(clka_i);

        while test_suite loop
            if run("Free running simulation") then
                set_timeout(runner, now + 20 us);
                info("Main: Will run until " & to_string(now + 10 us) & ". Timeout set for: " & to_string(now + 20 us) & "." );
                check_equal(fifo_status_o.underflow,'0',result("Error: Underflow detected."));
                check_equal(fifo_status_o.empty,'1',result("Error: Empty not detected."));
                check_equal(fifo_status_o.goempty,'0',result("Error: Go Empty detected."));
                check_equal(fifo_status_o.steady,'0',result("Error: Steady detected."));
                check_equal(fifo_status_o.gofull,'0',result("Error: Go Full detected."));
                check_equal(fifo_status_o.full,'0',result("Error: Full detected."));
                check_equal(fifo_status_o.overflow,'0',result("Error: Overflow detected."));
                check_equal(fifo_status_b_o.underflow,'0',result("Error: Underflow detected."));
                check_equal(fifo_status_b_o.empty,'1',result("Error: Empty not detected."));
                check_equal(fifo_status_b_o.goempty,'0',result("Error: Go Empty detected."));
                check_equal(fifo_status_b_o.steady,'0',result("Error: Steady detected."));
                check_equal(fifo_status_b_o.gofull,'0',result("Error: Go Full detected."));
                check_equal(fifo_status_b_o.full,'0',result("Error: Full detected."));
                check_equal(fifo_status_b_o.overflow,'0',result("Error: Overflow detected."));
                wait for 10 us;
                check_true(true, result("Free running finished."));

            elsif run("Isolated Write test") then
                wdata_v := all_1(port_size);
                fifo_vci.write(net,wdata_v);
                wait until (fifo_status_b_o.empty = '0');
                wait_cycles(clkb_i,3);
                check_equal(fifo_status_b_o.empty,'0',result("Error: Empty (b) not detected."));

            elsif run("Write to Go Empty") then
                wdata_v := all_1(port_size);
                for j in 0 to (2**fifo_size)/4-1 loop
                    fifo_vci.write(net,wdata_v);
                    wait_cycles(clka_i,2);
                    check_equal(fifo_status_o.goempty,'1',result("Error: Go Empty not detected."));
                    wait_cycles(clkb_i,3);
                    check_equal(fifo_status_b_o.goempty,'1',result("Error: Go Empty (b) not detected."));
                    wait_cycles(clka_i,1);
                end loop;

            elsif run("Write to Steady") then
                wdata_v := all_1(port_size);
                for j in 0 to 2**(fifo_size)/4 loop
                    fifo_vci.write(net,wdata_v);
                end loop;
                for j in 2**(fifo_size)/4+1 to 3*2**(fifo_size)/4-1 loop
                    fifo_vci.write(net,wdata_v);
                    wait_cycles(clka_i,2);
                    check_equal(fifo_status_o.steady,'1',result("Error: Steady not detected."));
                    wait_cycles(clkb_i,3);
                    check_equal(fifo_status_b_o.steady,'1',result("Error: Steady (b) not detected."));
                    wait_cycles(clka_i,1);
                end loop;

            elsif run("Write to Gofull") then
                wdata_v := all_1(port_size);
                for j in 0 to 3*2**(fifo_size)/4 loop
                    fifo_vci.write(net,wdata_v);
                end loop;
                for j in 3*2**(fifo_size)/4+1 to 2**(fifo_size)-1 loop
                    fifo_vci.write(net,wdata_v);
                    wait_cycles(clka_i,2);
                    check_equal(fifo_status_o.gofull,'1',result("Error: Steady not detected."));
                    wait_cycles(clkb_i,3);
                    check_equal(fifo_status_b_o.gofull,'1',result("Error: Steady (b) not detected."));
                    wait_cycles(clka_i,1);
                end loop;

            elsif run("Write to Full") then
                wdata_v := all_1(port_size);
                for j in 0 to 2**(fifo_size) loop
                    fifo_vci.write(net,wdata_v);
                end loop;
                wait_cycles(clka_i,2);
                check_equal(fifo_status_o.full,'1',result("Error: Full not detected."));
                wait_cycles(clkb_i,3);
                check_equal(fifo_status_b_o.full,'1',result("Error: Full (b) not detected."));

            elsif run("Single Write/Read") then
                wdata_v := all_1(port_size);
                fifo_vci.write(net,wdata_v);
                wait until (fifo_status_b_o.empty = '0');
                fifo_vci.read(net,rdata_v);
                check_equal(rdata_v,wdata_v,result("Wrong read value detected."));
                wait until (fifo_status_b_o.empty = '1');
                wait for 10 ns;
                check_true(true, result("Single Write/Read finished."));

            elsif run("Full Block Write/Read") then
                for j in 0 to 2**(fifo_size-1) loop
                    wdata_v := to_std_logic_vector(j,wdata_v'length);
                    fifo_vci.write(net,wdata_v);
                end loop;
                wait until rising_edge(clkb_i);
                for j in 0 to 2**(fifo_size-1) loop
                    fifo_vci.read(net,rdata_v);
                    check_equal(rdata_v,to_std_logic_vector(j,rdata_v'length),result("Error: wrong data received."));
                end loop;
                wait until rising_edge(clkb_i);

            elsif run("Underflow test") then
                fifo_vci.read(net,rdata_v);
                wait until fifo_status_o.underflow = '1' or fifo_status_b_o.underflow = '1';
                wait until fifo_status_o.empty = '1' or fifo_status_b_o.empty = '1';
                check_true(true, result("Underflow test finished."));

            elsif run("Overflow test") then
                for j in 0 to 2**(fifo_size)+1 loop
                    wdata_v := to_std_logic_vector(j,wdata_v'length);
                    fifo_vci.write(net,wdata_v);
                end loop;
                --detect any side overflow
                wait until fifo_status_o.overflow = '1' or fifo_status_b_o.overflow = '1';
                --wait both sides to regenerate
                wait until fifo_status_o.empty = '1' or fifo_status_b_o.empty = '1';
                check_true(true, result("Overflow test finished."));

            elsif run("Steady Run") then
                --place fifo into steady state;
                write_flag <= true;
                for j in 0 to 2**(fifo_size+2)-1 loop
                    --wait until fifo_status_o.full = '0' or fifo_status_o.gofull = '0';
                    loop
                        if fifo_status_o.full = '1' or fifo_status_o.gofull = '1' then
                            wait until rising_edge(clka_i);
                        else
                            exit;
                        end if;
                    end loop;
                    wdata_v := to_std_logic_vector(j,wdata_v'length);
                    fifo_vci.write(net,wdata_v);
                end loop;
                write_flag <= false;
                wait until read_flag;
                wait_cycles(clka_i,2);
                check_equal(fifo_status_o.empty,'1',result("Error: Empty not detected."));
                wait_cycles(clkb_i,2);
                check_equal(fifo_status_b_o.empty,'1',result("Error: Empty (b) not detected."));

            elsif run("Gapped Steady Run") then
                write_flag <= true;
                for j in 0 to 2**(fifo_size+2)-1 loop
                    --wait until fifo_status_o.full = '0' or fifo_status_o.gofull = '0';
                    loop
                        if fifo_status_o.full = '1' or fifo_status_o.gofull = '1' then
                            wait until rising_edge(clka_i);
                        else
                            exit;
                        end if;
                    end loop;
                    wdata_v := to_std_logic_vector(j,wdata_v'length);
                    fifo_vci.write(net,wdata_v);
                    wait until rising_edge(clka_i);
                end loop;
                write_flag <= false;
                wait until read_flag;
                wait_cycles(clka_i,2);
                check_equal(fifo_status_o.empty,'1',result("Error: Empty not detected."));
                wait_cycles(clkb_i,2);
                check_equal(fifo_status_b_o.empty,'1',result("Error: Empty (b) not detected."));

            elsif run("Empty Run") then
                write_flag <= true;
                for j in 0 to 2**(fifo_size+2)-1 loop
                    wait until fifo_status_o.empty = '1' and rising_edge(clka_i);
                    wdata_v := to_std_logic_vector(j,wdata_v'length);
                    fifo_vci.write(net,wdata_v);
                end loop;
                write_flag <= false;
                wait until read_flag;
                wait_cycles(clka_i,2);
                check_equal(fifo_status_o.empty,'1',result("Error: Empty not detected."));
                wait_cycles(clkb_i,2);
                check_equal(fifo_status_b_o.empty,'1',result("Error: Empty (b) not detected."));

            elsif run("Full Run") then
                write_flag <= true;
                for j in 0 to 2**(fifo_size+2)-1 loop
                    loop
                        if fifo_status_o.full = '1' then
                            wait until rising_edge(clka_i);
                        else
                            exit;
                        end if;
                    end loop;
                    wdata_v := to_std_logic_vector(j,wdata_v'length);
                    fifo_vci.write(net,wdata_v);
                end loop;
                write_flag <= false;
                wait until read_flag;
                wait_cycles(clka_i,2);
                check_equal(fifo_status_o.empty,'1',result("Error: Empty not detected."));
                wait_cycles(clkb_i,2);
                check_equal(fifo_status_b_o.empty,'1',result("Error: Empty (b) not detected."));

            end if;
        end loop;

        test_runner_cleanup(runner); -- Simulation ends here
    end process;

    test_runner_watchdog(runner, run_time_c);

    aux_p : process
        variable rdata_v    : std_logic_vector(port_size-1 downto 0);
        variable wdata_v    : std_logic_vector(port_size-1 downto 0);
        variable counter_v  : integer := 0;
    begin
        wait until rstb_i = '0';
        wait until write_flag;
        wait until rising_edge(clkb_i);
        if running_test_case = "Steady Run" then
            wait until fifo_status_b_o.steady = '1';
            loop
                if fifo_status_b_o.goempty = '0' or (not write_flag and fifo_status_b_o.empty = '0') then
                    fifo_vci.read(net,rdata_v);
                    check_equal(to_integer(rdata_v),counter_v,result("Error: incorrect value read."));
                    counter_v := counter_v + 1;
                else
                    wait until rising_edge(clkb_i);
                end if;
                if counter_v = 2**(fifo_size+2) then
                    read_flag <= true;
                    info("Aux: Read Complete.");
                    exit;
                end if;
            end loop;

        elsif running_test_case = "Gapped Steady Run" then
            wait until fifo_status_b_o.steady = '1';
            loop
                if fifo_status_b_o.empty = '0' or (not write_flag and fifo_status_b_o.empty = '0') then
                    fifo_vci.read(net,rdata_v);
                    check_equal(to_integer(rdata_v),counter_v,result("Error: incorrect value read."));
                    counter_v := counter_v + 1;
                -- else
                --     wait until rising_edge(clkb_i);
                end if;
                wait until rising_edge(clkb_i);
                if counter_v = 2**(fifo_size+2) then
                    read_flag <= true;
                    info("Aux: Read Complete.");
                    exit;
                end if;
            end loop;

        elsif running_test_case = "Empty Run" then
            loop
                wait until fifo_status_b_o.empty = '0' and rising_edge(clkb_i);
                fifo_vci.read(net,rdata_v);
                check_equal(to_integer(rdata_v),counter_v,result("Error: incorrect value read."));
                counter_v := counter_v + 1;
                if counter_v = 2**(fifo_size+2) then
                    read_flag <= true;
                    info("Aux: Read Complete.");
                    exit;
                end if;
            end loop;

        elsif running_test_case = "Full Run" then
            wait until fifo_status_b_o.full = '1';
            loop
                if fifo_status_b_o.full = '1' or (not write_flag and fifo_status_b_o.empty = '0') then
                    fifo_vci.read(net,rdata_v);
                    check_equal(to_integer(rdata_v),counter_v,result("Error: incorrect value read."));
                    counter_v := counter_v + 1;
                else
                    wait until rising_edge(clkb_i);
                end if;

                wait for 1 ps; --needed for simulation stabilization.

                if counter_v = 2**(fifo_size+2) then
                    read_flag <= true;
                    info("Aux: Read Complete.");
                    exit;
                end if;
            end loop;

        end if;
        wait;
    end process;

    porta_p : process
    begin
        fifo_vci.port_a(net,clka_i,rsta_i,dataa_i,ena_i);
    end process;

    portb_p : process
    begin
        if dut_sel = string_padding("stdfifo2ck",256) then
            fifo_vci.port_b(net,clkb_i,rstb_i,datab_o,enb_i);
        else
            fifo_vci.port_b(net,clka_i,rstb_i,datab_o,enb_i);
        end if;
    end process;

    dut_gen : case dut_sel generate
        when string_padding("intfifo1ck",256) =>
            -- intfifo1ck_i : intfifo1ck is
            --     generic map(
            --         ram_type  => blockram,
            --         fifo_size => fifo_size,
            --         port_size => port_size
            --     )
            --     port map(
            --         clk_i         => clka_i,
            --         rst_i         => rsta_i,
            --         dataa_i       => dataa_i,
            --         datab_o       => datab_o,
            --         ena_i         => ena_i,
            --         enb_i         => enb_i,
            --         pointera_o    => ,
            --         pointerb_o    =>
            --     );

        when string_padding("srfifo1ck",256) =>
            srfifo1ck_i : srfifo1ck
                generic map (
                    fifo_size => fifo_size,
                    port_size => port_size
                )
                port map (
                    clk_i         => clka_i,
                    rst_i         => rsta_i,
                    dataa_i       => dataa_i,
                    datab_o       => datab_o,
                    ena_i         => ena_i,
                    enb_i         => enb_i,
                    fifo_status_o => fifo_status_o
                );

            fifo_status_b_o <= fifo_status_o;

        when string_padding("stdfifo1ck",256) =>
            stdfifo1ck_i : stdfifo1ck
                generic map (
                    ram_type  => "auto",
                    fifo_size => fifo_size,
                    port_size => port_size
                )
                port map (
                        clk_i       => clka_i,
                        rst_i       => rsta_i,
                        dataa_i     => dataa_i,
                        datab_o     => datab_o,
                        ena_i       => ena_i,
                        enb_i       => enb_i,
                        fifo_status_o => fifo_status_o
                    );

            fifo_status_b_o <= fifo_status_o;

        when string_padding("stdfifo2ck",256) =>
            stdfifo2ck_i : stdfifo2ck
                generic map (
                    ram_type  => "auto",
                    fifo_size => fifo_size,
                    port_size => port_size
                )
                port map (
                    clka_i       => clka_i,
                    rsta_i       => rsta_i,
                    clkb_i       => clkb_i,
                    rstb_i       => rstb_i,
                    dataa_i      => dataa_i,
                    datab_o      => datab_o,
                    ena_i        => ena_i,
                    enb_i        => enb_i,
                    fifo_status_a_o => fifo_status_o,
                    fifo_status_b_o => fifo_status_b_o
                );

        when others =>
            assert false
                report "Invalid Entity Selection."
                severity failure;

    end generate;

end behavioral;
