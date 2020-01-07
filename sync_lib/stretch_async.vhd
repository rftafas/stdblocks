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

  signal reg_forward_s : std_logic := '0';
  signal reg_out_s     : std_logic := '0';
  signal reg_meta_s    : std_logic := '0';
  signal reg_back_s    : std_logic_vector(1 downto 0) := (others=>'0');

begin

  process(fastclk_i)
  begin
    if rising_edge(fastclk_i) then
      reg_back_s <= reg_back_s(0) & reg_out_s;
      if din = '1' then
        reg_forward_s <= '1';
      elsif reg_back_s(1) = '1' then
        reg_forward_s <= '0';
      end if;
    end if;
  end process;

  process(slowclk_i)
  begin
    if rising_edge(slowclk_i) then
      if reg_out_s = '1' then
        reg_out_s  <= '0';
        reg_meta_s <= '0';
      else
        reg_meta_s <= reg_forward_s;
        reg_out_s  <= reg_meta_s;
      end if;
    end if;
  end process;

  dout <= reg_out_s;

end behavioral;
