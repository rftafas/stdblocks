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
    use stdblocks.fifo_lib.all;


entity fifo_lib_tb is
end fifo_lib_tb;

architecture behavioral of fifo_lib_tb is

  constant port_size : integer := 8;
  constant fifo_size : integer := 4;
  signal clk_i       : std_logic := '0';
  signal rst_i       : std_logic;
  signal dataa_i     : std_logic_vector(port_size-1 downto 0);
  signal datab_o     : std_logic_vector(port_size-1 downto 0);
  signal ena_i       : std_logic;
  signal enb_i       : std_logic;
  signal oeb_i       : std_logic;
  signal overflow_o  : std_logic;
  signal full_o      : std_logic;
  signal gofull_o    : std_logic;
  signal steady_o    : std_logic;
  signal goempty_o   : std_logic;
  signal empty_o     : std_logic;
  signal underflow_o : std_logic;

begin

  rst_i  <= '1', '0' after 40 ns;
  clk_i <= not clk_i after 10 ns;

  process
  begin
    enb_i   <= '0';
    ena_i   <= '0';
    wait until rst_i = '0';
    wait until rising_edge(clk_i);
    --write
    for j in 16 downto 1 loop
      ena_i   <= '1';
      dataa_i <= to_std_logic_vector(j,dataa_i'length);
      wait until rising_edge(clk_i);
    end loop;
    ena_i   <= '0';
    --read
    for j in 1 to 16 loop
      enb_i   <= '1';
      wait until rising_edge(clk_i);
    end loop;
    enb_i   <= '0';
    wait;
  end process;

  stdfifo1ck_i : stdfifo1ck
    generic map (
      ram_type  => blockram,
      port_size => port_size,
      fifo_size => fifo_size
    )
    port map (
      clk_i       => clk_i,
      rst_i       => rst_i,
      dataa_i     => dataa_i,
      datab_o     => datab_o,
      ena_i       => ena_i,
      enb_i       => enb_i,
      oeb_i       => oeb_i,
      overflow_o  => overflow_o,
      full_o      => full_o,
      gofull_o    => gofull_o,
      steady_o    => steady_o,
      goempty_o   => goempty_o,
      empty_o     => empty_o,
      underflow_o => underflow_o
    );


end behavioral;
