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
library stdblocks;
  use stdblocks.ram_lib.all;
  use stdblocks.fifo_lib.all;

entity srfifo1ck is
    generic (
      fifo_size : positive := 8;
      port_size : positive := 8
    );
    port (
      --general
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      dataa_i     : in  std_logic_vector(port_size-1 downto 0);
      datab_o     : out std_logic_vector(port_size-1 downto 0);
      ena_i       : in  std_logic;
      enb_i       : in  std_logic;
      --
      fifo_status_o : out fifo_status
    );
end srfifo1ck;

architecture behavioral of srfifo1ck is

    constant fifo_length : integer := 2**fifo_size;
    constant addr_null   : std_logic_vector(fifo_size-1 downto 0) := (others=>'0');

    signal addro_cnt     : std_logic_vector(fifo_size-1 downto 0) := (others=>'0');

    signal fifo_mq       : fifo_state_t := empty_st;

    type srmem_t is array (fifo_length-1 downto 0) of std_logic_vector(port_size-1 downto 0);
    signal data_sr       : srmem_t := (others=>(others=>'0'));

    signal up_en        : std_logic;
    signal down_en      : std_logic;
    signal sr_wr_en     : std_logic;
    signal data_oe_en   : std_logic;

begin

    assert fifo_size >= 2
    report "Fifo Size must be greater than 2."
    severity failure;

    --Input
    up_en       <=  '0'   when fifo_mq = empty_st              else
                    '0'   when fifo_mq = full_st               else
                    '0'   when fifo_mq = load_output_st        else
                    '0'   when fifo_mq = last_data_register_st else
                    '1'   when ena_i = '1' and enb_i = '0'     else
                    '0';

    sr_wr_en    <=  ena_i;

    input_p : process(clk_i)
    begin
        if clk_i'event and clk_i = '1' then
            if sr_wr_en = '1' then
                --data_sr(fifo_length downto 1) <= data_sr(fifo_length-1 downto 0);
                data_sr(fifo_length-1 downto 0) <= data_sr(fifo_length-2 downto 0) & dataa_i;
            end if;
        end if;
    end process;

    down_en     <=  '0' when fifo_mq = empty_st              else
                    '0' when fifo_mq = load_output_st        else
                    '0' when fifo_mq = last_data_register_st else
                    '1' when ena_i = '0' and enb_i = '1'     else
                    '0';

    data_oe_en  <=  '1' when fifo_mq = load_output_st else
                    enb_i;

    --output
    output_p : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            addro_cnt <= (others=>'0');
            datab_o   <= (others=>'U');
        elsif clk_i'event and clk_i = '1' then
            if fifo_mq = underflow_st or fifo_mq = overflow_st then
                addro_cnt <= (others=>'0');
            elsif up_en = '1' then
                if addro_cnt < fifo_length-1 then
                    addro_cnt <= addro_cnt + 1;
                end if;
            elsif down_en = '1' then
                if  addro_cnt > 0 then
                    addro_cnt <= addro_cnt - 1;
                end if;
            end if;
            if data_oe_en = '1' then
                datab_o <= data_sr(to_integer(addro_cnt));
            end if;
        end if;
    end process;

    control_p : process(clk_i, rst_i)
        variable addro_v : std_logic_vector(fifo_size-1 downto 0);
    begin
        if rst_i = '1' then
            fifo_mq <= empty_st;
        elsif clk_i'event and clk_i = '1' then
            fifo_mq <= srfifo_state(ena_i,enb_i,addro_cnt,fifo_mq);
        end if;
    end process;

    --Fifo state decode. must be optmized for state machine in the future.
    fifo_status_o  <= fifo_status_f(fifo_mq);

end behavioral;
