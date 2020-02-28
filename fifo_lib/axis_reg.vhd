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

entity axis_reg is
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
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;

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
end axis_reg;

architecture behavioral of axis_reg is



begin

process()
begin


if busy_s then
elsif en_i_s = '1' then
  s_tdata_o <=



end process;

end behavioral;
