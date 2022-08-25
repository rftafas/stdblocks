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
    use expert.std_logic_gray.all;
library stdblocks;
    use stdblocks.sync_lib.all;
    use stdblocks.ram_lib.all;
    use stdblocks.fifo_lib.all;

entity stdfifo2ck is
    generic (
        ram_type  : fifo_t   := blockram;
        fifo_size : positive := 8;
        port_size : positive := 8
    );
    port (
        --general
        clka_i       : in  std_logic;
        rsta_i       : in  std_logic;
        clkb_i       : in  std_logic;
        rstb_i       : in  std_logic;
        dataa_i      : in  std_logic_vector(port_size-1 downto 0);
        datab_o      : out std_logic_vector(port_size-1 downto 0);
        ena_i        : in  std_logic;
        enb_i        : in  std_logic;

        fifo_status_a_o : out fifo_status;
        fifo_status_b_o : out fifo_status
    );
end stdfifo2ck;

architecture behavioral of stdfifo2ck is

    signal input_fifo_mq    : fifo_state_t := steady_st;
    signal output_fifo_mq   : fifo_state_t := steady_st;

    signal addri_cnt        : gray_vector(fifo_size downto 0);
    signal addro_cnt        : gray_vector(fifo_size downto 0);
    signal addri_s          : std_logic_vector(fifo_size downto 0);
    signal addro_s          : std_logic_vector(fifo_size downto 0);

    signal addri_cnt_en     : std_logic;
    signal ram_wr_en        : std_logic;
    signal addro_cnt_en     : std_logic;
    signal ram_oe_en        : std_logic;

begin
    assert fifo_size >= 4
    report "Fifo Size must be greater than 4."
    severity failure;

    --Input
    addri_cnt_en  <=    ena_i;
    ram_wr_en     <=    ena_i;

    input_p : process(clka_i, rsta_i)
    begin
        if rsta_i = '1' then
            addri_cnt     <= (others=>'0');
            input_fifo_mq <= empty_st;
        elsif clka_i'event and clka_i = '1' then
            if input_fifo_mq = overflow_st or input_fifo_mq = underflow_st then
                addri_cnt     <= (others=>'0');
            elsif addri_cnt_en = '1' then
                addri_cnt <= addri_cnt + 1;
            end if;
            async_input_state(ena_i,addri_cnt,addro_cnt,input_fifo_mq);
        end if;
    end process;

    output_p : process(clkb_i, rstb_i)
    begin
        if rstb_i = '1' then
            addro_cnt      <= (others=>'0');
            output_fifo_mq <= empty_st;
        elsif clkb_i'event and clkb_i = '1' then
            if output_fifo_mq = overflow_st or output_fifo_mq = underflow_st then
                addro_cnt     <= (others=>'0');
            elsif addro_cnt_en = '1' then
                addro_cnt    <= addro_cnt + 1;
            end if;
            async_output_state(enb_i,addri_cnt,addro_cnt,output_fifo_mq);
        end if;
    end process;

    ram_oe_en       <=  '1'     when output_fifo_mq = load_output_st   else
                        --'1'     when output_fifo_mq = load_output_st   else
                        enb_i;

    addro_cnt_en    <=  '1'     when output_fifo_mq = load_output_st   else
                        '0'     when output_fifo_mq = last_data_register_st   else
                        enb_i;

    addri_s <= to_std_logic_vector(addri_cnt);
    addro_s <= to_std_logic_vector(addro_cnt);

    dp_ram_i : dp_ram
        generic map (
            ram_type  => fifo_type_dec(ram_type),
            mem_size  => fifo_size,
            port_size => port_size
        )
        port map (
            clka_i  => clka_i,
            rsta_i  => rsta_i,
            clkb_i  => clkb_i,
            rstb_i  => rstb_i,
            addra_i => addri_s(fifo_size-1 downto 0),
            dataa_i => dataa_i,
            addrb_i => addro_s(fifo_size-1 downto 0),
            datab_o => datab_o,
            ena_i   => '1',
            wea_i   => ram_wr_en,
            enb_i   => ram_oe_en
        );

    fifo_status_a_o <= fifo_status_f(input_fifo_mq);
    fifo_status_b_o <= fifo_status_f(output_fifo_mq);

end behavioral;
