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
end nco_int;

architecture behavioral of debounce is

  signal scaler_s     : std_logic;
  constant NCO_size_c : integer := nco_size(Fref_hz,Resolution_hz);

  constant nvalue_c   : unsigned(NCO_size_c-1 downto 0) := nvalue(Fref_hz,Fout_hz,NCO_size_c)
  signal   nvalue_s   : unsigned(NCO_size_c-1 downto 0) := (others=>'0');
  signal   nco_s      : unsigned(NCO_size_c-1 downto 0) := (others=>'0');

begin

  nco_u : nco_int
      generic map (
        Fref_hz         => Fref_hz,
        Fout_hz         => Fout_hz,
        Resolution_hz   => Resolution_hz,
        use_scaler      => use_scaler,
        adjustable_freq => adjustable_freq
      );
      port map (
        rst_i     => rst_i,
        mclk_i    => mclk_i,
        scaler_i  => scaler_i,
        n_value_i => n_value_i,
        clkout_o  => clkout_o
      );

end behavioral;
