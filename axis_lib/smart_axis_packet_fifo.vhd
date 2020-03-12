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
        tdest_enable : boolean := false
      );
      port (
        --general
        clk_i       : in  std_logic;
        rst_i       : in  std_logic;

        v    : in  std_logic_vector(tdata_size-1 downto 0);
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

        flush_i      : in  std_logic;
        abort_i      : in  std_logic;

        fifo_status_a_o : out fifo_status;
        fifo_status_b_o : out fifo_status
      );
  end smart_axis_packet_fifo;

architecture behavioral of smart_axis_packet_fifo is

  constant meta_param_c : fifo_config_rec := (
    ram_type     => distributed,
    fifo_size    => meta_size,
    tdata_size   => tdata_size,
    tdest_size   => tdest_size,
    tuser_size   => tuser_size,
    packet_mode  => true,
    tuser_enable => tuser_enable,
    tdest_enable => tdest_enable,
    tlast_enable => tlast_enable,
    cut_through  => false,
    sync_mode    => true
  );

  constant meta_port_size : integer := header_size_f(meta_param_c);

  signal   fifo_data_i_s  : std_logic_vector(input_vector_size-1 downto 0);
  signal   fifo_data_i_s  : std_logic_vector(input_vector_size-1 downto 0);

  signal meta_enb_i_s     : std_logic;
  signal meta_ena_i_s     : std_logic;

  signal fifo_status_a_s : fifo_status;
  signal fifo_status_b_s : fifo_status;
  signal fifo_status_a_s : fifo_status;
  signal fifo_status_b_s : fifo_status;

begin

  meta_ena_i_s <= '0' when abort_i = '1' else
                  '1' when s_tlast_i = '1' and s_tvalid_i = '1' and s_tready_o_s = '1' else
                  '0';

  meta_enb_i_s <= '1' when flush_i = '1' else
                  '1' when m_tlast_o_s = '1' and m_tready_i = '1' and m_tvalid_o_s = '1' else
                  '0';

  ena_i_s         <= (not fifo_status_a_s.full)  and (not  meta_status_a_s.full) and s_tvalid_i;
  enb_i_s         <= (not fifo_status_b_s.empty) and (not meta_status_a_s.empty) and m_tready_i;

  meta_fifo_u : stdfifo1ck
    generic map(
      ram_type  => distributed,
      fifo_size => meta_size,
      port_size => meta_port_size
    );
    port map(
      --general
      clk_i    => clk_i,
      rst_i    => rst_i,
      dataa_i  => meta_data_i_s,
      datab_o  => meta_data_o_s,
      ena_i    => meta_ena_i_s,
      enb_i    => meta_enb_i_s,

      fifo_status_a_o => meta_status_a_s,
      fifo_status_b_o => meta_status_b_s
    );

  data_fifo_u : fifo_int
    generic map(
      ram_type  => ram_type,
      fifo_size => fifo_size,
      port_size => tdata_size
    );
    port map(
      --general
      clka_i   => clk_i,
      rsta_i   => rst_i,
      dataa_i  => s_tdata_i,
      datab_o  => meta_data_o_s,
      ena_i    => ena_i_s,
      enb_i    => enb_i_s,

      pointera_i    => abort_pointer_s,
      pointera_o    => pointera_o_s,
      pointera_en_i => abort_i,
      pointerb_i    => pointerb_i_s,
      pointerb_o    => open,
      pointerb_en_i => flush_i,

      fifo_status_a_o => fifo_status_a_s,
      fifo_status_b_o => fifo_status_b_s
    );

    process(all)
    begin
      if rising_edge(clk_i) then
        if meta_ena_i_s = '1' then
          abort_pointer_s <= pointera_o_s;
        end if;
        flush_s <= flush_i;
      end if;
    end process;

  end behavioral;
