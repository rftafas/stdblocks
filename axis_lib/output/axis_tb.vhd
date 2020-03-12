---------------------------------------------------------------------------------------------------------
-- This code and it autogenerated outputs are provided under LGPL by Ricardo Tafas.                    --
-- What does that mean? That you get it for free as long as you give back all good stiff you add to it.--
-- You can download more VHDL stuff at https://github.com/rftafas                                      --
---------------------------------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library expert;
  use expert.std_logic_expert.all;
library stdblocks;
  use stdblocks.fifo_lib.all;

entity axis_tb is
end axis_tb;

architecture simulation of axis_tb is

  constant packet_size : integer := 10;

  signal clk_s    : std_logic := '0';
  signal rst_s    : std_logic := '0';

  component broadcast2 is
    generic (
      tdata_size : integer := 32;
      tdest_size : integer := 8;
      tuser_size : integer := 8
    );
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      m0_tdata_o  : out std_logic_vector(tdata_size-1 downto 0);
      m0_tuser_o  : out std_logic_vector(tuser_size-1 downto 0);
      m0_tdest_o  : out std_logic_vector(tdest_size-1 downto 0);
      m0_tready_i : in  std_logic;
      m0_tvalid_o : out std_logic;
      m0_tlast_o  : out std_logic;
      m1_tdata_o  : out std_logic_vector(tdata_size-1 downto 0);
      m1_tuser_o  : out std_logic_vector(tuser_size-1 downto 0);
      m1_tdest_o  : out std_logic_vector(tdest_size-1 downto 0);
      m1_tready_i : in  std_logic;
      m1_tvalid_o : out std_logic;
      m1_tlast_o  : out std_logic;
      s_tdata_i   : in  std_logic_vector(tdata_size-1 downto 0);
      s_tuser_i   : in  std_logic_vector(tuser_size-1 downto 0);
      s_tdest_i   : in  std_logic_vector(tdest_size-1 downto 0);
      s_tready_o  : out std_logic;
      s_tvalid_i  : in  std_logic;
      s_tlast_i   : in  std_logic
    );
  end component;

  component axis_fifo is
    generic (
      ram_type     : fifo_t := blockram;
      fifo_size    : integer := 8;
      tdata_size   : integer := 8;
      tdest_size   : integer := 8;
      tuser_size   : integer := 8;
      packet_mode  : boolean := false;
      tuser_enable : boolean := false;
      tlast_enable : boolean := false;
      tdest_enable : boolean := false;
      sync_mode    : boolean := false;
      cut_through  : boolean := false
    );
    port (
      clka_i          : in  std_logic;
      rsta_i          : in  std_logic;
      clkb_i          : in  std_logic;
      rstb_i          : in  std_logic;
      s_tdata_i       : in  std_logic_vector(tdata_size-1 downto 0);
      s_tuser_i       : in  std_logic_vector(tuser_size-1 downto 0);
      s_tdest_i       : in  std_logic_vector(tdest_size-1 downto 0);
      s_tready_o      : out std_logic;
      s_tvalid_i      : in  std_logic;
      s_tlast_i       : in  std_logic;
      m_tdata_o       : out std_logic_vector(tdata_size-1 downto 0);
      m_tuser_o       : out std_logic_vector(tuser_size-1 downto 0);
      m_tdest_o       : out std_logic_vector(tdest_size-1 downto 0);
      m_tready_i      : in  std_logic;
      m_tvalid_o      : out std_logic;
      m_tlast_o       : out std_logic;
      fifo_status_a_o : out fifo_status;
      fifo_status_b_o : out fifo_status
    );
  end component;

  component intercon2_mux is
    generic (
      tdata_size   : integer := 8;
      tdest_size   : integer := 8;
      tuser_size   : integer := 8;
      select_auto  : boolean := false;
      switch_tlast : boolean := false;
      interleaving : boolean := false;
      max_tx_size  : integer := 10;
      mode         : integer := 10
    );
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      s0_tdata_i  : in  std_logic_vector(tdata_size-1 downto 0);
      s0_tuser_i  : in  std_logic_vector(tuser_size-1 downto 0);
      s0_tdest_i  : in  std_logic_vector(tdest_size-1 downto 0);
      s0_tready_o : out std_logic;
      s0_tvalid_i : in  std_logic;
      s0_tlast_i  : in  std_logic;
      s1_tdata_i  : in  std_logic_vector(tdata_size-1 downto 0);
      s1_tuser_i  : in  std_logic_vector(tuser_size-1 downto 0);
      s1_tdest_i  : in  std_logic_vector(tdest_size-1 downto 0);
      s1_tready_o : out std_logic;
      s1_tvalid_i : in  std_logic;
      s1_tlast_i  : in  std_logic;
      m_tdata_o   : out std_logic_vector(tdata_size-1 downto 0);
      m_tuser_o   : out std_logic_vector(tuser_size-1 downto 0);
      m_tdest_o   : out std_logic_vector(tdest_size-1 downto 0);
      m_tready_i  : in  std_logic;
      m_tvalid_o  : out std_logic;
      m_tlast_o   : out std_logic
    );
  end component;

  component intercon2_demux is
    generic (
      tdata_size   : integer := 8;
      tdest_size   : integer := 8;
      tuser_size   : integer := 8;
      select_auto  : boolean := false;
      switch_tlast : boolean := false;
      max_tx_size  : integer := 10
    );
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      m0_tdata_o  : out std_logic_vector(tdata_size-1 downto 0);
      m0_tuser_o  : out std_logic_vector(tuser_size-1 downto 0);
      m0_tdest_o  : out std_logic_vector(tdest_size-1 downto 0);
      m0_tready_i : in  std_logic;
      m0_tvalid_o : out std_logic;
      m0_tlast_o  : out std_logic;
      m1_tdata_o  : out std_logic_vector(tdata_size-1 downto 0);
      m1_tuser_o  : out std_logic_vector(tuser_size-1 downto 0);
      m1_tdest_o  : out std_logic_vector(tdest_size-1 downto 0);
      m1_tready_i : in  std_logic;
      m1_tvalid_o : out std_logic;
      m1_tlast_o  : out std_logic;
      s_tdata_i   : in  std_logic_vector(tdata_size-1 downto 0);
      s_tuser_i   : in  std_logic_vector(tuser_size-1 downto 0);
      s_tdest_i   : in  std_logic_vector(tdest_size-1 downto 0);
      s_tready_o  : out std_logic;
      s_tvalid_i  : in  std_logic;
      s_tlast_i   : in  std_logic
    );
  end component;

  component smart_axis_packet_fifo is
    generic (
      ram_type     : fifo_t := blockram;
      fifo_size    : integer := 8;
      meta_size    : integer := 5;
      tdata_size   : integer := 8;
      tdest_size   : integer := 8;
      tuser_size   : integer := 8;
      tuser_enable : boolean := false;
      tdest_enable : boolean := false
    );
    port (
      clk_i           : in  std_logic;
      rst_i           : in  std_logic;
      s_tdata_i       : in  std_logic_vector(tdata_size-1 downto 0);
      s_tuser_i       : in  std_logic_vector(tuser_size-1 downto 0);
      s_tdest_i       : in  std_logic_vector(tdest_size-1 downto 0);
      s_tready_o      : out std_logic;
      s_tvalid_i      : in  std_logic;
      s_tlast_i       : in  std_logic;
      m_tdata_o       : out std_logic_vector(tdata_size-1 downto 0);
      m_tuser_o       : out std_logic_vector(tuser_size-1 downto 0);
      m_tdest_o       : out std_logic_vector(tdest_size-1 downto 0);
      m_tready_i      : in  std_logic;
      m_tvalid_o      : out std_logic;
      m_tlast_o       : out std_logic;
      flush_i         : in  std_logic;
      abort_i         : in  std_logic;
      fifo_status_a_o : out fifo_status;
      fifo_status_b_o : out fifo_status
    );
  end component;

  signal broadcast_tdata_i   : std_logic_vector(31 downto 0) := (others=>'0');
  signal broadcast_tuser_i   : std_logic_vector(7 downto 0)  := (others=>'0');
  signal broadcast_tdest_i   : std_logic_vector(7 downto 0)  := (others=>'0');
  signal broadcast_tready_o  : std_logic;
  signal broadcast_tvalid_i  : std_logic := '0';
  signal broadcast_tlast_i   : std_logic := '0';

  signal broadcast0_tdata_o  : std_logic_vector(31 downto 0);
  signal broadcast0_tuser_o  : std_logic_vector(7 downto 0);
  signal broadcast0_tdest_o  : std_logic_vector(7 downto 0);
  signal broadcast0_tready_i : std_logic := '0';
  signal broadcast0_tvalid_o : std_logic;
  signal broadcast0_tlast_o  : std_logic;

  signal broadcast1_tdata_o  : std_logic_vector(31 downto 0);
  signal broadcast1_tuser_o  : std_logic_vector(7 downto 0);
  signal broadcast1_tdest_o  : std_logic_vector(7 downto 0);
  signal broadcast1_tready_i : std_logic := '0';
  signal broadcast1_tvalid_o : std_logic;
  signal broadcast1_tlast_o  : std_logic;

  signal fifo0_tdata_o       : std_logic_vector(31 downto 0);
  signal fifo0_tuser_o       : std_logic_vector(7 downto 0);
  signal fifo0_tdest_o       : std_logic_vector(7 downto 0);
  signal fifo0_tready_i      : std_logic := '0';
  signal fifo0_tvalid_o      : std_logic;
  signal fifo0_tlast_o       : std_logic;

  signal fifo1_tdata_o       : std_logic_vector(31 downto 0);
  signal fifo1_tuser_o       : std_logic_vector(7 downto 0);
  signal fifo1_tdest_o       : std_logic_vector(7 downto 0);
  signal fifo1_tready_i      : std_logic := '0';
  signal fifo1_tvalid_o      : std_logic;
  signal fifo1_tlast_o       : std_logic;

  signal fifo0_status_a_o    : fifo_status;
  signal fifo0_status_b_o    : fifo_status;
  signal fifo1_status_a_o    : fifo_status;
  signal fifo1_status_b_o    : fifo_status;

  signal mux_tdata_o           : std_logic_vector(31 downto 0);
  signal mux_tuser_o           : std_logic_vector(7 downto 0);
  signal mux_tdest_o           : std_logic_vector(7 downto 0);
  signal mux_tready_i          : std_logic;
  signal mux_tvalid_o          : std_logic;
  signal mux_tlast_o           : std_logic;

  signal demux0_tdata_o       : std_logic_vector(31 downto 0);
  signal demux0_tuser_o       : std_logic_vector(7 downto 0);
  signal demux0_tdest_o       : std_logic_vector(7 downto 0);
  signal demux0_tready_i      : std_logic := '0';
  signal demux0_tvalid_o      : std_logic;
  signal demux0_tlast_o       : std_logic;

  signal demux1_tdata_o       : std_logic_vector(31 downto 0);
  signal demux1_tuser_o       : std_logic_vector(7 downto 0);
  signal demux1_tdest_o       : std_logic_vector(7 downto 0);
  signal demux1_tready_i      : std_logic := '0';
  signal demux1_tvalid_o      : std_logic;
  signal demux1_tlast_o       : std_logic;

  signal fifo2_tdata_o       : std_logic_vector(31 downto 0);
  signal fifo2_tuser_o       : std_logic_vector(7 downto 0);
  signal fifo2_tdest_o       : std_logic_vector(7 downto 0);
  signal fifo2_tready_i      : std_logic := '0';
  signal fifo2_tvalid_o      : std_logic;
  signal fifo2_tlast_o       : std_logic;

