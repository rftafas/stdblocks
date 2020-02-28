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

entity axis_packet_fifo is
    generic (
      ram_type        :  fifo_t := blockram;
      fifo_size       : integer := 8;
      min_packet_size : integer := 8;
      tdata_size      : integer := 8;
      tdest_size      : integer := 8;
      tuser_size      : integer := 8;
      tuser_enable    : boolean := false;
      sync_mode       : boolean := false;
      tdest_enable    : boolean := false
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

      s_tdata_o    : out std_logic_vector(tdata_size-1 downto 0);
      s_tuser_o    : out std_logic_vector(tuser_size-1 downto 0);
      s_tdest_o    : out std_logic_vector(tdest_size-1 downto 0);
      m_tready_i   : in  std_logic;
      m_tvalid_o   : out std_logic;
      m_tlast_o    : out std_logic;

      fifo_status_a_o : out fifo_status;
      fifo_status_b_o : out fifo_status
    );
end axis_packet_fifo;

architecture behavioral of axis_packet_fifo is

  constant tlast_use      : boolean := tlast_enable;
  constant int_tlast_size : integer := false2zero(   tlast_use,         1);

  constant max_packets     : real    := real(2**fifo_size) / real(min_packet_size);
  constant max_packets_log : real    := log2(max_packets);
  constant header_depth    : integer := integer(ceil(max_packets_log));
  constant header_size     : integer := int_tlast_size+tuser_size+tdest_size;


  signal   header_i_s  : std_logic_vector(input_vector_size-1 downto 0);
  signal   header_o_s  : std_logic_vector(input_vector_size-1 downto 0);

  signal enb_i_s       : std_logic;
  signal ena_i_s       : std_logic;

  signal fifo_status_a_s : fifo_status;
  signal fifo_status_b_s : fifo_status;

begin

  tready_o <= not fifo_status_a_s.full;
  ena_i_s  <= not fifo_status_a_s.full and s_tvalid_i;

  m_tvalid_o <= not fifo_status_b_s.empty;
  enb_i_s    <= not fifo_status_b_s.empty and m_tready_i;

  fifo_status_a_o => fifo_status_a_s;
  fifo_status_b_o => fifo_status_b_s;


  --
  header_en_i_s <=

  header_fifo_gen : if sync_fifo generate
    header_u : stdfifo1ck
      generic map(
        ram_type  => ram_type,
        fifo_size => header_depth,
        port_size => header_size
      );
      port map(
        clk_i   => clka_i,
        rst_i   => rsta_i,
        dataa_i  => s_tdata_i,
        datab_o  => m_tdata_o,
        ena_i    => ,
        enb_i    => ,

        fifo_status_a_o => fifo_status_a_s,
        fifo_status_b_o => fifo_status_b_s
      );
  else generate
    header_u : stdfifo2ck
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
        dataa_i  => s_tdata_i,
        datab_o  => m_tdata_o,
        ena_i    => ,
        enb_i    => ,

        fifo_status_a_o => fifo_status_a_s,
        fifo_status_b_o => fifo_status_b_s
      );
  end generate;

  head_fifo_gen : if sync_fifo generate
    head_fifo_u : stdfifo1ck
      generic map(
        ram_type  => blockram,
        fifo_size => header_depth,
        port_size => header_size_f
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
        fifo_size => fifo_size,
        port_size => fifo_data_size
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


end behavioral;
