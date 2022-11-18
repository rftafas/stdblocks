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
--RAM with different aspect ratios. NOTE:
--Try to keep this RAM as small as possible as it is not very efficient.
--a more efficient RAM implementation can be achieved using manufacturer MACROS.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library expert;
    use expert.std_logic_expert.all;


entity tdp_ram_difport is
    generic (
        mem_size        : integer := 8;
        porta_size      : integer := 1;
        portb_size      : integer := 8;
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
        dataa_i  : in  std_logic_vector(porta_size-1 downto 0);
        datab_i  : in  std_logic_vector(portb_size-1 downto 0);
        dataa_o  : out std_logic_vector(porta_size-1 downto 0);
        datab_o  : out std_logic_vector(portb_size-1 downto 0);
        ena_i    : in  std_logic;
        enb_i    : in  std_logic;
        wea_i    : in  std_logic;
        web_i    : in  std_logic
    );
end tdp_ram_difport;

architecture behavioral of tdp_ram_difport is

  constant ram_word         : integer := porta_size*portb_size;
  constant total_ram_size   : integer := ram_word*(2**mem_size);

  shared variable ram_s     : std_logic_vector(total_ram_size-1 downto 0);

  signal dataa_o_s          : std_logic_vector(porta_size - 1 downto 0) := (others=>'0');
  signal datab_o_s          : std_logic_vector(portb_size - 1 downto 0) := (others=>'0');

begin



  process(clka_i)
    variable range_v : range_t;
	begin
		if rising_edge(clka_i) then
			if ena_i = '1' then
                range_v := range_of(to_integer(addra_i),porta_size);
				dataa_o_s <= ram_s(range_v.high downto range_v.low);
				if wea_i = '1' then
					ram_s(range_v.high downto range_v.low) := dataa_i;
				end if;
			end if;
		end if;
	end process;

  process(clkb_i)
    variable range_v : range_t;
	begin
		if rising_edge(clkb_i) then
			if enb_i = '1' then
                range_v := range_of(to_integer(addrb_i),portb_size);
				datab_o_s <= ram_s(range_v.high downto range_v.low);
				if web_i = '1' then
					ram_s(range_v.high downto range_v.low) := datab_i;
				end if;
			end if;
		end if;
	end process;

    fall_through_gen : if fall_through generate
        signal dataa_reg_en : std_logic;
        signal dataa_reg_s  : std_logic_vector(porta_size-1 downto 0);
        signal datab_reg_en : std_logic;
        signal datab_reg_s  : std_logic_vector(portb_size-1 downto 0);
    begin
        fall_through_a_p : process(rsta_i,clka_i)
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

        fall_through_b_p : process(rstb_i,clkb_i)
        begin
            if rstb_i = '1' then
                datab_reg_s  <= (others=>'0');
                datab_reg_en <= '0';
            elsif rising_edge(clkb_i) then
                if enb_i = '1' and web_i = '1' then
                    datab_reg_s <= datab_i;
                    datab_reg_en <= '1';
                else
                    datab_reg_en <= '0';
                end if;
            end if;
        end process;

        datab_o <= datab_reg_s when datab_reg_en = '1' else datab_o_s;

    else generate
        dataa_o <= dataa_o_s;
        datab_o <= datab_o_s;

    end generate;

end behavioral;
