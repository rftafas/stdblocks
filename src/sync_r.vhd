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
library sync_lib;
    use sync_lib.sync_pkg.all;


entity sync_r is
    generic (
            stages  : integer := 2
    );
    port (
        mclk_i  : in  std_logic;
        rst_i   : in  std_logic;
        din     : in  std_logic;
        dout    : out std_logic;
        );
end sync_r;

architecture behavioral of sync_r is

begin

    process(mclk_i,rst_i)
      variable reg_v : std_logic_vector(stages-1 downto 0) := (others=>'0');
    begin
      if rst_i = '0' then
        reg_v := (others => '0');
        dout  <= '0';
      elsif rising_edge(mclk_i) then
        reg_v(stages-1 downto 0) := reg_v(stages-2 downto 0) & din;
        dout <= reg_v(stages-1);
      end if;
     end process;

end behavioral;
