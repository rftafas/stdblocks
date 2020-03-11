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
      ram_type     :  fifo_t := blockram;
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

  constant input_vector_size  : integer := s_tdata_i'length + s_tuser_i'length + s_tdest_i'length;
  constant internal_port_size : integer := get_data_size (tdata_size,tdest_size,tuser_size,tuser_enable,tdest_enable);

  signal   fifo_data_i_s : std_logic_vector(input_vector_size-1 downto 0);
  signal   fifo_data_o_s : std_logic_vector(input_vector_size-1 downto 0);

  signal enb_i_s         : std_logic;
  signal ena_i_s         : std_logic;
  signal clk_s           : std_logic;
  signal m_tlast_o_s     : std_logic;

  signal fifo_status_a_s : fifo_status;
  signal fifo_status_b_s : fifo_status;
  
  signal counter_s       : integer := 0;
  signal has_packet_s    : std_logic;

begin

  --fifo data. we do this to NOT load forever 0 into ram. maybe synthesis
  --will do its part and trim. maybe not. we resolve it ourselves.
  fifo_data_i_s   <= s_tlast_i & s_tdest_i & s_tuser_i & s_tdata_i;
  m_tdata_o       <= fifo_data_o_s(s_tdata_i'range);
  m_tuser_o       <= fifo_data_o_s(tdata_size+tuser_size-1 downto tdata_size);
  m_tdest_o       <= fifo_data_o_s(tdata_size+tuser_size+tdest_size-1 downto tdata_size+tuser_size);
  m_tlast_o_s     <= fifo_data_o_s(fifo_data_o_s'high);
  m_tlast_o       <= m_tlast_o_s;
  
  s_tready_o      <= not fifo_status_a_s.full;
  ena_i_s         <= not fifo_status_a_s.full and s_tvalid_i;

  m_tvalid_o      <= not fifo_status_b_s.empty;
  enb_i_s         <= not fifo_status_b_s.empty and m_tready_i;

  fifo_status_a_o <= fifo_status_a_s;
  fifo_status_b_o <= fifo_status_b_s;

  sync_fifo_gen : if sync_mode generate
    clk_s <= clka_i;
    fifo_status_b_s <= fifo_status_a_s;
    fifo_u : stdfifo1ck
      generic map(
        ram_type  => ram_type,
        fifo_size => fifo_size,
        port_size => internal_port_size
      )
      port map(
        clk_i   => clka_i,
        rst_i   => rsta_i,
        dataa_i  => fifo_data_i_s(fifo_size-1 downto 0),
        datab_o  => fifo_data_o_s(fifo_size-1 downto 0),
        ena_i    => ena_i_s,
        enb_i    => enb_i_s,

        fifo_status_o => fifo_status_a_s
      );
      
  else generate
  
    clk_s <= clkb_i;
    fifo_u : stdfifo2ck
      generic map(
        ram_type  => ram_type,
        fifo_size => fifo_size,
        port_size => internal_port_size
      )
      port map(
        --general
        clka_i   => clka_i,
        rsta_i   => rsta_i,
        clkb_i   => clkb_i,
        rstb_i   => rstb_i,
        dataa_i  => fifo_data_i_s(fifo_size-1 downto 0),
        datab_o  => fifo_data_o_s(fifo_size-1 downto 0),
        ena_i    => ena_i_s,
        enb_i    => enb_i_s,

        fifo_status_a_o => fifo_status_a_s,
        fifo_status_b_o => fifo_status_b_s
      );
  end generate;


  packet_proc : process(clk_s)
  begin
    if rising_edge(clk_s) then
        if m_tlast_o_s = '1' and s_tlast_i = '0' then
          counter_s <= counter_s - 1;
        elsif m_tlast_o_s = '1' and s_tlast_i = '0' then
          counter_s <= counter_s + 1;
        end if;
        if counter_s /= 0 then
          has_packet_s <= '1';
        else
          has_packet_s <= '0';
        end if;
    end if;
  end process;


end behavioral;
