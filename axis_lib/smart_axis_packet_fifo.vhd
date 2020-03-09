----------------------------------------------------------------------------------
-- SPI-AXI-Master  by Ricardo F Tafas Jr
-- For this IP, CPOL = 0 and CPHA = 0. SPI Master must be configured accordingly.
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

  entity smart_axis_packet_fifo is
      generic (
        ram_type     : fifo_t := blockram;
        fifo_size    : integer := 8;
        meta_size    : integer := 5;
        tdata_size   : integer := 8;
        tdest_size   : integer := 8;
        tuser_size   : integer := 8;
        tuser_enable : boolean := false;
        tlast_enable : boolean := false;
        tdest_enable : boolean := false
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

        flush_i      : in  std_logic;
        abort_i      : in  std_logic;

        fifo_status_a_o : out fifo_status;
        fifo_status_b_o : out fifo_status
      );
  end smart_axis_packet_fifo;

architecture behavioral of smart_axis_packet_fifo is

    constant input_vector_size : integer := s_tdata_i'length + s_tuser_i'length + s_tdest_i'length;
    constant meta_fifo_size    : integer := get_data_size (fifo_size,tdest_size,tuser_size,tuser_enable,tdest_enable);

    signal   fifo_data_i_s  : std_logic_vector(input_vector_size-1 downto 0);
    signal   fifo_data_i_s  : std_logic_vector(input_vector_size-1 downto 0);

    signal meta_enb_i_s     : std_logic;
    signal meta_ena_i_s     : std_logic;

    signal fifo_status_a_s : fifo_status;
    signal fifo_status_b_s : fifo_status;

  begin

  meta_ena_i_s <= '0' when abort_i = '1' else
                  '1' when s_tlast_i = '1' and s_tvalid_i = '1' and s_tready_o_s = '1' else
                  '0';

  meta_enb_i_s <= '1' when flush_i = '1' else
                  '1' when m_tlast_o_s = '1' and m_tready_i = '1' and m_tvalid_o_s = '1' else
                  '0';

  meta_fifo_u : stdfifo2ck
      generic map(
        ram_type  => distributed,
        fifo_size => meta_size,
        port_size => meta_fifo_size
      );
      port map(
        --general
        clka_i   => clka_i,
        rsta_i   => rsta_i,
        clkb_i   => clkb_i,
        rstb_i   => rstb_i,
        dataa_i  => meta_data_i_s,
        datab_o  => meta_data_o_s,
        ena_i    => s_tlast_i,
        enb_i    => enb_i_s,

        fifo_status_a_o => meta_status_a_s,
        fifo_status_b_o => meta_status_b_s
      );

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
          dataa_i  => meta_data_i_s,
          datab_o  => meta_data_o_s,
          ena_i    => s_tlast_i,
          enb_i    => enb_i_s,

          fifo_status_a_o => meta_status_a_s,
          fifo_status_b_o => meta_status_b_s
        );


  end behavioral;
