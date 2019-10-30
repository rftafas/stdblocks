library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;
  use IEEE.math_real.all;

package ram_lib is

  type mem_t is ("block", "ultra", "registers", "distributed");
  attribute ram_style : string;


end package;

package body ram_lib is

  component tdp_ram
    port (
      clka_i  : in  std_logic;
      rsta_i  : in  std_logic;
      clkb_i  : in  std_logic;
      rstb_i  : in  std_logic;
      addra_i : in  std_logic_vector;
      addrb_i : in  std_logic_vector;
      dataa_i : in  std_logic_vector;
      datab_i : in  std_logic_vector;
      dataa_o : out std_logic_vector;
      datab_o : out std_logic_vector;
      ena_i   : in  std_logic;
      enb_i   : in  std_logic;
      oea_i   : in  std_logic;
      oeb_i   : in  std_logic;
      wea_i   : in  std_logic;
      web_i   : in  std_logic
    );
  end component tdp_ram;


end package body;
