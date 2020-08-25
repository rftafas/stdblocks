----------------------------------------------------------------------------------
-- timer_lib  by Ricardo F Tafas Jr
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library stdblocks;
    use stdblocks.timer_lib.all;

entity long_counter is
  generic (
    Fref_hz : frequency := 100 MHz;
    Tout_s  : time      :=  10 sec;
    sr_size : integer   :=  32
  );
  port (
    rst_i       : in  std_logic;
    mclk_i      : in  std_logic;
    enable_i    : in  std_logic;
    enable_o    : out std_logic
  );
end long_counter;

architecture behavioral of long_counter is

  constant sr_number : integer := q_calc(Tout_c,Fref_c,sr_size);

  type shift_vector is array (NATURAL RANGE <>) of std_logic_vector(sr_size-1 downto 0);
  signal timer_sr : shift_vector(sr_number-1 downto 0) := (others=>(0=>'1', others=>'0'));

  signal sr_en    : std_logic_vector(sr_number-1 downto 0) := (others=>'0');
  signal out_en   : std_logic_vector(sr_number-1 downto 0) := (others=>'0');

begin

  for j in 0 to sr_number-1 generate
    cell_u : long_counter_cell
      generic map(
        sr_size => sr_size
      )
      port map (
        rst_i    => rst_i,
        mclk_i   => mclk_i,
        enable_i => sr_en(j),
        enable_o => out_en(j)
      );
  end generate;

  sr_en(0) <= enable_i;

  en_gen : for j in 1 to sr_number-1 generate
    sr_en(j) <= out_en(j-1);
  end generate;

  enable_o <= out_en(sr_number-1);

end behavioral;
