library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;
  use IEEE.math_real.all;

package sync_pkg is

  component sync_r
    generic (
      stages : integer := 2
    );
    port (
      mclk_i : in  std_logic;
      rst_i  : in  std_logic;
      din    : in  std_logic;
      dout   : out std_logic
    );
  end component sync_r;

  component det_down
    port (
      mclk_i : in  std_logic;
      rst_i  : in  std_logic;
      din    : in  std_logic;
      dout   : out std_logic
    );
  end component det_down;

  component det_up
    port (
      mclk_i : in  std_logic;
      rst_i  : in  std_logic;
      din    : in  std_logic;
      dout   : out std_logic
    );
  end component det_up;


end package;

package body sync_pkg is

end package body;