begin

  clk_s <= not clk_s after 10 ns;
  rst_s <= '1', '0' after 41 ns;

  process
  begin
    wait until rst_s = '0';
    for j in 0 to packet_size loop
      broadcast_tdata_i  <= to_std_logic_vector(j,32);
      broadcast_tvalid_i <= '1';
      broadcast_tlast_i  <= '0';
      if j = packet_size then
        broadcast_tlast_i <= '1';
      end if;
      wait until rising_edge(clk_s) and broadcast_tready_o = '1';
    end loop;
    broadcast_tvalid_i <= '0';
    for j in 0 to 3 loop
      wait until rising_edge(clk_s);
    end loop;
  end process;

  broadcast2_i : broadcast2
  generic map (
    tdata_size => 32,
    tdest_size => 8,
    tuser_size => 8
  )
  port map (
    clk_i       => clk_s,
    rst_i       => rst_s,
    m0_tdata_o  => broadcast0_tdata_o,
    m0_tuser_o  => broadcast0_tuser_o,
    m0_tdest_o  => open,
    m0_tready_i => broadcast0_tready_i,
    m0_tvalid_o => broadcast0_tvalid_o,
    m0_tlast_o  => broadcast0_tlast_o,
    m1_tdata_o  => broadcast1_tdata_o,
    m1_tuser_o  => broadcast1_tuser_o,
    m1_tdest_o  => open,
    m1_tready_i => broadcast1_tready_i,
    m1_tvalid_o => broadcast1_tvalid_o,
    m1_tlast_o  => broadcast1_tlast_o,
    s_tdata_i   => broadcast_tdata_i,
    s_tuser_i   => broadcast_tuser_i,
    s_tdest_i   => broadcast_tdest_i,
    s_tready_o  => broadcast_tready_o,
    s_tvalid_i  => broadcast_tvalid_i,
    s_tlast_i   => broadcast_tlast_i
  );

  broadcast0_tdest_o <= x"00";
  broadcast1_tdest_o <= x"01";

  axis0_fifo_i : axis_fifo
  generic map (
    ram_type     => blockram,
    fifo_size    => 12,
    tdata_size   => 32,
    tdest_size   => 8,
    tuser_size   => 8,
    packet_mode  => true,
    tuser_enable => true,
    tlast_enable => true,
    sync_mode    => true,
    cut_through  => false,
    tdest_enable => true
  )
  port map (
    clka_i          => clk_s,
    rsta_i          => rst_s,
    clkb_i          => '0',
    rstb_i          => '0',
    s_tdata_i       => broadcast0_tdata_o,
    s_tuser_i       => broadcast0_tuser_o,
    s_tdest_i       => broadcast0_tdest_o,
    s_tready_o      => broadcast0_tready_i,
    s_tvalid_i      => broadcast0_tvalid_o,
    s_tlast_i       => broadcast0_tlast_o,
    m_tdata_o       => fifo0_tdata_o,
    m_tuser_o       => fifo0_tuser_o,
    m_tdest_o       => fifo0_tdest_o,
    m_tready_i      => fifo0_tready_i,
    m_tvalid_o      => fifo0_tvalid_o,
    m_tlast_o       => fifo0_tlast_o,
    fifo_status_a_o => fifo0_status_a_o,
    fifo_status_b_o => fifo0_status_b_o
  );

  axis1_fifo_i : axis_fifo
  generic map (
    ram_type     => blockram,
    fifo_size    => 12,
    tdata_size   => 32,
    tdest_size   => 8,
    tuser_size   => 8,
    packet_mode  => true,
    tuser_enable => true,
    tlast_enable => true,
    sync_mode    => true,
    cut_through  => false,
    tdest_enable => true
  )
  port map (
    clka_i          => clk_s,
    rsta_i          => rst_s,
    clkb_i          => '0',
    rstb_i          => '0',
    s_tdata_i       => broadcast1_tdata_o,
    s_tuser_i       => broadcast1_tuser_o,
    s_tdest_i       => broadcast1_tdest_o,
    s_tready_o      => broadcast1_tready_i,
    s_tvalid_i      => broadcast1_tvalid_o,
    s_tlast_i       => broadcast1_tlast_o,
    m_tdata_o       => fifo1_tdata_o,
    m_tuser_o       => fifo1_tuser_o,
    m_tdest_o       => fifo1_tdest_o,
    m_tready_i      => fifo1_tready_i,
    m_tvalid_o      => fifo1_tvalid_o,
    m_tlast_o       => fifo1_tlast_o,
    fifo_status_a_o => fifo1_status_a_o,
    fifo_status_b_o => fifo1_status_b_o
  );

  intercon2_mux_i : intercon2_mux
    generic map (
      tdata_size   => 32,
      tdest_size   => 8,
      tuser_size   => 8,
      select_auto  => true,
      switch_tlast => true,
      interleaving => false,
      max_tx_size  => 50,
      mode         => 0
    )
    port map (
      clk_i       => clk_s,
      rst_i       => rst_s,
      s0_tdata_i  => fifo0_tdata_o,
      s0_tuser_i  => fifo0_tuser_o,
      s0_tdest_i  => fifo0_tdest_o,
      s0_tready_o => fifo0_tready_i,
      s0_tvalid_i => fifo0_tvalid_o,
      s0_tlast_i  => fifo0_tlast_o,
      s1_tdata_i  => fifo1_tdata_o,
      s1_tuser_i  => fifo1_tuser_o,
      s1_tdest_i  => fifo1_tdest_o,
      s1_tready_o => fifo1_tready_i,
      s1_tvalid_i => fifo1_tvalid_o,
      s1_tlast_i  => fifo1_tlast_o,
      m_tdata_o   => mux_tdata_o,
      m_tuser_o   => mux_tuser_o,
      m_tdest_o   => mux_tdest_o,
      m_tready_i  => mux_tready_i,
      m_tvalid_o  => mux_tvalid_o,
      m_tlast_o   => mux_tlast_o
    );

    intercon2_demux_i : intercon2_demux
    generic map (
      tdata_size   => 32,
      tdest_size   => 8,
      tuser_size   => 8,
      select_auto  => true,
      switch_tlast => true,
      max_tx_size  => 50
    )
    port map (
      clk_i       => clk_s,
      rst_i       => rst_s,
      m0_tdata_o  => demux0_tdata_o,
      m0_tuser_o  => demux0_tuser_o,
      m0_tdest_o  => demux0_tdest_o,
      m0_tready_i => '1',--demux0_tready_i,
      m0_tvalid_o => demux0_tvalid_o,
      m0_tlast_o  => demux0_tlast_o,
      m1_tdata_o  => demux1_tdata_o,
      m1_tuser_o  => demux1_tuser_o,
      m1_tdest_o  => demux1_tdest_o,
      m1_tready_i => demux1_tready_i,
      m1_tvalid_o => demux1_tvalid_o,
      m1_tlast_o  => demux1_tlast_o,
      s_tdata_i   => mux_tdata_o,
      s_tuser_i   => mux_tuser_o,
      s_tdest_i   => mux_tdest_o,
      s_tready_o  => mux_tready_i,
      s_tvalid_i  => mux_tvalid_o,
      s_tlast_i   => mux_tlast_o
    );

    smart_axis_packet_fifo_i : smart_axis_packet_fifo
    generic map (
      ram_type     => blockram,
      fifo_size    => 12,
      meta_size    => 5,
      tdata_size   => 32,
      tdest_size   => 8,
      tuser_size   => 8,
      tuser_enable => true,
      tdest_enable => true
    )
    port map (
      clk_i           => clk_i,
      rst_i           => rst_i,
      s_tdata_i       => demux1_tdata_o,
      s_tuser_i       => demux1_tuser_o,
      s_tdest_i       => demux1_tdest_o,
      s_tready_o      => demux1_tready_i,
      s_tvalid_i      => demux1_tvalid_o,
      s_tlast_i       => demux1_tlast_o,
      m_tdata_o       => fifo2_tdata_o,
      m_tuser_o       => fifo2_tuser_o,
      m_tdest_o       => fifo2_tdest_o,
      m_tready_i      => fifo2_tready_i,
      m_tvalid_o      => fifo2_tvalid_o,
      m_tlast_o       => fifo2_tlast_o,
      flush_i         => '0',
      abort_i         => '0',
      fifo_status_a_o => open,
      fifo_status_b_o => open
    );


end simulation;
