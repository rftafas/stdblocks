----------------------------------------------------------------------------------
-- timer_lib  by Ricardo F Tafas Jr
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
-- ADPLL will filter any input clock and get it back to 50% duty cycle with error
-- MAX at +-1 reference clock cycle.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library stdblocks;
  use stdblocks.sync_lib.all;
  use stdblocks.timer_lib.all;

entity timer_lib_tb is
end timer_lib_tb;

architecture behavioral of timer_lib_tb is


begin



end behavioral;
