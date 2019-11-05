library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;

package ram_lib is

  type mem_t is ("block", "ultra", "registers", "distributed");
  attribute ram_style : string;

  component tdp_ram
    generic (
      ram_type : mem_t
    );
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

  component dp_ram
    generic (
      ram_type : mem_t
    );
    port (
      clka_i  : in  std_logic;
      rsta_i  : in  std_logic;
      clkb_i  : in  std_logic;
      rstb_i  : in  std_logic;
      addra_i : in  std_logic_vector;
      dataa_i : in  std_logic_vector;
      addrb_i : in  std_logic_vector;
      datab_o : out std_logic_vector;
      ena_i   : in  std_logic;
      enb_i   : in  std_logic;
      oeb_i   : in  std_logic;
      wea_i   : in  std_logic
    );
  end component dp_ram;


end package;

package body ram_lib is

end package body;
