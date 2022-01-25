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
      --ram_type   : mem_t   := "block"
      porta_size : integer := 1;
      portb_size : integer := 8;
      ram_size   : integer := 1
    );
    port (
      --general
      clka_i   : in  std_logic;
      rsta_i   : in  std_logic;
      clkb_i   : in  std_logic;
      rstb_i   : in  std_logic;
      addra_i  : in  std_logic_vector(10 downto 0);
      addrb_i  : in  std_logic_vector(10 downto 0);
      dataa_i  : in  std_logic_vector(porta_size-1 downto 0);
      datab_i  : in  std_logic_vector(portb_size-1 downto 0);
      dataa_o  : out std_logic_vector(porta_size-1 downto 0);
      datab_o  : out std_logic_vector(portb_size-1 downto 0);
      ena_i    : in  std_logic;
      enb_i    : in  std_logic;
      oea_i    : in  std_logic;
      oeb_i    : in  std_logic;
      wea_i    : in  std_logic;
      web_i    : in  std_logic
    );
end tdp_ram_difport;

architecture behavioral of tdp_ram_difport is

  constant ram_word       : integer := porta_size*portb_size;
  constant total_ram_size : integer := ram_word*ram_size;

  signal ram_s : std_logic_vector(total_ram_size-1 downto 0);


begin

  process(clka_i)
    variable range_v : range_t;
	begin
		if rising_edge(clka_i) then
			if ena_i = '1' then
        range_v := range_of(to_integer(addra_i),porta_size);
				dataa_o <= ram_s(range_v.high downto range_v.low);
				if wea_i = '1' then
					ram_s(range_v.high downto range_v.low) <= dataa_i;
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
				datab_o <= ram_s(range_v.high downto range_v.low);
				if wea_i = '1' then
					ram_s(range_v.high downto range_v.low) <= datab_i;
				end if;
			end if;
		end if;
	end process;

end behavioral;
