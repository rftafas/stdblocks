----------------------------------------------------------------------------------
-- timer_lib  by Ricardo F Tafas Jr
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity precise_long_counter is
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
end precise_long_counter;

architecture behavioral of precise_long_counter is

  constant base_tmp  : real    := tout / 16.0000;
  constant sr_number : integer := q_calc(base_tmp,Fref,m);
  constant x1_c      : integer := x1_calc(tout,Fref,sr_size,sr_number);
  constant cnt_limit : integer := y_calc(Tout,Fref,sr_size,sr_number);

  type shift_vector is array (NATURAL RANGE <>) of std_logic_vector(sr_size-1 downto 0);
  signal timer_sr    : shift_vector(sr_number-1 downto 0) := (others=>(0=>'1', others=>'0'));

  signal sr_en       : std_logic_vector(sr_number-1 downto 0) := (others=>'0');
  signal out_en      : std_logic_vector(sr_number-1 downto 0) := (others=>'0');
  signal start_en    : std_logic;
  signal counter_en  : std_logic;
  signal counter_s   : integer := 0;

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

  sr_en(0) <= not counter_en;

  en_gen : for j in 1 to sr_number-1 generate
    sr_en(j) <= out_en(j-1);
  end generate;

  x1_u : long_counter_cell
    generic map(
      sr_size => x1_c
    )
    port map (
      rst_i    => rst_i,
      mclk_i   => mclk_i,
      enable_i => out_en(sr_number-1),
      enable_o => start_en
    );

    counter_p : process(all)
    begin
      if rising_edge(mclk_i) then
        if start_en = '1' then
          counter_s  <= 0;
          counter_en <= '1';
        elsif counter_s = cnt_limit-1 then
          counter_en <= '0';
          counter_s  <= 0;
        elsif counter_en = '1' then
          counter_s  <= counter_s  + 1;
        end if;
      end if;
    end process;

end behavioral;
