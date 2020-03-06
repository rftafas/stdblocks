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
        clk_i       : in  std_logic;
        rst_i       : in  std_logic;

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
        repeat_i     : in  std_logic;

        fifo_status_a_o : out fifo_status;
        fifo_status_b_o : out fifo_status
      );
  end smart_axis_packet_fifo;

architecture behavioral of smart_axis_packet_fifo is

  constant fifo_param_c : fifo_config_rec := (
    ram_type     => ram_type,
    fifo_size    => fifo_size,
    tdata_size   => fifo_size,
    tdest_size   => tdest_size,
    tuser_size   => tuser_size,
    packet_mode  => false,
    tuser_enable => tuser_enable,
    tdest_enable => tdest_enable,
    tlast_enable => false,
    cut_through  => false,
    sync_mode    => true
  );

    constant max_packets     : real    := real(2**fifo_size) / real(min_packet_size);
    constant max_packets_log : real    := log2(max_packets);
    constant header_depth    : integer := integer(ceil(max_packets_log));
    constant header_size     : integer := header_size_f(fifo_param_c);
    constant meta_data_size  : integer := fifo_size_f(fifo_param_c);

    signal   fifo_data_i_s  : std_logic_vector(input_vector_size-1 downto 0);
    signal   fifo_data_i_s  : std_logic_vector(input_vector_size-1 downto 0);

    signal meta_enb_i_s     : std_logic;
    signal meta_ena_i_s     : std_logic;

    signal fifo_status_a_s : fifo_status;
    signal fifo_status_s : fifo_status;

  begin

  process(all)
    variable fifo_data_v : fifo_data_rec;
  begin
    fifo_data_v.tdata := pointera_o_s;
    fifo_data_v.tuser := s_tuser_i;
    fifo_data_v.tdest := s_tdest_i;
    fifo_data_v.tlast := '0';
    data_bus_in (fifo_data_v, fifo_param_c, meta_data_i_s, head_data_i_s);
    --
    data_bus_out(fifo_data_v, fifo_param_c, meta_data_o_s, head_data_o_s);
    m_tdest_o     <= fifo_data_v.tdest;
    m_tuser_o     <= fifo_data_v.tuser;
    end_pointer_s <= fifo_data_v.tdata;
  end process;

  tready_o <= not fifo_status_s.full and not meta_status_s.full;
  ena_i_s  <= not fifo_status_s.full and not meta_status_s.full and s_tvalid_i;

  m_tvalid_o <= not meta_status_s.empty;
  enb_i_s    <= '0' when fifo_status_s.empty = '1' else
                '0' when meta_status_s.empty = '1' else
                m_tready_i;

  meta_ena_i_s <= ena_i_s and s_tlast_i;
  meta_enb_i_s <= '0' when meta_status_s.empty = '1'   else
                  '0' when repeat_i = '1'              else
                  '1' when enb_i_s and m_tlast_s = '1' else
                  '1' when flush_i  = '1'              else
                  '0';

  fifo_status_a_o => fifo_status_a_s;
  fifo_status_b_o => fifo_status_b_s;

  process(clk_i)
  begin
    if clk_i'event and clk_i = '1' then

    end if;
  end process;

  meta_fifo_u : fifo_int
    generic map(
      ram_type  => blockram,
      fifo_size => header_depth,
      port_size => meta_data_size
      );
    port map(
      --general
      clk_i    => clk_i,
      rst_i    => rst_i,
      dataa_i  => meta_data_i_s,
      datab_o  => meta_data_o_s,
      ena_i    => meta_ena_i_s,
      enb_i    => meta_enb_i_s,
      pointera_i    => (others=>'0'),
      pointera_o    => open,
      pointera_en_i => '0',
      pointerb_i    => (others=>'0'),
      pointerb_o    => open,
      pointerb_en_i => '0',
      fifo_status_o => meta_status_s,
    );

  data_fifo_u : fifo_int
    generic map(
      ram_type  => ram_type,
      port_size => tdata_size,
      fifo_size => fifo_size
      );
    port map(
      --general
      clk_i         => clk_i,
      rst_i         => rst_i,
      dataa_i       => s_tdata_i,
      datab_o       => m_tdata_o,
      ena_i         => ena_i_s,
      enb_i         => enb_i_s,
      pointera_i    => pointera_i_s,
      pointera_o    => pointera_o_s,
      pointera_en_i => pointera_en_s,
      pointerb_i    => pointerb_i_s,
      pointerb_o    => pointerb_o_s,
      pointerb_en_i => pointerb_en_s,
      fifo_status_o => fifo_status_s
    );

    process(clk_i)
    begin
      if rising_edge(clk_i) then
        if head_ena_i_s = '1' then
          abort_pointer_s  <= pointera_o_s;
        end if;
        if meta_enb_i_s = '1'  then
          repeat_pointer_s <= end_pointer_s + 1;
        end if;
      end if;
    end process;

  pointera_i_s  <= abort_pointer_s;
  pointera_en_s <= '1'             when abort_i = '1' else '0';

  pointerb_i_s  <= end_pointer_s + 1 when flush_i  = '1' else
                   repeat_pointer_s  when repeat_i = '1' else
                   (others=>'0');

  pointerb_en_s <= '1'             when flush_i = '1' else
                   '1'             when repeat_i = '1' else
                   '0';


  m_tlast_s <= '1' when pointerb_o_s = end_pointer_s else '0';
  m_tlast_o <= m_tlast_s;

end behavioral;
