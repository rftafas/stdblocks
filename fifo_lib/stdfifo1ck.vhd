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
library stdblocks;
    use stdblocks.fifo_lib.all;

entity stdfifo1ck is
    generic (
      ram_type  : fifo_t   := blockram;
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
end stdfifo1ck;

architecture behavioral of stdfifo1ck is

  signal addri_cnt    : std_logic_vector(fifo_size-1 downto 0) := (others=>'0');
  signal addro_cnt    : std_logic_vector(fifo_size-1 downto 0) := (others=>'0');
  signal fifo_mq      : fifo_state_t := empty_st;

  signal addri_cnt_en : std_logic;
  signal ram_wr_en    : std_logic;
  signal addro_cnt_en : std_logic;
  signal ram_oe_en    : std_logic;

begin

    assert fifo_size >= 4
    report "Fifo Size must be greater than 4."
    severity failure;


    --Input
    addri_cnt_en  <=    ena_i;
    ram_wr_en     <=    ena_i;

    input_p : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            addri_cnt <= (others=>'0');
        elsif clk_i'event and clk_i = '1' then
            if fifo_mq = overflow_st or fifo_mq = underflow_st then
                addri_cnt     <= (others=>'0');
            elsif addri_cnt_en = '1' then
                addri_cnt    <= addri_cnt + 1;
            end if;
        end if;
    end process;

  --output
    addro_cnt_en    <=  '1'     when fifo_mq = load_output_st    else
                        enb_i;

    ram_oe_en     <=    '1'     when fifo_mq = load_output_st    else
                        enb_i;

    output_p : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            addro_cnt <= (others=>'0');
        elsif clk_i'event and clk_i = '1' then
            if fifo_mq = overflow_st or fifo_mq = underflow_st then
                addro_cnt <= (others=>'0');
            elsif addro_cnt_en = '1' then
                addro_cnt <= addro_cnt + 1;
            end if;
        end if;
    end process;

  control_p : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      fifo_mq <= empty_st;
    elsif clk_i'event and clk_i = '1' then
      fifo_mq <= sync_state(ena_i,enb_i,addri_cnt,addro_cnt,fifo_mq);
    end if;
  end process;


  dp_ram_u : dp_ram
    generic map (
      ram_type  => fifo_type_dec(ram_type),
      mem_size  => fifo_size,
      port_size => port_size
    )
    port map (
      clka_i  => clk_i,
      rsta_i  => rst_i,
      clkb_i  => clk_i,
      rstb_i  => rst_i,
      addra_i => addri_cnt,
      dataa_i => dataa_i,
      addrb_i => addro_cnt,
      datab_o => datab_o,
      ena_i   => '1',
      wea_i   => ram_wr_en,
      enb_i   => ram_oe_en
    );

  fifo_status_o  <= fifo_status_f(fifo_mq);

end behavioral;
