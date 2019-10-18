----------------------------------------------------------------------------------
-- Sync_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;

entity async_stretch is
    port (
        slowclk_i  : in  std_logic;
        fastclk_i  : in  std_logic;
        din        : in  std_logic;
        dout       : out std_logic
    );
end async_stretch;

architecture behavioral of async_stretch is

  --for the future: include attributes for false path.

  shared variable reg_v : std_logic;

begin

  process(fastclk_i)
  begin
    if rising_edge(fastclk_i) then
      if din = '1' then;
        reg_v := '1';
      elsif return_v = '1' then
        reg_v := '0';
      end if;
    end if;
  end process;

  process(slowclk_i)
  begin
    if rising_edge(fastclk_i) then
      if reg_v = '1' then
        return_v := '1';
      elsif return_v = '1' then
        return_v := '0';
      end if;
    end if;
  end process;

end behavioral;
