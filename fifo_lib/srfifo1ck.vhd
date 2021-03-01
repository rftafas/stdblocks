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
      fifo_size : integer := 8;
      port_size : integer := 8
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

  constant debug       : boolean := false;
  constant fifo_length : integer := 2**fifo_size;
  constant addr_null   : std_logic_vector(fifo_size-1 downto 0) := (others=>'0');

  signal addro_cnt     : std_logic_vector(fifo_size-1 downto 0) := (others=>'1');

  signal fifo_mq       : fifo_state_t := empty_st;

  type srmem_t is array (fifo_length-1 downto 0) of std_logic_vector(port_size-1 downto 0);
  signal data_sr       : srmem_t := (others=>(others=>'0'));


begin

  --Input
  --data_sr(0) <= dataa_i;
  input_p : process(clk_i)
  begin
    if clk_i'event and clk_i = '1' then
      if ena_i = '1' then
        data_sr <= data_sr(fifo_length-2 downto 0) & dataa_i;
      end if;
    end if;
  end process;

  --output
  output_p : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      addro_cnt <= (others=>'0');
    elsif clk_i'event and clk_i = '1' then
      if ena_i = '1' and enb_i = '0' then
        if fifo_mq  = empty_st then
        elsif addro_cnt < fifo_length then
          addro_cnt <= addro_cnt + 1;
        end if;
      elsif ena_i = '0' and enb_i = '1' then
        if fifo_mq  = empty_st then
        elsif addro_cnt > 0 then
          addro_cnt <= addro_cnt - 1;
        end if;
      end if;
    end if;
  end process;

  datab_o <= data_sr(to_integer(addro_cnt));

  control_p : process(clk_i, rst_i)
    variable addro_v : std_logic_vector(fifo_size-1 downto 0);
  begin
    if rst_i = '1' then
      fifo_mq <= empty_st;
    elsif clk_i'event and clk_i = '1' then
      addro_v := std_logic_vector(addro_cnt) + 1;
      fifo_mq <= sync_state(ena_i,enb_i,addro_v,addr_null,fifo_mq);
    end if;
  end process;

  --Fifo state decode. must be optmized for state machine in the future.
  fifo_status_o.overflow  <= '1' when fifo_mq = overflow_st  else '0';
  fifo_status_o.full      <= '1' when fifo_mq = full_st      else '0';
  fifo_status_o.gofull    <= '1' when fifo_mq = gofull_st    else '0';
  fifo_status_o.steady    <= '1' when fifo_mq = steady_st    else '0';
  fifo_status_o.goempty   <= '1' when fifo_mq = goempty_st   else '0';
  fifo_status_o.empty     <= '1' when fifo_mq = empty_st     else '0';
  fifo_status_o.underflow <= '1' when fifo_mq = underflow_st else '0';

  debug_gen : if debug generate
    signal delta_s : std_logic_vector(addro_cnt'range);
  begin
    delta_s <= std_logic_vector(addro_cnt);
  end generate;

end behavioral;
