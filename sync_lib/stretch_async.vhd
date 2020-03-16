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
        clkin_i    : in  std_logic;
        clkout_i   : in  std_logic;
        din        : in  std_logic;
        dout       : out std_logic
    );
end async_stretch;

architecture behavioral of async_stretch is

  --for the future: include attributes for false path.

  signal dout_s        : std_logic := '0';
  signal reg_forward_s : std_logic := '0';
  signal reg_out_s     : std_logic_vector(2 downto 0) := (others=>'0');
  signal reg_back_s    : std_logic_vector(1 downto 0) := (others=>'0');

begin

  process(clkin_i)
  begin
    if rising_edge(clkin_i) then
      reg_back_s <= reg_back_s(0) & reg_out_s(1);
      if din = '1' then
        reg_forward_s <= '1';
      elsif reg_back_s(1) = '1' then
        reg_forward_s <= '0';
      end if;
    end if;
  end process;

  process(clkout_i)
    variable lock_v : boolean := false;
  begin
    if rising_edge(clkout_i) then
      reg_out_s  <= reg_out_s(1 downto 0) & reg_forward_s;
    end if;
  end process;

  dout <= reg_out_s(2) and not reg_out_s(1);

end behavioral;
