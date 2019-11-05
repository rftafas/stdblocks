library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;
  use IEEE.math_real.all;

package fifo_lib is

  type mem_t is ("block", "ultra", "registers", "distributed");
  attribute ram_style : string;

  component stdfifo2ck
    generic (
      ram_type  : mem_t;
      fifo_size : integer := 8
    );
    port (
      clka_i       : in  std_logic;
      rsta_i       : in  std_logic;
      clkb_i       : in  std_logic;
      rstb_i       : in  std_logic;
      dataa_i      : in  std_logic_vector;
      datab_o      : out std_logic_vector;
      ena_i        : in  std_logic;
      enb_i        : in  std_logic;
      oeb_i        : in  std_logic;
      overflowa_o  : in  std_logic;
      fulla_o      : in  std_logic;
      gofulla_o    : in  std_logic;
      steadya_o    : in  std_logic;
      goemptya_o   : in  std_logic;
      emptya_o     : in  std_logic;
      underflowa_o : in  std_logic;
      overflowb_o  : in  std_logic;
      fullb_o      : in  std_logic;
      gofullb_o    : in  std_logic;
      steadyb_o    : in  std_logic;
      goemptyb_o   : in  std_logic;
      emptyb_o     : in  std_logic;
      underflowb_o : in  std_logic
    );
  end component stdfifo2ck;

  component stdfifo1ck
    generic (
      ram_type  : mem_t;
      fifo_size : integer := 8
    );
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      dataa_i     : in  std_logic_vector;
      datab_o     : out std_logic_vector;
      ena_i       : in  std_logic;
      enb_i       : in  std_logic;
      oeb_i       : in  std_logic;
      overflow_o  : in  std_logic;
      full_o      : in  std_logic;
      gofull_o    : in  std_logic;
      steady_o    : in  std_logic;
      goempty_o   : in  std_logic;
      empty_o     : in  std_logic;
      underflow_o : in  std_logic
    );
  end component stdfifo1ck;

  component srfifo1ck
    generic (
      fifo_size : integer := 8
    );
    port (
      clka_i      : in  std_logic;
      rsta_i      : in  std_logic;
      clkb_i      : in  std_logic;
      rstb_i      : in  std_logic;
      dataa_i     : in  std_logic_vector;
      datab_o     : out std_logic_vector;
      ena_i       : in  std_logic;
      enb_i       : in  std_logic;
      oeb_i       : in  std_logic;
      overflow_o  : in  std_logic;
      full_o      : in  std_logic;
      gofull_o    : in  std_logic;
      steady_o    : in  std_logic;
      goempty_o   : in  std_logic;
      empty_o     : in  std_logic;
      underflow_o : in  std_logic
    );
  end component srfifo1ck;


end package;

package body fifo_lib is



end package body;
