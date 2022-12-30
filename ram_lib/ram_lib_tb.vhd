----------------------------------------------------------------------------------
--Copyright 2022 Ricardo F Tafas Jr

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

library vunit_lib;
    context vunit_lib.vunit_context;
    context vunit_lib.com_context;
    context vunit_lib.vc_context;

use work.ram_lib.all;

entity ram_lib_tb is
  generic (
    runner_cfg      : string;
    entity_sel      : string;
    port_size       : positive  := 8;
    addr_size       : positive  := 8;
    fall_through    : boolean;
    run_time        : integer
);
end entity;

architecture simulation of ram_lib_tb is

    function latency_set ( fall_through : boolean ) return positive is
    begin
        if fall_through then
            return 1;
        else
            return 2;
        end if;
    end function;

    constant latency : positive := latency_set(fall_through);

    constant num_back_to_back_reads : integer := 64;

    signal rsta_s     : std_logic := '0';
    signal rstb_s     : std_logic := '0';
    signal clka_s     : std_logic := '0';
    signal clkb_s     : std_logic := '0';
    signal ena_s      : std_logic;
    signal enb_s      : std_logic;
    signal wea_s      : std_logic_vector(7 downto 0) := (others => '0');
    signal web_s      : std_logic_vector(7 downto 0) := (others => '0');
    signal addra_s    : std_logic_vector(addr_size-1 downto 0) := (others => '0');
    signal addrb_s    : std_logic_vector(addr_size-1 downto 0) := (others => '0');
    signal dataa_i_s  : std_logic_vector(port_size-1 downto 0) := (others => '0');
    signal datab_i_s  : std_logic_vector(port_size-1 downto 0) := (others => '0');
    signal dataa_o_s  : std_logic_vector(port_size-1 downto 0) := (others => '0');
    signal datab_o_s  : std_logic_vector(port_size-1 downto 0) := (others => '0');

    constant porta_handle : bus_master_t := new_bus(
        data_length     => port_size,
        address_length  => addr_size,
        byte_length     => 1
    );

    constant portb_handle : bus_master_t := new_bus(
        data_length     => port_size,
        address_length  => addr_size,
        byte_length     => 1
    );

