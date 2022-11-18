----------------------------------------------------------------------------------
--Copyright 2021 Ricardo F Tafas Jr

--Licensed under the Apache License, Version 2.0 (the "License"); you may not
--use this file except in compliance with the License. You may obtain a copy of
--the License at

--   http://www.apache.org/licenses/LICENSE-2.0

--Unless required by applicable law or agreed to in writing, software distributed
--under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
--OR CONDITIONS OF ANY KIND, either express or implied. See the License for
--the specific language governing permissions and limitations under the License.
----------------------------------------------------------------------------------
-- This block puts on DATAB_O the last sampled value of DATAA_I.
-- IF wen = ren = 1, it works like a FFD.
-- If wen = 1 and REN = 0, then it starts to store values.
-- IF ren = 1 and WEN = 0, it starts to readback until empty.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library expert;
    use expert.std_logic_expert.all;
library stdblocks;
    use stdblocks.ram_lib.all;
library stdblocks;
    use stdblocks.fifo_lib.all;

entity stack is
    generic (
        ram_type   : string   := "auto";
        stack_size : positive := 8;
        port_size  : positive := 8
    );
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      dataa_i     : in  std_logic_vector(port_size-1 downto 0);
      wen_i       : in  std_logic;
      dataa_o     : out std_logic_vector(port_size-1 downto 0);
      ren_i       : in  std_logic;
      --
      stack_status_o : out fifo_status
    );
end stack;

architecture behavioral of stack is

    signal data_cnt   : std_logic_vector(stack_size-1 downto 0);

    signal up_en      : std_logic;
    signal dn_en      : std_logic;
    signal read_en    : std_logic;
    signal write_en   : std_logic;

    signal stack_mq   : fifo_state_t := empty_st;


begin

    assert stack_size >= 4
    report "Stack Size must be greater than 8."
    severity failure;

    --memory write control
    up_en   <=  '1' when wen_i = '1' and ren_i = '0' else '0';
    dn_en   <=  '1' when wen_i = '0' and ren_i = '1' else '0';

    read_en  <= wen_i and ren_i;
    write_en <= wen_i;

    --counter control
    data_cnt_p : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            data_cnt <= (others=>'0');
        elsif clk_i'event and clk_i = '1' then
            if stack_mq = overflow_st or stack_mq = underflow_st then
                data_cnt <= (others=>'0');
            elsif up_en = '1' then
                data_cnt <= data_cnt + 1;
            elsif dn_en = '1' then
                data_cnt <= data_cnt - 1;
            end if;
        end if;
    end process;

    control_p : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            stack_mq <= empty_st;
        elsif clk_i'event and clk_i = '1' then
            stack_mq <= stack_state(wen_i,ren_i,data_cnt,stack_mq);
        end if;
    end process;
    stack_status_o <= fifo_status_f(stack_mq);

    ram_u : dp_ram
        generic map (
            mem_size        => stack_size,
            port_size       => port_size,
            ram_type        => ram_type,
            fall_through    => true
        )
        port map (
            --general
            clka_i   => clk_i,
            rsta_i   => rst_i,
            clkb_i   => clk_i,
            rstb_i   => rst_i,
            addra_i  => data_cnt,
            addrb_i  => all_0(stack_size),
            dataa_i  => dataa_i,
            dataa_o  => dataa_o,
            datab_o  => open,
            ena_i    => read_en,
            enb_i    => '0',
            wea_i    => write_en
        );

end behavioral;
