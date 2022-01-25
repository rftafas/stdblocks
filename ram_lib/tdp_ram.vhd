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
-- TDP_RAM, true dual port memory.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library expert;
use expert.std_logic_expert.all;
library stdblocks;
use stdblocks.ram_lib.all;
entity tdp_ram is
    generic (
        mem_size  : integer := 8;
        port_size : integer := 8;
        ram_type  : mem_t   := blockram
    );
    port (
        --general
        clka_i  : in std_logic;
        rsta_i  : in std_logic;
        clkb_i  : in std_logic;
        rstb_i  : in std_logic;
        addra_i : in std_logic_vector(mem_size - 1 downto 0);
        addrb_i : in std_logic_vector(mem_size - 1 downto 0);
        dataa_i : in std_logic_vector(port_size - 1 downto 0);
        datab_i : in std_logic_vector(port_size - 1 downto 0);
        dataa_o : out std_logic_vector(port_size - 1 downto 0);
        datab_o : out std_logic_vector(port_size - 1 downto 0);
        ena_i   : in std_logic;
        enb_i   : in std_logic;
        wea_i   : in std_logic;
        web_i   : in std_logic
    );
end tdp_ram;

architecture behavioral of tdp_ram is

    constant ram_size_c : integer                                                          := 2 ** mem_size;
    signal ram_data_s   : std_logic_array(ram_size_c - 1 downto 0)(port_size - 1 downto 0) := (others => (others => '0'));

    constant ram_string               : string := ram_type_dec(ram_type);
    attribute ram_style of ram_data_s : signal is ram_string;

begin

    process (clka_i)
    begin
        if rising_edge(clka_i) then
            if ena_i = '1' then
                if wea_i = '1' then
                    ram_data_s(to_integer(addra_i)) <= dataa_i;
                end if;
            end if;
        end if;
    end process;

    process (clka_i, rsta_i)
    begin
        if rsta_i = '1' then
            dataa_o <= (others => '0');
        elsif rising_edge(clka_i) then
            if ena_i = '1' then
                dataa_o <= ram_data_s(to_integer(addra_i));
            end if;
        end if;
    end process;

    process (clkb_i)
    begin
        if rising_edge(clkb_i) then
            if enb_i = '1' then
                if web_i = '1' then
                    ram_data_s(to_integer(addrb_i)) <= datab_i;
                end if;
            end if;
        end if;
    end process;

    process (clkb_i, rstb_i)
    begin
        if rstb_i = '1' then
            datab_o <= (others => '0');
        elsif rising_edge(clkb_i) then
            if enb_i = '1' then
                datab_o <= ram_data_s(to_integer(addrb_i));
            end if;
        end if;
    end process;

end behavioral;
