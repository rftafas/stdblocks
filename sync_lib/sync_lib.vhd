library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;
  use IEEE.math_real.all;

package sync_lib is

  component sync_r
    generic (
      stages : integer := 2
    );
    port (
      rst_i  : in  std_logic;
      mclk_i : in  std_logic;
      din    : in  std_logic;
      dout   : out std_logic
    );
  end component sync_r;

  component det_down
    port (
      rst_i  : in  std_logic;
      mclk_i : in  std_logic;
      din    : in  std_logic;
      dout   : out std_logic
    );
  end component det_down;

  component det_up
    port (
      rst_i  : in  std_logic;
      mclk_i : in  std_logic;
      din    : in  std_logic;
      dout   : out std_logic
    );
  end component det_up;

  component det_updown
    port (
      mclk_i : in  std_logic;
      rst_i  : in  std_logic;
      din    : in  std_logic;
      dout   : out std_logic
    );
  end component det_updown;


  component pulse_align
    generic (
      port_size : integer := 8
    );
    port (
      rst_i  : in  std_logic;
      mclk_i : in  std_logic;
      en_i   : in  std_logic_vector(port_size-1 downto 0);
      en_o   : out std_logic_vector(port_size-1 downto 0)
    );
  end component pulse_align;

  component async_stretch
    port (
      slowclk_i : in  std_logic;
      fastclk_i : in  std_logic;
      din       : in  std_logic;
      dout      : out std_logic
    );
  end component async_stretch;


end package;

package body sync_lib is

end package body;