begin

    clka_s <= not clka_s after 5 ns;
    rsta_s <= '1', '0' after 10 ns;

    clkb_s <= not clkb_s after 5 ns;
    rstb_s <= '1', '0' after 10 ns;


    main : process
        variable reference : bus_reference_t;
        variable reference_queue : queue_t := new_queue;
        variable addr_v  : std_logic_vector(addr_size-1 downto 0);
        variable rdata_v : std_logic_vector(port_size-1 downto 0);
        variable wdata_v : std_logic_vector(port_size-1 downto 0);
    begin
        test_runner_setup(runner, runner_cfg);
        wait until (rsta_s and rstb_s) = '0';
        wait until rising_edge(clka_s);

        if run("Free running simulation") then
            set_timeout(runner, now + 20 us);
            wait for 10 us;
            check_true(true, result("Free running finished."));

        elsif run("Test Single Write") then
            wdata_v := to_std_logic_vector(27,port_size);
            addr_v  := (1 => '1', others=>'0');
            write_bus(net, porta_handle, addr_v, wdata_v);
            check_true(true, result("Single Write finished."));

        elsif run("Test Single Write/Read, All Zeroes") then
            wdata_v := (others=>'0');
            addr_v  := (1 => '1', others=>'0');
            write_bus(net, porta_handle, addr_v, wdata_v);
            read_bus(net, porta_handle, addr_v, rdata_v);
            check_equal(rdata_v, wdata_v, "Test Single Write/Read, All Zeroes");

        elsif run("Test Single Write/Read, All Ones") then
            wdata_v := (others=>'1');
            addr_v  := (1 => '1', others=>'0');
            write_bus(net, porta_handle, addr_v, wdata_v);
            read_bus(net, porta_handle, addr_v, rdata_v);
            check_equal(rdata_v, wdata_v, "Test Single Write/Read, All Ones");

        elsif run("Test Single Write/Read") then
            wdata_v := to_std_logic_vector(27,port_size);
            addr_v  := (1 => '1', others=>'0');
            write_bus(net, porta_handle, addr_v, wdata_v);
            read_bus(net, porta_handle, addr_v, rdata_v);
            check_equal(rdata_v, wdata_v, "Test Single Write/Read");

        elsif run("Test Single Write/ Two Read") then
            wdata_v := to_std_logic_vector(27,port_size);
            addr_v  := (1 => '1', others=>'0');
            write_bus(net, porta_handle, addr_v, wdata_v);
            read_bus(net, porta_handle, addr_v, rdata_v);
            check_equal(rdata_v, wdata_v, "Test Single Write/ First Read");
            read_bus(net, porta_handle, addr_v, rdata_v);
            check_equal(rdata_v, wdata_v, "Test Single Write/ Second Read");

        elsif run("Test Two Write / Single Read") then
            wdata_v := (others=>'1');
            addr_v  := (1 => '1', others=>'0');
            write_bus(net, porta_handle, addr_v, wdata_v);
            wdata_v := (others=>'0');
            addr_v  := (1 => '1', others=>'0');
            write_bus(net, porta_handle, addr_v, wdata_v);
            read_bus(net, porta_handle, addr_v, rdata_v);
            check_equal(rdata_v, wdata_v, "Test Two Write / Single Read");

        elsif run("Test Full Write/Read") then
            for j in 0 to 2**addr_size-1 loop
                wdata_v := to_std_logic_vector(2**addr_size-1-j,port_size);
                addr_v  := to_std_logic_vector(j,addr_size);
                write_bus(net, porta_handle, addr_v, wdata_v);
                read_bus(net, porta_handle, addr_v, rdata_v);
                check_equal(rdata_v, wdata_v, "Test Full Write/Read");
            end loop;

        elsif run("Test Full Write then Full Read") then
            for j in 0 to 2**addr_size-1 loop
                wdata_v := to_std_logic_vector(2**addr_size-1-j,port_size);
                addr_v  := to_std_logic_vector(j,addr_size);
                write_bus(net, porta_handle, addr_v, wdata_v);
            end loop;
            for j in 0 to 2**addr_size-1 loop
                wdata_v := to_std_logic_vector(2**addr_size-1-j,port_size);
                addr_v  := to_std_logic_vector(j,addr_size);
                read_bus(net, porta_handle, addr_v, rdata_v);
                check_equal(rdata_v, wdata_v, "Test Full Write then Full Read");
            end loop;

        elsif run("Test Write Port A / Read Port B, All Zeroes") then
            wdata_v := (others=>'0');
            addr_v  := (1 => '1', others=>'0');
            write_bus(net, porta_handle, addr_v, wdata_v);
            wait for 40 ns;
            read_bus(net, portb_handle, addr_v, rdata_v);
            check_equal(rdata_v, wdata_v, "read data");

        elsif run("Test Write Port A / Read Port B, All Ones") then
            wdata_v := (others=>'1');
            addr_v  := (1 => '1', others=>'0');
            write_bus(net, porta_handle, addr_v, wdata_v);
            wait for 40 ns;
            read_bus(net, portb_handle, addr_v, rdata_v);
            check_equal(rdata_v, wdata_v, "read data");

        elsif run("Test Write Port A / Read Port B") then
            wdata_v := to_std_logic_vector(27,port_size);
            addr_v  := (1 => '1', others=>'0');
            write_bus(net, porta_handle, addr_v, wdata_v);
            wait for 40 ns;
            read_bus(net, portb_handle, addr_v, rdata_v);
            check_equal(rdata_v, wdata_v, "read data");

        elsif run("Test Write Port A / Two Read Port B") then
            wdata_v := to_std_logic_vector(27,port_size);
            addr_v  := (1 => '1', others=>'0');
            write_bus(net, porta_handle, addr_v, wdata_v);
            wait for 40 ns;
            read_bus(net, portb_handle, addr_v, rdata_v);
            check_equal(rdata_v, wdata_v, "read data");
            read_bus(net, portb_handle, addr_v, rdata_v);
            check_equal(rdata_v, wdata_v, "read data");

        end if;

        wait for 100 ns;


        test_runner_cleanup(runner);
    end process;

    test_runner_watchdog(runner, 100 us);

    handler_a_u : entity vunit_lib.ram_master
        generic map (
            bus_handle  => porta_handle,
            latency     => latency
        )
        port map (
            clk   => clka_s,
            en    => ena_s,
            we    => wea_s,
            addr  => addra_s,
            wdata => dataa_i_s,
            rdata => dataa_o_s
        );

    handler_b_u : entity vunit_lib.ram_master
        generic map (
            bus_handle  => portb_handle,
            latency     => latency
        )
        port map (
            clk   => clkb_s,
            en    => enb_s,
            we    => web_s,
            addr  => addrb_s,
            wdata => datab_i_s,
            rdata => datab_o_s
        );

    dut_gen : if entity_sel = "dp_ram" generate
        dut : dp_ram
            generic map(
                mem_size     => addr_size,
                port_size    => port_size,
                ram_type     => "auto",
                fall_through => fall_through
            )
            port map(
                --general
                clka_i   => clka_s,
                rsta_i   => rsta_s,
                clkb_i   => clkb_s,
                rstb_i   => rstb_s,
                addra_i  => addra_s,
                addrb_i  => addrb_s,
                dataa_i  => dataa_i_s,
                dataa_o  => dataa_o_s,
                datab_o  => datab_o_s,
                ena_i    => ena_s,
                enb_i    => enb_s,
                wea_i    => wea_s(0)
            );

    elsif entity_sel = "tdp_ram" generate
        dut : tdp_ram
            generic map(
                mem_size     => addr_size,
                port_size    => port_size,
                ram_type     => "auto",
                fall_through => fall_through
            )
            port map(
                --general
                clka_i   => clka_s,
                rsta_i   => rsta_s,
                clkb_i   => clkb_s,
                rstb_i   => rstb_s,
                addra_i  => addra_s,
                addrb_i  => addrb_s,
                dataa_i  => dataa_i_s,
                dataa_o  => dataa_o_s,
                datab_i  => datab_i_s,
                datab_o  => datab_o_s,
                ena_i    => ena_s,
                enb_i    => enb_s,
                wea_i    => wea_s(0),
                web_i    => web_s(0)
            );

    else generate
        dut : tdp_ram_difport
            generic map(
                mem_size     => addr_size,
                porta_size   => port_size,
                portb_size   => port_size,
                ram_type     => "auto",
                fall_through => fall_through
            )
            port map(
                --general
                clka_i   => clka_s,
                rsta_i   => rsta_s,
                clkb_i   => clkb_s,
                rstb_i   => rstb_s,
                addra_i  => addra_s,
                addrb_i  => addrb_s,
                dataa_i  => dataa_i_s,
                dataa_o  => dataa_o_s,
                datab_i  => datab_i_s,
                datab_o  => datab_o_s,
                ena_i    => ena_s,
                enb_i    => enb_s,
                wea_i    => wea_s(0),
                web_i    => web_s(0)
            );

    end generate;

end architecture;