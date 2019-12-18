----------------------------------------------------------------------------------
-- SPI-AXI-Master  by Ricardo F Tafas Jr
-- For this IP, CPOL = 0 and CPHA = 0. SPI Master must be configured accordingly.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library expert;
    use expert.std_logic_expert.all;
library stdblocks;
    use stdblocks.ram_lib.all;
library stdblocks;
    use stdblocks.fifo_lib.all;


entity stdfifo1ck is
    generic (
      ram_type  : mem_t := blockram;
      port_size : integer := 8;
      fifo_size : integer := 8
    );
    port (
      --general
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      dataa_i     : in  std_logic_vector;
      datab_o     : out std_logic_vector;
      ena_i       : in  std_logic;
      enb_i       : in  std_logic;
      oeb_i       : in  std_logic;
      --
      overflow_o  : out std_logic;
      full_o      : out std_logic;
      gofull_o    : out std_logic;
      steady_o    : out std_logic;
      goempty_o   : out std_logic;
      empty_o     : out std_logic;
      underflow_o : out std_logic
    );
end stdfifo1ck;

architecture behavioral of stdfifo1ck is

  constant debug : boolean := true;

  signal addri_cnt   : std_logic_vector(fifo_size-1 downto 0);
  signal addro_cnt   : std_logic_vector(fifo_size-1 downto 0);
  signal fifo_mq     : fifo_state_t := steady_st;

  signal enb_s : std_logic;

begin

  --Input
  input_p : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      addri_cnt <= (others=>'0');
    elsif clk_i'event and clk_i = '1' then
      if ena_i = '1' then
        addri_cnt    <= addri_cnt + 1;
      end if;
    end if;
  end process;

  --output
  output_p : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      addro_cnt <= (others=>'0');
    elsif clk_i'event and clk_i = '1' then
      if enb_i = '1' then
        addro_cnt    <= addro_cnt + 1;
      end if;
    end if;
  end process;

  control_p : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      fifo_mq <= empty_st;
    elsif clk_i'event and clk_i = '1' then
      fifo_mq <= sync_state(ena_i,enb_i,addri_cnt,addro_cnt,fifo_mq);
    end if;
  end process;

  overflow_o  <= '1' when fifo_mq = overflow_st  else '0';
  full_o      <= '1' when fifo_mq = full_st      else '0';
  gofull_o    <= '1' when fifo_mq = gofull_st    else '0';
  steady_o    <= '1' when fifo_mq = steady_st    else '0';
  goempty_o   <= '1' when fifo_mq = goempty_st   else '0';
  empty_o     <= '1' when fifo_mq = empty_st     else '0';
  underflow_o <= '1' when fifo_mq = underflow_st else '0';

  enb_s <= '1'    when fifo_mq = empty_st else
           enb_i;

  dp_ram_u : dp_ram
    generic map (
      ram_type  => ram_type,
      mem_size  => fifo_size,
      port_size => port_size
    )
    port map (
      clka_i  => clk_i,
      rsta_i  => rst_i,
      clkb_i  => clk_i,
      rstb_i  => rst_i,
      addra_i => addri_cnt,
      dataa_i => dataa_i,
      addrb_i => addro_cnt,
      datab_o => datab_o,
      ena_i   => '1',
      enb_i   => '1',
      oeb_i   => oeb_i,
      wea_i   => ena_i
    );

  debug_gen : if debug generate
    signal delta_s : integer;
  begin
    delta_s <= to_integer( signed('0'&addro_cnt) - signed('0'&addri_cnt) );
  end generate;


end behavioral;
