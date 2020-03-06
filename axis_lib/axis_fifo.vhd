----------------------------------------------------------------------------------
-- Simple AXI fifo.
-- It supports:
-- 1) Continuous streaming.
-- 2) Cut through packet mode.
-- 3) Full packet mode.
-- Sync or Async.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library expert;
  use expert.std_logic_gray.all;
library stdblocks;
  use stdblocks.sync_lib.all;
  use stdblocks.ram_lib.all;
  use stdblocks.fifo_lib.all;

entity axis_fifo is
    generic (
      ram_type     :  fifo_t := blockram; --type of memory.
      fifo_size    : integer := 8;        --fifo size is 2**fifo_size-1
      tdata_size   : integer := 8;        --tdata port size. must be > 0
      tdest_size   : integer := 8;        --tdest port size. must be > 0
      tuser_size   : integer := 8;        --tuser port size. must be > 0
      tuser_enable : boolean := false;    --enable tuser port
      tdest_enable : boolean := false;    --enable tdest port
      tlast_enable : boolean := false;    --enable tlastr port
      cut_through  : boolean := false;    --when enabled, start sending poacket data right after receive.
      sync_mode    : boolean := false     --use clock A only.
    );
    port (
      --general
      clka_i       : in  std_logic;
      rsta_i       : in  std_logic;
      clkb_i       : in  std_logic;
      rstb_i       : in  std_logic;

      s_tdata_i    : in  std_logic_vector(tdata_size-1 downto 0);
      s_tuser_i    : in  std_logic_vector(tuser_size-1 downto 0);
      s_tdest_i    : in  std_logic_vector(tdest_size-1 downto 0);
      s_tready_o   : out std_logic;
      s_tvalid_i   : in  std_logic;
      s_tlast_i    : in  std_logic;

      m_tdata_o    : out std_logic_vector(tdata_size-1 downto 0);
      m_tuser_o    : out std_logic_vector(tuser_size-1 downto 0);
      m_tdest_o    : out std_logic_vector(tdest_size-1 downto 0);
      m_tready_i   : in  std_logic;
      m_tvalid_o   : out std_logic;
      m_tlast_o    : out std_logic;

      fifo_status_a_o : out fifo_status;
      fifo_status_b_o : out fifo_status
    );
end axis_fifo;

architecture behavioral of axis_fifo is

  constant fifo_param_c : fifo_config_rec := (
    ram_type     => ram_type,
    fifo_size    => fifo_size,
    tdata_size   => tdata_size,
    tdest_size   => tdest_size,
    tuser_size   => tuser_size,
    packet_mode  => packet_mode,
    tuser_enable => tuser_enable,
    tdest_enable => tdest_enable,
    tlast_enable => tlast_enable,
    cut_through  => cut_through,
    sync_mode    => sync_mode
  );

  constant max_packets     : real    := real(2**fifo_size) / real(min_packet_size);
  constant max_packets_log : real    := log2(max_packets);
  constant header_depth    : integer := integer(ceil(max_packets_log));
  constant header_size     : integer := header_size_f(fifo_param_c);
  constant fifo_data_size  : integer := fifo_size_f(fifo_param_c);

  signal fifo_data_i_s   : std_logic_vector(fifo_data_size-1 downto 0);
  signal fifo_data_o_s   : std_logic_vector(fifo_data_size-1 downto 0);

  signal head_data_i_s   : std_logic_vector(header_size-1 downto 0);
  signal head_data_o_s   : std_logic_vector(header_size-1 downto 0);

  signal enb_i_s         : std_logic;
  signal ena_i_s         : std_logic;
  signal head_enb_i_s    : std_logic;
  signal head_ena_i_s    : std_logic;

  signal fifo_status_a_s : fifo_status;
  signal fifo_status_b_s : fifo_status;
  signal head_status_a_s : fifo_status;
  signal head_status_b_s : fifo_status;

