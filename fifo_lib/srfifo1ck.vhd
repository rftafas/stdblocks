----------------------------------------------------------------------------------
-- SPI-AXI-Master  by Ricardo F Tafas Jr
-- For this IP, CPOL = 0 and CPHA = 0. SPI Master must be configured accordingly.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library expert;
    use expert.std_logic_gray.all;
library stdblocks;
  use stdblocks.ram_lib.all;
  use stdblocks.fifo_lib.all;

entity srfifo1ck is
    generic (
      fifo_size : integer := 8;
      port_size : integer := 8
    );
    port (
      --general
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      dataa_i     : in  std_logic_vector(port_size-1 downto 0);
      datab_o     : out std_logic_vector(port_size-1 downto 0);
      ena_i       : in  std_logic;
      enb_i       : in  std_logic;
      --
      fifo_status_o : out fifo_status
    );
end srfifo1ck;

architecture behavioral of srfifo1ck is

  constant debug       : boolean := false;
  constant fifo_length : integer := 2**fifo_size;
  constant addr_null   : std_logic_vector(fifo_size-1 downto 0) := (others=>'0');

  signal addro_cnt     : integer range 0 to fifo_length;

  signal fifo_mq      : fifo_state_t := steady_st;

  type srmem_t is array (fifo_length downto 0) of std_logic_vector(port_size-1 downto 0);
  signal data_sr       : srmem_t := (others=>(others=>'0'));


begin

  --Input
  data_sr(0) <= dataa_i;
  input_p : process(clk_i)
  begin
    if clk_i'event and clk_i = '1' then
      if ena_i = '1' then
        data_sr(data_sr'high downto 1) <= data_sr(data_sr'high-1 downto 0);
      end if;
    end if;
  end process;

  --output
  output_p : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      addro_cnt <= 0;
    elsif clk_i'event and clk_i = '1' then
      if ena_i = '1' and enb_i = '0' then
        if addro_cnt < fifo_length then
          addro_cnt    <= addro_cnt + 1;
        end if;
      elsif ena_i = '0' and enb_i = '1' then
        if addro_cnt > 0 then
          addro_cnt    <= addro_cnt - 1;
        end if;
      end if;
    end if;
  end process;

  datab_o <= data_sr(addro_cnt);

  control_p : process(clk_i, rst_i)
    variable addro_v : std_logic_vector(fifo_size-1 downto 0);
  begin
    if rst_i = '1' then
      fifo_mq <= empty_st;
    elsif clk_i'event and clk_i = '1' then
      addro_v := std_logic_vector(to_signed(addro_cnt,fifo_size));
      fifo_mq <= sync_state(ena_i,enb_i,addro_v,addr_null,fifo_mq);
    end if;
  end process;

  --Fifo state decode. must be optmized for state machine in the future.
  fifo_status_o.overflow  <= '1' when fifo_mq = overflow_st  else '0';
  fifo_status_o.full      <= '1' when fifo_mq = full_st      else '0';
  fifo_status_o.gofull    <= '1' when fifo_mq = gofull_st    else '0';
  fifo_status_o.steady    <= '1' when fifo_mq = steady_st    else '0';
  fifo_status_o.goempty   <= '1' when fifo_mq = goempty_st   else '0';
  fifo_status_o.empty     <= '1' when fifo_mq = empty_st     else '0';
  fifo_status_o.underflow <= '1' when fifo_mq = underflow_st else '0';

  debug_gen : if debug generate
    signal delta_s : std_logic_vector(addr_null'range);
  begin
    delta_s <= std_logic_vector(to_signed(addro_cnt,fifo_size));
  end generate;

end behavioral;
