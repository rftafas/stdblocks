----------------------------------------------------------------------------------
-- Sync_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
-- This block removes metastability from any asynchronous signal.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
library stdblocks;
    use stdblocks.sync_lib.all;


entity sync_r is
    generic (
      stages  : integer := 2
    );
    port (
      rst_i   : in  std_logic;
      mclk_i  : in  std_logic;
      din     : in  std_logic;
      dout    : out std_logic
    );
end sync_r;

architecture behavioral of sync_r is

  signal reg_s : std_logic_vector(stages-1 downto 0) := (others=>'0');

begin

    process(mclk_i,rst_i)

    begin
      if rst_i = '1' then
        reg_s <= (others => '0');
      elsif rising_edge(mclk_i) then
        reg_s <= reg_s(stages-2 downto 0) & din;
      end if;
     end process;
     dout  <= reg_s(stages-1);

end behavioral;
