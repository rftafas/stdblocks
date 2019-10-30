----------------------------------------------------------------------------------
-- Sync_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity debounce is
    port (
      rst_i  : in  std_logic;
      mclk_i  : in  std_logic;
      din     : in  std_logic_vector;
      dout    : out std_logic_vector
    );
end debounce;

architecture behavioral of debounce is

begin

    process(mclk_i, rst_i)
      variable reg_v : unsigned(4 downto 0);
    begin
      if rst_i = '1' then
        dout  <= '0';
        reg_v := (others=>'0');
      elsif rising_edge(mclk_i) then
        if din = '0' then
          if reg_v > 0 then
            reg_v := reg_v - 1;
          else
            dout <= '0';
          end if;
        else
          if reg_v < (reg_v'range => '1') then
            reg_v := reg_v + 1;
          else
            dout <= '1';
          end if;
        end if;
      end if;
     end process;

end behavioral;
