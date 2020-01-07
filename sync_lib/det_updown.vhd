----------------------------------------------------------------------------------
-- Sync_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;

entity det_updown is
    port (
        mclk_i  : in  std_logic;
        rst_i   : in  std_logic;
        din     : in  std_logic;
        dout    : out std_logic
    );
end det_updown;

architecture behavioral of det_updown is

  signal reg_s : std_logic;

begin

    process(mclk_i, rst_i)
    begin
      if rst_i = '1' then
        reg_s <= '0';
      elsif rising_edge(mclk_i) then
        reg_s <= din;
      end if;
    end process;

    dout <= reg_s xor din;

end behavioral;
