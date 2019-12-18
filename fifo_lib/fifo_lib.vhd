library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;
  use IEEE.math_real.all;
library expert;
  use expert.std_logic_expert.all;
library stdblocks;
    use stdblocks.ram_lib.all;

package fifo_lib is

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
      overflowa_o  : out std_logic;
      fulla_o      : out std_logic;
      gofulla_o    : out std_logic;
      steadya_o    : out std_logic;
      goemptya_o   : out std_logic;
      emptya_o     : out std_logic;
      underflowa_o : out std_logic;
      overflowb_o  : out std_logic;
      fullb_o      : out std_logic;
      gofullb_o    : out std_logic;
      steadyb_o    : out std_logic;
      goemptyb_o   : out std_logic;
      emptyb_o     : out std_logic;
      underflowb_o : out std_logic
    );
  end component stdfifo2ck;

  component stdfifo1ck
    generic (
      ram_type  : mem_t;
      port_size : integer := 8;
      fifo_size : integer := 8
    );
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      dataa_i     : in  std_logic_vector(port_size-1 downto 0);
      datab_o     : out std_logic_vector(port_size-1 downto 0);
      ena_i       : in  std_logic;
      enb_i       : in  std_logic;
      oeb_i       : in  std_logic;
      overflow_o  : out std_logic;
      full_o      : out std_logic;
      gofull_o    : out std_logic;
      steady_o    : out std_logic;
      goempty_o   : out std_logic;
      empty_o     : out std_logic;
      underflow_o : out std_logic
    );
  end component stdfifo1ck;

  component srfifo1ck
    generic (
      port_size : integer := 8;
      fifo_size : integer := 8
    );
    port (
      clka_i      : in  std_logic;
      rsta_i      : in  std_logic;
      clkb_i      : in  std_logic;
      rstb_i      : in  std_logic;
      dataa_i     : in  std_logic_vector(port_size-1 downto 0);
      datab_o     : out std_logic_vector(port_size-1 downto 0);
      ena_i       : in  std_logic;
      enb_i       : in  std_logic;
      oeb_i       : in  std_logic;
      overflow_o  : out std_logic;
      full_o      : out std_logic;
      gofull_o    : out std_logic;
      steady_o    : out std_logic;
      goempty_o   : out std_logic;
      empty_o     : out std_logic;
      underflow_o : out std_logic
    );
  end component srfifo1ck;

  type fifo_state_t is (underflow_st, empty_st, goempty_st, steady_st, gofull_st, full_st, overflow_st);
  function sync_state (
    ien : std_logic; oen : std_logic; iaddr : std_logic_vector; oaddr : std_logic_vector; current_state : fifo_state_t
  ) return fifo_state_t;

end package;

package body fifo_lib is

  function sync_state (
    ien : std_logic; oen : std_logic; iaddr : std_logic_vector; oaddr : std_logic_vector; current_state : fifo_state_t
  ) return fifo_state_t is
    variable tmp         : fifo_state_t := steady_st;
    variable delta       : integer      := 0;
    variable fifo_length : integer      := 2**iaddr'length;
  begin
    tmp   := current_state;
    delta := to_integer(signed(oaddr) - signed(iaddr));
		case current_state is
      when empty_st =>
        if oen = '1' then
          if delta = -1 then
            tmp :=  underflow_st;
          end if;
        elsif delta = -2 then
          tmp := goempty_st;
        end if;

      when goempty_st =>
        if delta = -1 and oen = '1' then
          tmp :=  empty_st;
        elsif delta = -fifo_length/4 then
          tmp:= steady_st;
        end if;

      when steady_st =>
        if    delta =  fifo_length/4 then
          tmp := gofull_st;
        elsif delta = -fifo_length/4 then
          tmp:= goempty_st;
        end if;

      when gofull_st =>
        if delta = 2 and ien = '1' then
          tmp :=  full_st;
        elsif delta = fifo_length/4 then
          tmp:= steady_st;
        end if;
      when full_st =>
        if ien = '1' then
          if delta = 0 then
            tmp :=  overflow_st;
          end if;
        elsif delta = 2 then
          tmp := gofull_st;
        end if;
      when others =>
        tmp := steady_st;
    end case;
    return tmp;
	end sync_state;


end package body;
