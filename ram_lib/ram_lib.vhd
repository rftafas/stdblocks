library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;

package ram_lib is

  type mem_t is (blockram, ultra, registers, distributed);
  attribute ram_style : string;

  component tdp_ram
    generic (
      mem_size  : integer := 8;
      port_size : integer := 8;
      ram_type  : mem_t := blockram
    );
    port (
      clka_i  : in  std_logic;
      rsta_i  : in  std_logic;
      clkb_i  : in  std_logic;
      rstb_i  : in  std_logic;
      addra_i : in  std_logic_vector(mem_size-1 downto 0);
      addrb_i : in  std_logic_vector(mem_size-1 downto 0);
      dataa_i : in  std_logic_vector(port_size-1 downto 0);
      datab_i : in  std_logic_vector(port_size-1 downto 0);
      dataa_o : out std_logic_vector(port_size-1 downto 0);
      datab_o : out std_logic_vector(port_size-1 downto 0);
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
      mem_size  : integer := 8;
      port_size : integer := 8;
      ram_type  : mem_t := blockram
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

  function ram_type_dec ( ram_type : mem_t ) return string;

end package;

package body ram_lib is

    function ram_type_dec ( ram_type : mem_t ) return string is
        variable tmp : string;
    begin
        case ram_type is
            when blockram =>
                tmp := "block";
            when ultra =>
                tmp := "ultra";
            when registers =>
                tmp := "registers";
            when distributed =>
                tmp := "distributed";
            when others =>
                tmp := "registers";
                report "Unknown ram type. Using Flip-flops." severity warning;
        end case;
        return tmp;
    end function ram_type_dec;


end package body;
