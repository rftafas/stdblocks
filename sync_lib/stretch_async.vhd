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

  signal reg_forward_s : std_logic;
  signal reg_back_s    : std_logic;

begin

  process(fastclk_i)
    variable reg_v : std_logic_vector(1 downto 0);
  begin
    if rising_edge(fastclk_i) then
      if din = '1' then
        reg_forward_s <= '1';
      elsif reg_v(1) = '1' then
        reg_forward_s <= '0';
      end if;
      reg_v := reg_v(0) & reg_back_s;
    end if;
  end process;

  process(slowclk_i)
    variable reg_v : std_logic_vector(1 downto 0);
  begin
    if rising_edge(slowclk_i) then
      if reg_v(1) = '1' then
        reg_back_s <= '1';
      else
        reg_back_s <= '0';
      end if;
      reg_v := reg_v(0) & reg_forward_s;
    end if;
  end process;

end behavioral;
