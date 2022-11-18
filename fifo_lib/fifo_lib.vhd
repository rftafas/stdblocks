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

package fifo_lib is

    type fifo_status is record
        overflow  : std_logic;
        full      : std_logic;
        gofull    : std_logic;
        steady    : std_logic;
        goempty   : std_logic;
        empty     : std_logic;
        underflow : std_logic;
    end record fifo_status;

    type fifo_state_t is (
        underflow_st, empty_st, load_output_st, last_data_register_st, goempty_st, steady_st, gofull_st, full_st, overflow_st
    );

    function srfifo_state (
        ien             : std_logic;
        oen             : std_logic;
        addr            : std_logic_vector;
        current_state   : fifo_state_t
    ) return fifo_state_t;

    function stack_state (
        ien             : std_logic;
        oen             : std_logic;
        addr            : std_logic_vector;
        current_state   : fifo_state_t
    ) return fifo_state_t;

    function sync_state (
        ien             : std_logic;
        oen             : std_logic;
        iaddr           : std_logic_vector;
        oaddr           : std_logic_vector;
        current_state   : fifo_state_t
    ) return fifo_state_t;

    procedure async_output_state (
        signal oen      : in    std_logic;
        signal iaddr    : in    gray_vector;
        signal oaddr    : in    gray_vector;
        signal state    : inout fifo_state_t
    );

    procedure async_input_state (
        signal ien      : in    std_logic;
        signal iaddr    : in    gray_vector;
        signal oaddr    : in    gray_vector;
        signal state    : inout fifo_state_t
    );

    function fifo_status_f(mq_input : fifo_state_t) return fifo_status;
    function fifo_status_decoder( delta : in integer; fifo_length : in integer) return fifo_state_t;
    function fifo_op_range_check( delta : in integer; fifo_length : in integer) return boolean;


    component stdfifo2ck
        generic (
            ram_type  : string   := "auto";
            fifo_size : positive := 8;
            port_size : positive := 8
        );
        port (
            clka_i          : in  std_logic;
            rsta_i          : in  std_logic;
            clkb_i          : in  std_logic;
            rstb_i          : in  std_logic;
            dataa_i         : in  std_logic_vector(port_size-1 downto 0);
            datab_o         : out std_logic_vector(port_size-1 downto 0);
            ena_i           : in  std_logic;
            enb_i           : in  std_logic;
            fifo_status_a_o : out fifo_status;
            fifo_status_b_o : out fifo_status
        );
    end component stdfifo2ck;

    component stdfifo1ck
        generic (
            ram_type  : string   := "auto";
            port_size : positive := 8;
            fifo_size : positive := 8
        );
        port (
            clk_i         : in  std_logic;
            rst_i         : in  std_logic;
            dataa_i       : in  std_logic_vector(port_size-1 downto 0);
            datab_o       : out std_logic_vector(port_size-1 downto 0);
            ena_i         : in  std_logic;
            enb_i         : in  std_logic;
            fifo_status_o : out fifo_status
        );
    end component stdfifo1ck;

    component srfifo1ck
        generic (
            fifo_size : positive := 8;
            port_size : positive := 8
        );
        port (
            clk_i         : in  std_logic;
            rst_i         : in  std_logic;
            dataa_i       : in  std_logic_vector(port_size-1 downto 0);
            datab_o       : out std_logic_vector(port_size-1 downto 0);
            ena_i         : in  std_logic;
            enb_i         : in  std_logic;
            fifo_status_o : out fifo_status
        );
    end component srfifo1ck;

    component intfifo1ck is
        generic (
            ram_type  : string   := "auto";
            port_size : positive := 8;
            fifo_size : positive := 8
        );
        port (
            clk_i         : in  std_logic;
            rst_i         : in  std_logic;
            dataa_i       : in  std_logic_vector(port_size-1 downto 0);
            datab_o       : out std_logic_vector(port_size-1 downto 0);
            ena_i         : in  std_logic;
            enb_i         : in  std_logic;
            pointera_i    : in  std_logic_vector(fifo_size-1 downto 0);
            pointera_o    : out std_logic_vector(fifo_size-1 downto 0);
            pointera_en_i : in  std_logic;
            pointerb_i    : in  std_logic_vector(fifo_size-1 downto 0);
            pointerb_o    : out std_logic_vector(fifo_size-1 downto 0);
            pointerb_en_i : in  std_logic;
            fifo_status_o : out fifo_status
        );
    end component;

    component stack is
        generic (
            ram_type   : string   := "auto";
            port_size  : positive := 8;
            stack_size : positive := 8
        );
        port (
            clk_i           : in  std_logic;
            rst_i           : in  std_logic;
            dataa_i         : in  std_logic_vector(port_size-1 downto 0);
            wen_i           : in  std_logic;
            dataa_o         : out std_logic_vector(port_size-1 downto 0);
            ren_i           : in  std_logic;
            addrb_i         : in  std_logic_vector(stack_size-1 downto 0);
            datab_o         : out std_logic_vector(port_size-1 downto 0);
            stack_status_o  : out fifo_status
        );
    end component;

