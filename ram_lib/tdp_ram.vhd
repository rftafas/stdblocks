----------------------------------------------------------------------------------
-- ram_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
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
      ram_type  : mem_t := blockram
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
      datab_i  : in  std_logic_vector(port_size-1 downto 0);
      dataa_o  : out std_logic_vector(port_size-1 downto 0);
      datab_o  : out std_logic_vector(port_size-1 downto 0);
      ena_i    : in  std_logic;
      enb_i    : in  std_logic;
      wea_i    : in  std_logic;
      web_i    : in  std_logic
    );
end tdp_ram;

architecture behavioral of tdp_ram is

  constant ram_size_c : integer := 2**mem_size;
  type ram_data_t  is array (ram_size_c-1 downto 0) of std_logic_vector(port_size-1 downto 0);
  shared variable ram_data_v : ram_data_t := (others=>(others=>'0'));

  constant ram_string : string := ram_type_dec(ram_type);
  attribute ram_style of ram_data_v : variable is ram_string;

begin

  process(clka_i)
  begin
    if rising_edge(clka_i) then
      if ena_i = '1' then
          if wea_i = '1' then
            ram_data_v(to_integer(addra_i)) := dataa_i;
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
        dataa_o <= ram_data_v(to_integer(addra_i));
      end if;
    end if;
  end process;

  process(clkb_i)
  begin
    if rising_edge(clkb_i) then
      if enb_i = '1' then
          if web_i = '1' then
            ram_data_v(to_integer(addrb_i)) := datab_i;
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
