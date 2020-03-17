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

  signal write_ok     : boolean;

  signal clkb_i       : std_logic := '0';
  signal rstb_i       : std_logic;
  signal enb2_i       : std_logic;
  signal datab2_o     : std_logic_vector(port_size-1 downto 0);

  signal datab3_o     : std_logic_vector(port_size-1 downto 0);

  signal fifo_status_o   : fifo_status;
  signal fifo_status3_o  : fifo_status;
  signal fifo_status_a_o : fifo_status;
  signal fifo_status_b_o : fifo_status;

begin

  rst_i  <= '1', '0' after 40 ns;
  clk_i <= not clk_i after 10 ns;

  rstb_i  <= '1', '0' after 120 ns;
  clkb_i <= not clkb_i after 20 ns;


  process
    variable counter_v : integer := 20;
  begin
    enb_i   <= '0';
    ena_i   <= '0';
    write_ok <= false;
    wait until rst_i = '0';
    wait until rising_edge(clk_i);
    --write
    report "starting write test" severity note;
    for j in 0 downto 0 loop
      ena_i   <= '1';
      dataa_i <= to_std_logic_vector(j+5,dataa_i'length);
      wait until rising_edge(clk_i);
    end loop;
    ena_i   <= '0';
    wait until rising_edge(clk_i);
    write_ok <= true;
    --read
    wait until rising_edge(clk_i);
    report "starting read test" severity note;
    for j in 0 downto 0 loop
      enb_i   <= '1';
      wait until rising_edge(clk_i);
    end loop;
    enb_i   <= '0';
    wait for 500 ns;
    wait until rising_edge(clk_i);
    report "starting write forever" severity note;
    dataa_i   <= to_std_logic_vector(counter_v,dataa_i'length);
    wait until rising_edge(clk_i);
    while true loop
      ena_i <= not ena_i;
      if ena_i = '1' then
        counter_v := counter_v + 1;
        dataa_i   <= to_std_logic_vector(counter_v,dataa_i'length);
      end if;
      if fifo_status_o.steady = '1' then
        enb_i <= not ena_i;
      else
        enb_i <= '0';
      end if;
      wait until rising_edge(clk_i);
    end loop;
    wait;
  end process;

  process
  begin
    enb2_i   <= '0';
    wait until rstb_i = '0';
    wait until fifo_status_b_o.empty = '0';
    wait until rising_edge(clkb_i);
    --read
    for j in 0 to 0 loop
      enb2_i   <= '1';
      wait until rising_edge(clkb_i);
    end loop;
    enb2_i   <= '0';
    wait until fifo_status_b_o.steady = '1';
    wait until rising_edge(clkb_i);
    while true loop
      if fifo_status_b_o.steady = '1' then
        enb2_i <= '1';
      elsif fifo_status_b_o.gofull = '1' then
        enb2_i <= '1';
      elsif fifo_status_b_o.full = '1' then
        enb2_i <= '1';
      else
        enb2_i <= '0';
      end if;
      wait until rising_edge(clkb_i);
    end loop;
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
      --
      fifo_status_o => fifo_status_o

    );

    stdfifo2ck_i : stdfifo2ck
    generic map (
      ram_type  => blockram,
      fifo_size => 5,
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
      fifo_status_a_o => fifo_status_a_o,
      fifo_status_b_o => fifo_status_b_o
    );


    srfifo1ck_i : srfifo1ck
      generic map (
        fifo_size => fifo_size,
        port_size => port_size
      )
      port map (
        clk_i         => clk_i,
        rst_i         => rst_i,
        dataa_i       => dataa_i,
        datab_o       => datab3_o,
        ena_i         => ena_i,
        enb_i         => enb_i,
        fifo_status_o => fifo_status3_o
      );

end behavioral;
