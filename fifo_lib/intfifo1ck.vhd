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
--
-- This fifo has absolutely no control. All controls to it should be performed by
-- the digital machine using it.
--
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
        ram_type  : string   := "block";
        fifo_size : positive := 8;
        port_size : positive := 8
    );
    port (
        --general
        clk_i         : in  std_logic;
        rst_i         : in  std_logic;
        dataa_i       : in  std_logic_vector(port_size-1 downto 0);
        datab_o       : out std_logic_vector(port_size-1 downto 0);
        ena_i         : in  std_logic;
        enb_i         : in  std_logic;
        pointera_o    : out std_logic_vector(fifo_size-1 downto 0);
        pointerb_o    : out std_logic_vector(fifo_size-1 downto 0)
    );
end intfifo1ck;

architecture behavioral of intfifo1ck is

    signal addri_cnt     : std_logic_vector(fifo_size-1 downto 0);
    signal addro_cnt     : std_logic_vector(fifo_size-1 downto 0);

begin

    --Input
    input_p : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            addri_cnt <= (others=>'0');
        elsif clk_i'event and clk_i = '1' then
            if ena_i = '1' then
                addri_cnt <= addri_cnt + 1;
            end if;
        end if;
    end process;
    pointera_o <= addri_cnt;

    output_p : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            addro_cnt <= (others=>'0');
        elsif clk_i'event and clk_i = '1' then
            if enb_i = '1' then
                addro_cnt <= addro_cnt + 1;
            end if;
        end if;
    end process;
    pointerb_o <= addro_cnt;

    dp_ram_u : dp_ram
        generic map (
            ram_type  => ram_type,
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
        wea_i   => ena_i,
        enb_i   => '1'
    );

end behavioral;
