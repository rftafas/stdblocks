----------------------------------------------------------------------------------
-- Sync_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
	use IEEE.math_real.all;
library stdblocks;
  use stdblocks.timer_lib.all;

entity nco is
    generic (
      Fref_hz         : frequency := 100 MHz;
      Fout_hz         : frequency :=  10 MHz;
      Resolution_hz   : frequency :=  20  Hz;
      use_scaler      : boolean   :=   false;
      adjustable_freq : boolean   :=   false
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
  constant NCO_size_c : integer := nco_size_calc(Fref_hz,Resolution_hz);

  constant nvalue_c   : unsigned(NCO_size_c-1 downto 0) := increment_value_calc(Fref_hz,Fout_hz,NCO_size_c);
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

  nco_u : nco_int
      port map (
        rst_i     => rst_i,
        mclk_i    => mclk_i,
        scaler_i  => scaler_s,
        n_value_i => n_value_s,
        clkout_o  => clkout_o
      );

end behavioral;
