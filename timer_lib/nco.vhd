----------------------------------------------------------------------------------
-- Sync_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity nco is
    generic (
      Fref_hz        : real    := 100000000.0000;
      Fout_hz         : real    :=   1000000.0000;
      Resolution_hz   : real    :=        20.0000;
      use_scaler      : boolean :=          false;
      adjustable_freq : boolean :=          false
    );
    port (
      rst_i     : in  std_logic;
      mclk_i    : in  std_logic;
      scaler_i  : in  std_logic;
      n_value_i : in  std_logic_vector;
      clkout_o  : out std_logic
    );
end nco;

architecture behavioral of debounce is

  signal scaler_s     : std_logic;
  constant NCO_size_c : integer := nco_size(Fref_hz,Resolution_hz);

  constant nvalue_c   : unsigned(NCO_size_c-1 downto 0) := nvalue(Fref_hz,Fout_hz,NCO_size_c)
  signal   nvalue_s   : unsigned(NCO_size_c-1 downto 0) := (others=>'0');
  signal   nco_s      : unsigned(NCO_size_c-1 downto 0) := (others=>'0');

begin

  nvalue_gen : if adjustable_freq generate
    nvalue_p : process(mclk_i, rst_i)
    begin
      if rst_i = '1' then
        n_value_s  <= (others=>'0');
      elsif rising_edge(mclk_i) then
        n_value_s <= to_unsigned(n_value_i);
      end if;
    end process;

  else generate
    n_value_s <= n_value_c;

  end generate;

  scaler_s <= scaler_i when use_scaler else '1';

  nco_p : process(mclk_i, rst_i)
  begin
    if rst_i = '1' then
      nco_s  <= (others=>'0');
    elsif rising_edge(mclk_i) then
      if scaler_s = '1' then
        nco_s <= nco_s + n_value_s;
      end if;
    end if;
   end process;

   clkout_o <= nco_s(nco_s'high);

end behavioral;
