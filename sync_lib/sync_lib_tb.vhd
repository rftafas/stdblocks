----------------------------------------------------------------------------------
-- Sync_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library stdblocks;
    use stdblocks.sync_lib.all;

entity sync_lib_tb is
end sync_lib_tb;

architecture behavioral of sync_lib_tb is

  signal rst_i     : std_logic;
  signal mclk_i    : std_logic := '1';
  signal slowclk_i : std_logic := '1';

  signal align_i_s  : std_logic_vector(7 downto 0);
  signal align_o_s  : std_logic_vector(7 downto 0);
  signal det_up_s   : std_logic;
  signal det_down_s : std_logic;
  signal det_ud_s   : std_logic;
  signal syncr_s    : std_logic;
  signal stretch_s  : std_logic;

begin

  rst_i     <= '1',      '0' after 50 ns;
  mclk_i    <= not mclk_i    after 10 ns;
  slowclk_i <= not slowclk_i after 35 ns;

  process
  begin
    align_i_s <= (others=>'0');
    wait until rst_i = '0';
    wait until rising_edge(mclk_i);
    for j in align_i_s'range loop
      align_i_s(j) <= '1';
      wait until rising_edge(mclk_i);
    end loop;
    wait until align_o_s = "11111111";
    wait until rising_edge(mclk_i);
    for j in align_i_s'range loop
      align_i_s(j) <= '0';
      wait until rising_edge(mclk_i);
    end loop;
    wait;
  end process;

  pulse_align_i : pulse_align
    generic map (
      port_size => 8
    )
    port map (
      rst_i  => rst_i,
      mclk_i => mclk_i,
      en_i   => align_i_s,
      en_o   => align_o_s
    );

    det_up_i : det_up
    port map (
      rst_i  => rst_i,
      mclk_i => mclk_i,
      din    => align_o_s(7),
      dout   => det_up_s
    );

    det_down_i : det_down
    port map (
      rst_i  => rst_i,
      mclk_i => mclk_i,
      din    => align_o_s(7),
      dout   => det_down_s
    );

    det_updown_i : det_updown
    port map (
      rst_i  => rst_i,
      mclk_i => mclk_i,
      din    => align_o_s(7),
      dout   => det_ud_s
    );

    sync_r_i : sync_r
      generic map (
        stages => 5
      )
      port map (
        rst_i  => rst_i,
        mclk_i => mclk_i,
        din    => align_o_s(7),
        dout   => syncr_s
      );

    async_stretch_i : async_stretch
    port map (
      clkin_i   => slowclk_i,
      clkout_i  => mclk_i,
      din       => det_up_s,
      dout      => stretch_s
    );


end behavioral;
