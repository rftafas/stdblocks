----------------------------------------------------------------------------------
-- Sync_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;

entity debounce is
    port (
        mclk_i  : in  std_logic;
        din     : in  std_logic_vector;
        dout    : out std_logic_vector
    );
end debounce;

architecture behavioral of debounce is

begin

    process(mclk_i)
      variable reg_v : std_logic_vector(15 downto 0);
    begin
      if rising_edge(mclk_i) then
        reg_v(15 downto 0) := reg_v(14 downto 0) & ( din nand reg_v(15) );
      end if;
     end process;

     dout <= reg_v(15);

end behavioral;
