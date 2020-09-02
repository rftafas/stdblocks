----------------------------------------------------------------------------------
-- timer_lib  by Ricardo F Tafas Jr
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
	use IEEE.math_real.all;

entity long_counter_cell is
  generic (
    sr_size : integer   :=  32
  );
  port (
    rst_i       : in  std_logic;
    mclk_i      : in  std_logic;
    enable_i    : in  std_logic;
    enable_o    : out std_logic
  );
end long_counter_cell;

architecture behavioral of long_counter_cell is

  signal timer_sr : std_logic_vector(sr_number-1 downto 0) := (0=>'1', others=>'0');

begin

  cell_p : process(all)
  begin
    if mclk_i = '1' and mclk_i'event then
      if enable_i = '1' then
        timer_sr <= timer_sr sll 1;
      end if;
    end if;
  end process;

  enable_o <= timer_sr(sr_number-1) and enable_i;

end behavioral;
