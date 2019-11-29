----------------------------------------------------------------------------------
-- SPI-AXI-Master  by Ricardo F Tafas Jr
-- For this IP, CPOL = 0 and CPHA = 0. SPI Master must be configured accordingly.
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
      mem_size  : integer := 8;
      port_size : integer := 8;
      ram_type  : mem_t   := blockram
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
      oeb_i    : in  std_logic;
      wea_i    : in  std_logic
    );
end dp_ram;

architecture behavioral of dp_ram is

  constant ram_size : integer := 2**mem_size;
  type ram_data_t  is array (ram_size-1 downto 0) of std_logic_vector(dataa_i'range);
  signal ram_data_s : ram_data_t(ram_size-1 downto 0) := (others=>(others=>'0'));

  constant ram_string : string := ram_type_dec(ram_type); 
  attribute ram_style of ram_data_s : signal is ram_string;

begin

  ram_gen : if ram_type = registers generate

    ffin_p : process(clka_i, rsta_i)
    begin
      if rsta_i = '1' then
        ram_data_s <= (others=>(others=>'0'));
        dataa_o    <= (others=>'0');
      elsif rising_edge(clka_i) then
        if ena_i = '1' then
          dataa_o <= ram_data_s(to_integer(addra_i));
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
          if oeb_i = '1' then
            datab_o <= ram_data_s(to_integer(addrb_i));
          end if;
        end if;
      end if;
    end process;

  elsif ram_type = ultra generate

    ultraram_u : tdp_ram
      generic map(
        mem_size  => mem_size,
        port_size => port_size,
        ram_type  => ram_type
      )
      port map (
        clka_i  => clka_i,
        rsta_i  => rsta_i,
        clkb_i  => clka_i,
        rstb_i  => rsta_i,
        addra_i => addra_i,
        addrb_i => addrb_i,
        dataa_i => dataa_i,
        datab_i => (dataa_i'range => '0'),
        dataa_o => open,
        datab_o => datab_o,
        ena_i   => ena_i,
        enb_i   => enb_i,
        oea_i   => '0',
        oeb_i   => oeb_i,
        wea_i   => wea_i,
        web_i   => '0'
      );

    assert true
      report "Ultra RAM only uses CLKA and RSTA. Ignoring CLKB and RSTB."
      severity note;

    assert not clkb_i'event
      report "Detected clock activity on port clock B. UltraRAM only uses clock from port A."
      severity failure;

  elsif ram_type = distributed generate

    ffin_p : process(clka_i, rsta_i)
    begin
      if rsta_i = '1' then
        dataa_o    <= (others=>'0');
      elsif rising_edge(clka_i) then
        if ena_i = '1' then
          dataa_o <= ram_data_s(to_integer(addra_i));
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
          if oeb_i = '1' then
            datab_o <= ram_data_s(to_integer(addrb_i));
          end if;
        end if;
      end if;
    end process;

  else generate --BLOCK

    blockram_u : tdp_ram
      generic map(
        mem_size  => mem_size,
        port_size => port_size,
        ram_type  => ram_type
      )
      port map (
        clka_i  => clka_i,
        rsta_i  => rsta_i,
        clkb_i  => clkb_i,
        rstb_i  => rstb_i,
        addra_i => addra_i,
        addrb_i => addrb_i,
        dataa_i => dataa_i,
        datab_i => (dataa_i'range => '0'),
        dataa_o => dataa_o,
        datab_o => datab_o,
        ena_i   => ena_i,
        enb_i   => enb_i,
        oea_i   => '0',
        oeb_i   => oeb_i,
        wea_i   => wea_i,
        web_i   => '0'
      );

  end generate;
 

end behavioral;
