----------------------------------------------------------------------------------
-- timer_lib  by Ricardo F Tafas Jr
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library stdblocks;
    use stdblocks.sync_lib.all;

entity adpll is
  generic (
    Fref_hz        : real    := 100000000.0000;
    Fout_hz         : real    :=   1000000.0000;
    Resolution_hz   : real    :=        20.0000;
  );
  port (
    rst_i    : in  std_logic;
    mclk_i   : in  std_logic;
    clkin_i  : in  std_logic;
    clkout_o : out std_logic
  );
end adpll;

architecture behavioral of adpll is

  constant nco_size_c   : integer := nco_size(Fref_hz,Resolution_hz)

  signal clkout_s  : std_logic;
  signal clkout_en : std_logic;
  signal clkin_en  : std_logic;
  signal up_s      : std_logic;
  signal down_s    : std_logic;

  signal all1_c    : unsigned(nco_size_c-1 downto 0) := (others=>'1');
  signal all0_c    : unsigned(nco_size_c-1 downto 0) := (others=>'0');
  signal n_value_s : unsigned(nco_size_c-1 downto 0) := (others=>'0');

begin


  control_p : process(all)
  begin
    if rst_i = '1' then
    elsif mclk_i = '1' and mclk_i'event then
      if up_s then
        if n_value_s /= all1_c then
          n_value_s <= n_value_s + 1;
        end if;
      elsif down_s then
        if n_value_s /= all0_c then
          n_value_s <= n_value_s - 1;
        end if;
      end if;
    end if;
  end process;

  nco_u : nco
      generic map (
        Fref_hz         => Fref_hz/2**scale_factor,
        Fout_hz         => Fout_hz,
        Resolution_hz   => Resolution_hz,
        use_scaler      => use_scale_f(scale_factor),
        adjustable_freq => true
      );
      port map (
        rst_i     => rst_i,
        mclk_i    => mclk_i,
        scaler_i  => '1',
        n_value_i => n_value_s,
        clkout_o  => clkout_s
      );

  clkout_u : det_up port map (rst_i,mclk_i,clkout_s,clkout_en);
  clkin_u  : det_up port map (rst_i,mclk_i, clkin_i, clkin_en);
  up_s   <= clkout_en and not clkin_en;
  down_s <= not clkout_en and clkin_en;

end behavioral;
