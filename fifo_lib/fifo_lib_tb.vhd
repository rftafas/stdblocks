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

  constant port_size  : integer := 8;
  constant fifo_size  : integer := 4;
  signal clk_i        : std_logic := '0';
  signal rst_i        : std_logic;
  signal dataa_i      : std_logic_vector(port_size-1 downto 0);
  signal datab_o      : std_logic_vector(port_size-1 downto 0);
  signal ena_i        : std_logic;
  signal enb_i        : std_logic;
  signal overflow_o   : std_logic;
  signal full_o       : std_logic;
  signal gofull_o     : std_logic;
  signal steady_o     : std_logic;
  signal goempty_o    : std_logic;
  signal empty_o      : std_logic;
  signal underflow_o  : std_logic;

  signal write_ok     : boolean;

  signal clkb_i       : std_logic := '0';
  signal rstb_i       : std_logic;
  signal enb2_i       : std_logic;
  signal datab2_o     : std_logic_vector(port_size-1 downto 0);

  signal overflowa_o  : std_logic;
  signal fulla_o      : std_logic;
  signal gofulla_o    : std_logic;
  signal steadya_o    : std_logic;
  signal goemptya_o   : std_logic;
  signal emptya_o     : std_logic;
  signal underflowa_o : std_logic;
  signal overflowb_o  : std_logic;
  signal fullb_o      : std_logic;
  signal gofullb_o    : std_logic;
  signal steadyb_o    : std_logic;
  signal goemptyb_o   : std_logic;
  signal emptyb_o     : std_logic;
  signal underflowb_o : std_logic;


begin

  rst_i  <= '1', '0' after 40 ns;
  clk_i <= not clk_i after 10 ns;

  rstb_i  <= '1', '0' after 120 ns;
  clkb_i <= not clkb_i after 30 ns;


  process
  begin
    enb_i   <= '0';
    ena_i   <= '0';
    write_ok <= false;
    wait until rst_i = '0';
    wait until rising_edge(clk_i);
    --write
    for j in 16 downto 1 loop
      ena_i   <= '1';
      dataa_i <= to_std_logic_vector(j,dataa_i'length);
      wait until rising_edge(clk_i);
    end loop;
    ena_i   <= '0';
    write_ok <= true;
    --read
    for j in 1 to 16 loop
      enb_i   <= '1';
      wait until rising_edge(clk_i);
    end loop;
    enb_i   <= '0';
    wait;
  end process;

  process
  begin
    enb2_i   <= '0';
    wait until rstb_i = '0';
    wait until write_ok;
    wait until rising_edge(clkb_i);
    --read
    for j in 1 to 16 loop
      enb2_i   <= '1';
      wait until rising_edge(clkb_i);
    end loop;
    enb2_i   <= '0';
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

    stdfifo2ck_i : stdfifo2ck
    generic map (
      ram_type  => blockram,
      fifo_size => fifo_size,
      port_size => port_size
    )
    port map (
      clka_i       => clk_i,
      rsta_i       => rst_i,
      clkb_i       => clkb_i,
      rstb_i       => rstb_i,
      dataa_i      => dataa_i,
      datab_o      => datab2_o,
      ena_i        => ena_i,
      enb_i        => enb2_i,
      overflowa_o  => overflowa_o,
      fulla_o      => fulla_o,
      gofulla_o    => gofulla_o,
      steadya_o    => steadya_o,
      goemptya_o   => goemptya_o,
      emptya_o     => emptya_o,
      underflowa_o => underflowa_o,
      overflowb_o  => overflowb_o,
      fullb_o      => fullb_o,
      gofullb_o    => gofullb_o,
      steadyb_o    => steadyb_o,
      goemptyb_o   => goemptyb_o,
      emptyb_o     => emptyb_o,
      underflowb_o => underflowb_o
    );


end behavioral;
