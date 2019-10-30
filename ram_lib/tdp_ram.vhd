----------------------------------------------------------------------------------
-- SPI-AXI-Master  by Ricardo F Tafas Jr
-- For this IP, CPOL = 0 and CPHA = 0. SPI Master must be configured accordingly.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library expert;
    use expert.std_logic_expert.all;


entity tdp_ram is
    generic (
      ram_type : mem_t := "block"
    );
    port (
      --general
      clka_i   : in  std_logic;
      rsta_i   : in  std_logic;
      clkb_i   : in  std_logic;
      rstb_i   : in  std_logic;
      addra_i  : in  std_logic_vector;
      addrb_i  : in  std_logic_vector;
      dataa_i  : in  std_logic_vector;
      datab_i  : in  std_logic_vector;
      dataa_o  : out std_logic_vector;
      datab_o  : out std_logic_vector;
      ena_i    : in  std_logic;
      enb_i    : in  std_logic;
      oea_i    : in  std_logic;
      oeb_i    : in  std_logic;
      wea_i    : in  std_logic;
      web_i    : in  std_logic
    );
end tdp_ram;

architecture behavioral of tdp_ram is

  constant ram_size : integer := 2**addra_i'length;
  type ram_data_t  is array (ram_size-1 downto 0) of std_logic_vector(dataa_i'range);
  shared variable ram_data_v : ram_data_t(ram_size-1 downto 0) := (others=>(others=>'0'));

  attribute ram_style of ram_data_v : shared variable is ram_type;

begin

  process(clka_i)
  begin
    if rising_edge(clka_i) then
      if ena_i = '1' then
          if wea_i = '1' then
            ram_data_v(to_integer(addra_i) := dataa_i;
          end if;
      end if;
    end if;
  end process;

  process(clka_i, rsta_i)
  begin
    if rsta_i = '1' then
      dataa_o <= (others=>'0');
    elsif rising_edge(clka_i) then
      if ena_i = '1' then
        dataa_o <= ram_data_v(to_integer(addra));
      end if;
    end if;
  end process;

  process(clkb_i)
  begin
    if rising_edge(clkb_i) then
      if enb_i = '1' then
          if web_i = '1' then
            ram_data_v(to_integer(addrb_i) := datab_i;
          end if;
      end if;
    end if;
  end process;

  process(clkb_i, rstb_i)
  begin
    if rstb_i = '1' then
      datab_o <= (others=>'0');
    elsif rising_edge(clkb_i) then
      if enb_i = '1' then
        datab_o <= ram_data_v(to_integer(addrb_i));
      end if;
    end if;
  end process;

end behavioral;
