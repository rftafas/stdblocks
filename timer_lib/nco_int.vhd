----------------------------------------------------------------------------------
-- Sync_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity nco_int is
    port (
      rst_i     : in  std_logic;
      mclk_i    : in  std_logic;
      scaler_i  : in  std_logic;
      n_value_i : in  std_logic_vector;
      clkout_o  : out std_logic
    );
end nco_int;

architecture behavioral of nco_int is

  constant NCO_size_c : integer := n_value_i'lentgh;
  signal   nco_s      : unsigned(NCO_size_c-1 downto 0) := (others=>'0');

begin

  nco_p : process(mclk_i, rst_i)
  begin
    if rst_i = '1' then
      nco_s  <= (others=>'0');
    elsif rising_edge(mclk_i) then
      if scaler_i = '1' then
        nco_s <= nco_s + n_value_i;
      end if;
    end if;
   end process;

   clkout_o <= nco_s(nco_s'high);

end behavioral;
