----------------------------------------------------------------------------------
-- Sync_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
library sync_lib;
    use sync_lib.sync_pkg.all;

entity det_up is
    port (
      rst_i   : in  std_logic;
      mclk_i  : in  std_logic;
      din     : in  std_logic;
      dout    : out std_logic
    );
end det_up;

architecture behavioral of det_up is

begin

    process(mclk_i, rst_i)
      variable reg_v : std_logic_vector(1 downto 0);
    begin
      if rst_i = '0' then
        reg_v := (others => '0');
      elsif rising_edge(mclk_i) then
        reg_v(1 downto 0) := reg_v(0) & din;
      end if;
      dout <= reg_v(0) and not reg_v(1);
     end process;

end behavioral;
