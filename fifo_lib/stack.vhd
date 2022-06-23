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
      ram_type   : fifo_t  := blockram;
      port_size  : integer := 8;
      stack_size : integer := 8
    );
    port (
      --general
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      --STACK WRITE port.
      dataa_i     : in  std_logic_vector(port_size-1 downto 0);
      wen_i       : in  std_logic;
      --STACK READ port
      dataa_o     : out std_logic_vector(port_size-1 downto 0);
      ren_i       : in  std_logic;
      --RAM port
      addrb_i  : in  std_logic_vector(stack_size-1 downto 0);
      datab_o  : out std_logic_vector(port_size-1 downto 0);
      --
      stack_status_o : out fifo_status
    );
end stack;

architecture behavioral of stack is

  constant debug : boolean := false;

  signal addr_cnt : std_logic_vector(stack_size-1 downto 0) := (others=>'0');
  signal stack_mq : fifo_state_t := empty_st;

  signal dataa_i_s : std_logic_vector(port_size-1 downto 0);
  signal ram_data_s : std_logic_vector(port_size-1 downto 0);

  signal wena_en    : std_logic;
  signal regout_sel : std_logic;
  signal up_en      : std_logic;
  signal dn_en      : std_logic;
  signal ffd_en     : std_logic;

  signal regout_en  : std_logic;


begin

    --memory write control
    wena_en    <= wen_i;

    --output register source sel
    regout_sel <= wen_i;
    regout_en  <= wen_i and ren_i;

    --counter control
    up_en  <= wen_i and not ren_i;
    dn_en  <= ren_i and not wen_i;


    addr_p : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            addr_cnt <= (others=>'0');
        elsif clk_i'event and clk_i = '1' then
            if up_en = '1' then
                if addr_cnt /= all_1(stack_size) then
                    addr_cnt <= addr_cnt;
                end if;
            elsif dn_en = '1' then
                if addr_cnt /= 0  then
                    addr_cnt <= addr_cnt - 1;
                end if;
            end if;
        end if;
    end process;

    regout_p : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            dataa_o <= (others=>'0');
        elsif clk_i'event and clk_i = '1' then
            if regout_en = '1' then
                if regout_sel = '1' then
                    dataa_o <= ram_data_s;
                else
                    dataa_o <= dataa_i;
                end if;
            end if;
        end if;
    end process;

    fifo_state_p : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            stack_mq <= empty_st;
        elsif clk_i'event and clk_i = '1' then
            stack_mq <= sync_state(up_en,dn_en,addr_cnt,all_0(stack_size),stack_mq);
        end if;
    end process;

    dp_ram_u : dp_ram
        generic map (
            ram_type  => fifo_type_dec(ram_type),
            mem_size  => stack_size,
            port_size => port_size
        )
        port map (
            clka_i  => clk_i,
            rsta_i  => rst_i,
            clkb_i  => clk_i,
            rstb_i  => rst_i,
            addra_i => addr_cnt,
            dataa_i => dataa_i,
            dataa_o => ram_data_s,
            addrb_i => addrb_i,
            datab_o => datab_o,
            ena_i   => '1',
            wea_i   => wena_en,
            enb_i   => '1'
        );

    stack_status_o <= fifo_status_f(stack_mq);

end behavioral;