end package;

package body fifo_lib is

    function srfifo_state (
        ien             : std_logic;
        oen             : std_logic;
        addr            : std_logic_vector;
        current_state   : fifo_state_t
    ) return fifo_state_t is
        variable tmp         : fifo_state_t := steady_st;
        variable delta       : integer      := 0;
        variable up          : std_logic    := '0';
        variable dn          : std_logic    := '0';
        variable fifo_length : integer      := 2**addr'length;
    begin
        tmp   := current_state;
        delta := to_integer(addr);
        up    := ien and not oen;
        dn    := oen and not ien;

		case current_state is
            when empty_st =>
                if oen = '1' then
                    tmp := underflow_st;
                elsif up = '1' then
                    tmp:= load_output_st;
                end if;

            when load_output_st =>
                if dn = '1' then
                    tmp:= underflow_st;
                elsif up = '1' then
                    tmp:= goempty_st;
                else
                    tmp:= last_data_register_st;
                end if;

            when last_data_register_st =>
                if up = '1' then
                    tmp:= goempty_st;
                elsif dn = '1' then
                    tmp:= empty_st;
                end if;

            when goempty_st =>
                if delta = 0 and dn  = '1' then
                    tmp := last_data_register_st;
                elsif delta = fifo_length/4 then
                    tmp:= steady_st;
                end if;

            when steady_st =>
                if delta = fifo_length/4-1 then
                    tmp := goempty_st;
                elsif delta = 3*fifo_length/4 then
                    tmp:= gofull_st;
                end if;

            when gofull_st =>
                if delta = fifo_length-2 and up = '1' then
                    tmp:= full_st;
                elsif delta = 3*fifo_length/4-1 then
                    tmp :=  steady_st;
                end if;

            when full_st =>
                if up = '1' then
                    tmp :=  overflow_st;
                elsif dn = '1' then
                    tmp := gofull_st;
                end if;

            when others =>
                tmp := empty_st;

        end case;
        return tmp;
	end srfifo_state;

    function stack_state (
        ien             : std_logic;
        oen             : std_logic;
        addr            : std_logic_vector;
        current_state   : fifo_state_t
    ) return fifo_state_t is
        variable tmp         : fifo_state_t := steady_st;
        variable delta       : unsigned(addr'range) := (others=>'0');
        variable up          : std_logic             := '0';
        variable dn          : std_logic             := '0';
        variable keep        : std_logic             := '0';
        variable fifo_length : integer               := 2**addr'length;
    begin
        tmp   := current_state;
        delta := unsigned(addr);
        up    := ien and not oen;
        dn    := oen and not ien;
        keep  := oen and ien;

		case current_state is
            when empty_st =>
                if oen = '1' then
                    tmp := underflow_st;
                elsif up = '1' then
                    tmp:= goempty_st;
                end if;

            when goempty_st =>
                if delta = 1 and dn  = '1' then
                    tmp := empty_st;
                elsif delta = fifo_length/4+1 then
                    tmp:= steady_st;
                end if;

            when steady_st =>
                if delta = fifo_length/4 then
                    tmp := goempty_st;
                elsif delta = 3*fifo_length/4+1 then
                    tmp:= gofull_st;
                end if;

            when gofull_st =>
                if delta = 0 and up = '1' then
                    tmp:= full_st;
                elsif delta = 3*fifo_length/4 then
                    tmp :=  steady_st;
                end if;

            when full_st =>
                if up = '1' then
                    tmp :=  overflow_st;
                elsif dn = '1' then
                    tmp := gofull_st;
                end if;

            when others =>
                tmp := empty_st;

        end case;
        return tmp;
	end stack_state;

    function sync_state (
        ien : std_logic; oen : std_logic; iaddr : std_logic_vector; oaddr : std_logic_vector; current_state : fifo_state_t
    ) return fifo_state_t is
        variable tmp         : fifo_state_t := steady_st;
        variable delta       : unsigned(iaddr'range) := (others=>'0');
        variable up          : std_logic             := '0';
        variable dn          : std_logic             := '0';
        variable keep        : std_logic             := '0';
        variable fifo_length : integer               := 2**iaddr'length;
    begin
        tmp   := current_state;
        delta := unsigned(iaddr) - unsigned(oaddr);
        up    := ien and not oen;
        dn    := oen and not ien;
        keep  := oen and ien;

		case current_state is
            when empty_st =>
                if oen = '1' then
                    tmp := underflow_st;
                elsif up = '1' then
                    tmp:= load_output_st;
                end if;

            when load_output_st =>
                if dn = '1' then
                    tmp:= underflow_st;
                elsif up = '1' then
                    tmp:= goempty_st;
                else
                    tmp:= last_data_register_st;
                end if;

            when last_data_register_st =>
                if up = '1' then
                    tmp:= goempty_st;
                elsif dn = '1' then
                    tmp:= empty_st;
                elsif keep = '1' then
                    tmp:= last_data_register_st;
                end if;

            when goempty_st =>
                if delta = 1 and dn  = '1' then
                    tmp := last_data_register_st;
                    report(to_string(delta));
                elsif delta = fifo_length/4 then
                    tmp:= steady_st;
                end if;

            when steady_st =>
                if delta = fifo_length/4-1 then
                    tmp := goempty_st;
                elsif delta = 3*fifo_length/4 then
                    tmp:= gofull_st;
                end if;

            when gofull_st =>
                if delta = fifo_length-1 and up = '1' then
                    tmp:= full_st;
                elsif delta = 3*fifo_length/4-1 then
                    tmp :=  steady_st;
                end if;

            when full_st =>
                if up = '1' then
                    tmp :=  overflow_st;
                elsif dn = '1' then
                    tmp := gofull_st;
                end if;

            when others =>
                tmp := empty_st;

        end case;
        return tmp;
	end sync_state;

    procedure async_output_state (
        signal oen       : in std_logic;
        signal iaddr     : in gray_vector;
        signal oaddr     : in gray_vector;
        signal state     : inout fifo_state_t
    ) is
        variable tmp         : fifo_state_t := steady_st;
        variable delta       : integer      := 0;
        variable fifo_length : integer      := 2**(iaddr'length-1);
    begin
        tmp   := state;
        delta := to_integer(iaddr) - to_integer(oaddr);

        case state is
            when underflow_st =>
                if delta = 0 then
                    tmp := empty_st;
                end if;

            when overflow_st =>
                if delta = 0 then
                    tmp := empty_st;
                end if;

            when empty_st =>
                if oen = '1' then
                    tmp := underflow_st;
                elsif delta > 0 or delta < -fifo_length then
                    tmp := load_output_st;
                end if;

            when load_output_st =>
                if oen = '1' then
                    tmp := underflow_st;
                elsif delta = 1 or delta = -2*fifo_length+1 then
                    tmp := last_data_register_st;
                else
                    tmp := fifo_status_decoder(delta,fifo_length);
                end if;

            when last_data_register_st =>
                if oen = '1' then
                    tmp := empty_st;
                elsif delta = 0 or delta = -fifo_length then
                    tmp := last_data_register_st;
                else
                    tmp := fifo_status_decoder(delta,fifo_length);
                end if;

            when goempty_st =>
                if (delta = 1 or delta = -2*fifo_length+1 ) and oen = '1' then
                    tmp := last_data_register_st;
                else
                    tmp := fifo_status_decoder(delta,fifo_length);
                end if;

            when others =>
                tmp := fifo_status_decoder(delta,fifo_length);

        end case;

        state <= tmp;

	end async_output_state;

    procedure async_input_state (
        signal ien       : in std_logic;
        signal iaddr     : in gray_vector;
        signal oaddr     : in gray_vector;
        signal state     : inout fifo_state_t
    ) is
        variable tmp         : fifo_state_t := steady_st;
        variable delta       : integer      := 0;
        variable fifo_length : integer      := 2**(iaddr'length-1);
    begin
        tmp   := state;
        delta := to_integer(iaddr) - to_integer(oaddr);

        case state is
            when underflow_st =>
                if delta = 0 then
                    tmp := empty_st;
                end if;

            when overflow_st =>
                if delta = 0 then
                    tmp := empty_st;
                end if;

            when gofull_st =>
                if (delta = fifo_length-1 or delta = -fifo_length-1) and ien = '1' then
                    tmp := full_st;
                else
                    tmp := fifo_status_decoder(delta,fifo_length);
                end if;

            when full_st =>
                if ien = '1' then
                    tmp := overflow_st;
                else
                    tmp := fifo_status_decoder(delta,fifo_length);
                end if;

            when others =>
                tmp := fifo_status_decoder(delta,fifo_length);

        end case;

        state <= tmp;

	end async_input_state;

    function fifo_status_f(mq_input : fifo_state_t) return fifo_status is
        variable tmp : fifo_status;
    begin
        tmp.overflow  := '0';
        tmp.full      := '0';
        tmp.gofull    := '0';
        tmp.steady    := '0';
        tmp.empty     := '0';
        tmp.underflow := '0';
        tmp.goempty   := '0';
        if mq_input = overflow_st then
            tmp.overflow  := '1';
        elsif mq_input = full_st then
            tmp.full      := '1';
        elsif mq_input = gofull_st then
            tmp.gofull    := '1';
        elsif mq_input = steady_st then
            tmp.steady    := '1';
        elsif mq_input = goempty_st then
            tmp.goempty   := '1';
        elsif mq_input = last_data_register_st then
            tmp.goempty   := '1';
        elsif mq_input = underflow_st then
            tmp.underflow := '1';
        else
            tmp.empty     := '1';
        end if;
        return tmp;
    end fifo_status_f;

    function fifo_status_decoder( delta : in integer; fifo_length : in integer) return fifo_state_t is
    begin
        if delta > fifo_length then
            return overflow_st;
        elsif delta = fifo_length then
            return full_st;
        elsif delta >= 3*fifo_length/4 then
            return gofull_st;
        elsif delta >= fifo_length/4 then
            return steady_st;
        elsif delta > 0 then
            return goempty_st;
        elsif delta = 0 then
            return empty_st;
        elsif delta > -fifo_length then
            return underflow_st;
        elsif delta = -fifo_length then
            return full_st;
        elsif delta >= -5*fifo_length/4 then
            return gofull_st;
        elsif delta >= -7*fifo_length/4 then
            return steady_st;
        elsif delta > -2*fifo_length then
            return goempty_st;
        else
            --fifo should never get to -2*fifo_length as max negative should be -2*fifo_length+1.
            --if, for one awkward reason that happens, it should be treated as delta = 0.
            return empty_st;
        end if;
    end function;

    function fifo_op_range_check( delta : in integer; fifo_length : in integer) return boolean is
    begin
        if delta > fifo_length then
            return false;
        elsif delta < 0 then
            return false;
        else
            return true;
        end if;
    end function;

end package body;
