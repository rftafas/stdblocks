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
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    use IEEE.math_real.all;
library expert;
    use expert.std_logic_expert.all;
    use expert.std_logic_gray.all;
library stdblocks;
    use stdblocks.ram_lib.all;
    use stdblocks.fifo_lib.all;
library vunit_lib;
    context vunit_lib.vunit_context;
    context vunit_lib.com_context;
    context vunit_lib.vc_context;

package fifo_vci_pkg is

    constant read_cmd       : msg_type_t := new_msg_type("read cmd");
    constant reply_cmd      : msg_type_t := new_msg_type("reply cmd");
    constant write_cmd      : msg_type_t := new_msg_type("write cmd");
    constant start_cmd      : msg_type_t := new_msg_type("start cmd");
    constant reset_cmd      : msg_type_t := new_msg_type("start cmd");

    type fifo_vci_t is protected
        procedure write      ( signal net : inout network_t; data : in  std_logic_vector);
        procedure read       ( signal net : inout network_t; data : out std_logic_vector);
        procedure start      ( signal net : inout network_t );
        procedure reset      ( signal net : inout network_t );
        procedure port_a (
            signal net  : inout network_t;
            signal clk  : in    std_logic;
            signal rst  : in    std_logic;
            signal data : out   std_logic_vector;
            signal en   : out   std_logic
        );
        procedure port_b (
            signal net  : inout network_t;
            signal clk  : in    std_logic;
            signal rst  : in    std_logic;
            signal data : in    std_logic_vector;
            signal en   : out   std_logic
        );
    end protected fifo_vci_t;

    procedure fifo_write_signals(
        data_v        : in  std_logic_vector;
        signal clk    : in  std_logic;
        signal en     : out std_logic;
        signal data_s : out std_logic_vector
    );

    procedure fifo_read_signals (
        data_v        : out std_logic_vector;
        signal clk    : in  std_logic;
        signal en     : out std_logic;
        signal data_s : in  std_logic_vector
    );

    procedure wait_for ( constant period : time );

end package;

package body fifo_vci_pkg is

    type fifo_vci_t is protected body
        constant porta_actor     : actor_t := new_actor("port a actor");
        constant portb_actor     : actor_t := new_actor("port b actor");
        variable write_data_reg  : std_logic_vector(2047 downto 0); --2048 bits should be enough...
        variable read_data_reg   : std_logic_vector(2047 downto 0);

        procedure write ( signal net : inout network_t; data : in std_logic_vector ) is
            variable cmd_msg   : msg_t := new_msg(write_cmd);
            variable reply_msg : msg_t := new_msg(reply_cmd);
        begin
            push(cmd_msg, data);
            send(net, porta_actor, cmd_msg);
            receive_reply(net, cmd_msg, reply_msg);
        end write;

        procedure read (signal net : inout network_t; data : out std_logic_vector ) is
            variable cmd_msg   : msg_t := new_msg(read_cmd);
            variable reply_msg : msg_t := new_msg(reply_cmd);
        begin
            send(net, portb_actor, cmd_msg);
            receive_reply(net, cmd_msg, reply_msg);
            data := pop(reply_msg);
        end read;

        procedure start(signal net : inout network_t) is
            variable cmd_msg : msg_t := new_msg(start_cmd);
        begin
            send(net, porta_actor, cmd_msg);
            cmd_msg := new_msg(start_cmd);
            send(net, portb_actor, cmd_msg);
        end start;

        procedure reset(signal net : inout network_t) is
            variable cmd_msg : msg_t := new_msg(reset_cmd);
        begin
            send(net, porta_actor, cmd_msg);
            cmd_msg := new_msg(reset_cmd);
            send(net, portb_actor, cmd_msg);
        end reset;

        procedure port_a (
            signal net  : inout network_t;
            signal clk  : in    std_logic;
            signal rst  : in    std_logic;
            signal data : out   std_logic_vector;
            signal en   : out   std_logic
        ) is
            variable request_msg  : msg_t;
            variable reply_msg    : msg_t := new_msg(reply_cmd);
            variable msg_type     : msg_type_t;
            variable status       : com_status_t;
        begin
            en <= '0';
            wait_for_message(net, porta_actor, status, timeout => 500 us);
            receive(net, porta_actor, request_msg);
            msg_type := message_type(request_msg);
            if msg_type = reset_cmd then
                info("FIFO VCI: reset, port a.");
            elsif msg_type = start_cmd then
                info("FIFO VCI: started.");
                check_equal(rst,'0',result("FIFO VCI: cannot start with Reset on PortA Active or Undefined."));
            elsif msg_type = write_cmd then
                fifo_write_signals(pop(request_msg),clk,en,data);
                reply(net, request_msg, reply_msg);
            end if;
        end port_a;

        procedure port_b (
            signal net  : inout network_t;
            signal clk  : in    std_logic;
            signal rst  : in    std_logic;
            signal data : in    std_logic_vector;
            signal en   : out   std_logic
        ) is
            variable request_msg  : msg_t;
            variable reply_msg    : msg_t := new_msg(reply_cmd);
            variable msg_type     : msg_type_t;
            variable data_v       : std_logic_vector(data'range);
            variable status       : com_status_t;
        begin
            en <= '0';
            wait_for_message(net, portb_actor, status, timeout => 500 us);
            receive(net, portb_actor, request_msg);
            msg_type := message_type(request_msg);
            if msg_type = reset_cmd then
                info("FIFO VCI: reset, port b.");
            elsif msg_type = start_cmd then
                info("FIFO VCI: started, port b.");
                check_equal(rst,'0',result("FIFO VCI: cannot start with Reset on PortB Active or Undefined."));
            elsif msg_type = read_cmd then
                fifo_read_signals(data_v,clk,en,data);
                push(reply_msg,data_v);
                reply(net, request_msg, reply_msg);
                wait_for(2 ps);
            end if;
        end port_b;

    end protected body fifo_vci_t;

    procedure fifo_write_signals(
        data_v        : in  std_logic_vector;
        signal clk    : in  std_logic;
        signal en     : out std_logic;
        signal data_s : out std_logic_vector
    ) is
    begin
        en     <= '1';
        data_s <= data_v;
        wait until rising_edge(clk);
        wait for 1 ps;
    end procedure;

    procedure fifo_read_signals (
        data_v        : out std_logic_vector;
        signal clk    : in  std_logic;
        signal en     : out std_logic;
        signal data_s : in  std_logic_vector
    ) is
    begin
        wait for 1 ps;
        en <= '1';
        wait until rising_edge(clk);
        data_v := data_s;
        wait for 1 ps;
    end procedure;

    procedure wait_for ( constant period : time ) is
    begin
      wait for period;
    end procedure;

end package body;
