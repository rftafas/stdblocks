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

entity intfifo1ck is
    generic (
      ram_type  : fifo_t := blockram;
      port_size : integer := 8;
      fifo_size : integer := 8
    );
    port (
      --general
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
end intfifo1ck;

architecture behavioral of intfifo1ck is

  constant debug   : boolean := false;

  signal addri_cnt     : std_logic_vector(fifo_size-1 downto 0);
  signal addro_cnt     : std_logic_vector(fifo_size-1 downto 0);
  signal fifo_mq      : fifo_state_t := empty_st;

  signal ena_i_s       : std_logic;
  signal enb_i_s       : std_logic;

begin

  --Input
  ena_i_s <= '0' when fifo_mq = full_st     else
             '0' when fifo_mq = overflow_st else
             ena_i;

  input_p : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      addri_cnt <= (others=>'0');
    elsif clk_i'event and clk_i = '1' then
      if pointera_en_i = '1' then
        addri_cnt <= pointera_i;
      elsif ena_i_s = '1' then
        addri_cnt <= addri_cnt + 1;
      end if;
    end if;
  end process;
  pointera_o <= addri_cnt;

  --output
  enb_i_s <= '0'   when fifo_mq = underflow_st else
             '1'   when fifo_mq = f_empty_st   else
             '0'   when fifo_mq = t_empty_st   else
             '0'   when fifo_mq = empty_st     else
             enb_i;

  output_p : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      addro_cnt <= (others=>'0');
    elsif clk_i'event and clk_i = '1' then
      if pointerb_en_i = '1' then
        addro_cnt <= pointerb_i;
      elsif enb_i_s = '1' then
        addro_cnt <= addro_cnt + 1;
      end if;
    end if;
  end process;
  pointerb_o <= addro_cnt;

  control_p : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      fifo_mq <= empty_st;
    elsif clk_i'event and clk_i = '1' then
      fifo_mq <= async_state(ena_i,enb_i,addri_cnt,addro_cnt,fifo_mq);
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
      wea_i   => ena_i_s,
      enb_i   => enb_i_s
    );

  fifo_status_o  <= fifo_status_f(fifo_mq);

  debug_gen : if debug generate
    signal delta_s : std_logic_vector(addri_cnt'range);
  begin
    delta_s <= addri_cnt - addro_cnt;
  end generate;


end behavioral;
