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

entity dp_ram is
    generic (
        mem_size        : integer := 8;
        port_size       : integer := 8;
        ram_type        : string  := "auto";
        fall_through    : boolean := false
    );
    port (
        --general
        clka_i   : in  std_logic;
        rsta_i   : in  std_logic;
        clkb_i   : in  std_logic;
        rstb_i   : in  std_logic;
        addra_i  : in  std_logic_vector(mem_size-1 downto 0);
        addrb_i  : in  std_logic_vector(mem_size-1 downto 0);
        dataa_i  : in  std_logic_vector(port_size-1 downto 0);
        dataa_o  : out std_logic_vector(port_size-1 downto 0);
        datab_o  : out std_logic_vector(port_size-1 downto 0);
        ena_i    : in  std_logic;
        enb_i    : in  std_logic;
        wea_i    : in  std_logic
    );
end dp_ram;

architecture behavioral of dp_ram is

    constant  ram_type_c : mem_t := ram_type_dec(ram_type,port_size,mem_size);

    constant ram_size : integer := 2**mem_size;
    type ram_data_t  is array (ram_size-1 downto 0) of std_logic_vector(dataa_i'range);
    signal ram_data_s : ram_data_t := (others=>(others=>'0'));

    signal dataa_o_s   : std_logic_vector(port_size-1 downto 0) := (others=>'0');

begin

    ram_gen : if ram_type_c = blockram generate

        bramin_p : process(clka_i, rsta_i)
        begin
            if rising_edge(clka_i) then
                if ena_i = '1' then
                    if rsta_i = '1' then
                        dataa_o_s <= (others=>'0');
                    else
                        dataa_o_s <= ram_data_s(to_integer(addra_i));
                    end if;
                    if wea_i = '1' then
                        ram_data_s(to_integer(addra_i)) <= dataa_i;
                    end if;
                end if;
            end if;
        end process;

        bramout_p : process(clkb_i)
        begin
            if rising_edge(clkb_i) then
                if enb_i = '1' then
                    if rstb_i = '1' then
                        datab_o <= (others=>'0');
                    else
                        datab_o <= ram_data_s(to_integer(addrb_i));
                    end if;
                end if;
            end if;
        end process;

    elsif ram_type_c = distributed generate

        lutin_p : process(clka_i, rsta_i)
        begin
            if rsta_i = '1' then
                dataa_o_s    <= (others=>'0');
            elsif rising_edge(clka_i) then
                if ena_i = '1' then
                    dataa_o_s <= ram_data_s(to_integer(addra_i));
                    if wea_i = '1' then
                        ram_data_s(to_integer(addra_i)) <= dataa_i;
                    end if;
                end if;
            end if;
        end process;

        lutout_p : process(clkb_i, rstb_i)
        begin
            if rstb_i = '1' then
                datab_o <= (others=>'0');
            elsif rising_edge(clkb_i) then
                if enb_i = '1' then
                    datab_o <= ram_data_s(to_integer(addrb_i));
                end if;
            end if;
        end process;

    else generate --BLOCK

        ffin_p : process(clka_i, rsta_i)
        begin
            if rsta_i = '1' then
                ram_data_s <= (others=>(others=>'0'));
                dataa_o_s    <= (others=>'0');
            elsif rising_edge(clka_i) then
                if ena_i = '1' then
                    dataa_o_s <= ram_data_s(to_integer(addra_i));
                    if wea_i = '1' then
                        ram_data_s(to_integer(addra_i)) <= dataa_i;
                    end if;
                end if;
            end if;
        end process;

        ffout_p : process(clkb_i, rstb_i)
        begin
            if rstb_i = '1' then
                datab_o <= (others=>'0');
            elsif rising_edge(clkb_i) then
                if enb_i = '1' then
                    datab_o <= ram_data_s(to_integer(addrb_i));
                end if;
            end if;
        end process;

    end generate;

    fall_through_gen : if fall_through generate
        signal dataa_reg_en : std_logic;
        signal dataa_reg_s  : std_logic_vector(port_size-1 downto 0);
    begin
        fall_through_p : process(all)
        begin
            if rsta_i = '1' then
                dataa_reg_s  <= (others=>'0');
                dataa_reg_en <= '0';
            elsif rising_edge(clka_i) then
                if ena_i = '1' and wea_i = '1' then
                    dataa_reg_s <= dataa_i;
                    dataa_reg_en <= '1';
                else
                    dataa_reg_en <= '0';
                end if;
            end if;
        end process;

        dataa_o <= dataa_reg_s when dataa_reg_en = '1' else dataa_o_s;

    else generate
        dataa_o <= dataa_o_s;

    end generate;

end behavioral;
