----------------------------------------------------------------------------------
-- Sync_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;

entity det_down is
    port (
        mclk_i  : in  std_logic;
        rst_i   : in  std_logic;
        din     : in  std_logic;
        dout    : out std_logic
    );
end det_down;

architecture behavioral of det_down is

begin

    process(mclk_i, rst_i)
      variable reg_v : std_logic_vector(1 downto 0);
    begin
      if rst_i = '1' then
        reg_v := (others => '0');
        dout  <= '0';
      elsif rising_edge(mclk_i) then
        reg_v(1 downto 0) := reg_v(0) & din;
      end if;
      dout <= not reg_v(0) and reg_v(1);
     end process;

end behavioral;