begin

  process(all)
    variable fifo_data_v : fifo_data_rec;
  begin
    fifo_data_v.tdata := s_tdata_i;
    fifo_data_v.tuser := s_tuser_i;
    fifo_data_v.tdest := s_tdest_i;
    fifo_data_v.tlast := '0'';
    data_bus_in (fifo_data_v, fifo_param_c, fifo_data_i_s, head_data_i_s);
    --
    data_bus_out(fifo_data_v, fifo_param_c, fifo_data_o_s, head_data_o_s);
    m_tdest_o <= fifo_data_v.tdest;
    m_tuser_o <= fifo_data_v.tuser;
    m_tdata_o <= fifo_data_v.tdata;
  end process;
  m_tlast_o <= m_tlast_s;

  tready_o <= not fifo_status_a_s.full and not head_status_a_s.full;
  ena_i_s  <= not fifo_status_a_s.full and not head_status_a_s.full and s_tvalid_i;

  m_tvalid_o <= not fifo_status_b_s.empty when cut_through else
                not head_status_b_s.empty;

  enb_i_s    <= m_tready_i when fifo_status_b_s.empty = '0' and cut_through else
                m_tready_i when head_status_b_s.empty = '0'                 else
                '0';

  head_ena_i_s <= ena_i_s and s_tlast_i;
  head_enb_i_s <= enb_i_s and m_tlast_s;

  fifo_status_a_o => fifo_status_a_s;
  fifo_status_b_o => fifo_status_b_s;

  head_fifo_gen : if sync_fifo generate
    head_fifo_u : stdfifo1ck
      generic map(
        ram_type  => blockram,
        fifo_size => header_depth,
        port_size => header_size
      );
      port map(
        clk_i   => clka_i,
        rst_i   => rsta_i,
        dataa_i  => head_data_i_s,
        datab_o  => head_data_o_s,
        ena_i    => head_ena_i_s,
        enb_i    => head_enb_i_s,

        fifo_status_a_o => head_status_a_s,
        fifo_status_b_o => head_status_b_s
      );

  else generate

    head_fifo_u : stdfifo2ck
      generic map(
        ram_type  => ram_type,
        fifo_size => header_depth,
        port_size => header_size
      );
      port map(
        --general
        clka_i   => clka_i,
        rsta_i   => rsta_i,
        clkb_i   => clkb_i,
        rstb_i   => rstb_i,
        dataa_i  => head_data_i_s,
        datab_o  => head_data_o_s,
        ena_i    => head_ena_i_s,
        enb_i    => head_enb_i_s,

        fifo_status_a_o => fifo_status_a_s,
        fifo_status_b_o => fifo_status_b_s
      );
  end generate;

  data_fifo_gen : if sync_fifo generate
    data_fifo_u : stdfifo1ck
      generic map(
        ram_type  => ram_type,
        fifo_size => fifo_size,
        port_size => fifo_data_size
      );
      port map(
        clk_i   => clka_i,
        rst_i   => rsta_i,
        dataa_i  => fifo_data_i_s,
        datab_o  => fifo_data_o_s,
        ena_i    => ena_i_s,
        enb_i    => enb_i_s,

        fifo_status_a_o => fifo_status_a_s,
        fifo_status_b_o => fifo_status_b_s
      );

  else generate

    data_fifo_u : stdfifo2ck
      generic map(
        ram_type  => ram_type,
        fifo_size => fifo_size,
        port_size => fifo_data_size
      );
      port map(
        --general
        clka_i   => clka_i,
        rsta_i   => rsta_i,
        clkb_i   => clkb_i,
        rstb_i   => rstb_i,
        dataa_i  => fifo_data_i_s,
        datab_o  => fifo_data_o_s,
        ena_i    => ena_i_s,
        enb_i    => enb_i_s,

        fifo_status_a_o => fifo_status_a_s,
        fifo_status_b_o => fifo_status_b_s
      );
  end generate;

end behavioral;
