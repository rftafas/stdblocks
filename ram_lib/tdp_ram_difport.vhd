----------------------------------------------------------------------------------
-- SPI-AXI-Master  by Ricardo F Tafas Jr
-- For this IP, CPOL = 0 and CPHA = 0. SPI Master must be configured accordingly.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library expert;
    use expert.std_logic_expert.all;


entity tdp_ram_difport is
    generic (
      --ram_type   : mem_t   := "block"
      ram_size   : integer := 1;
      porta_size : integer := 1;
      portb_size : integer := 8
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

  constant ram_word : integer := porta_size*portb_size;

  constant min_port_size : integer := min(porta_size, portb_size);
	constant max_port_size : integer := max(porta_size, portb_size);
	constant ram_size      : integer := min_port_size;
	constant ram_ratio     : integer := max_port_size / min_port_size;

	-- An asymmetric RAM is modeled in a similar way as a symmetric RAM, with an
	-- array of array object. Its aspect ratio corresponds to the port with the
	-- lower data width (larger depth)
	type ramType is array (0 to maxSIZE - 1) of std_logic_vector(minWIDTH - 1 downto 0);

	signal my_ram : ramType := (others => (others => '0'));

	signal readA : std_logic_vector(WIDTHA - 1 downto 0) := (others => '0');
	signal readB : std_logic_vector(WIDTHB - 1 downto 0) := (others => '0');
	signal regA  : std_logic_vector(WIDTHA - 1 downto 0) := (others => '0');
	signal regB  : std_logic_vector(WIDTHB - 1 downto 0) := (others => '0');

begin

  process(clkA)
	begin
		if rising_edge(clkA) then
			if enA = '1' then
				readA <= my_ram(conv_integer(addrA));
				if weA = '1' then
					my_ram(conv_integer(addrA)) <= diA;
				end if;
			end if;
			regA <= readA;
		end if;
	end process;

	process(clkB)
	begin
		if rising_edge(clkB) then
			for i in 0 to RATIO - 1 loop
				if enB = '1' then
					readB((i + 1) * minWIDTH - 1 downto i * minWIDTH) <= my_ram(conv_integer(addrB & conv_std_logic_vector(i, log2(RATIO))));
					if weB = '1' then
						my_ram(conv_integer(addrB & conv_std_logic_vector(i, log2(RATIO)))) <= diB((i + 1) * minWIDTH - 1 downto i * minWIDTH);
					end if;
				end if;
			end loop;
			regB <= readB;
		end if;
	end process;

end behavioral;
