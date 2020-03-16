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
      ram_type  : fifo_t := blockram;
      port_size : integer := 8;
      fifo_size : integer := 8
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
end stdfifo1ck;

architecture behavioral of stdfifo1ck is

  constant debug : boolean := false;

  signal addri_cnt    : std_logic_vector(fifo_size-1 downto 0) := (others=>'0');
  signal addro_cnt    : std_logic_vector(fifo_size-1 downto 0) := (others=>'0');
  signal fifo_mq      : fifo_state_t := empty_st;

  signal ena_i_s      : std_logic;
  signal enb_i_s      : std_logic;

begin

  --Input
  ena_i_s <= '0' when fifo_mq = full_st else
             '0' when fifo_mq = overflow_st else
             ena_i;

  input_p : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      addri_cnt <= (others=>'0');
    elsif clk_i'event and clk_i = '1' then
      if ena_i_s = '1' then
        addri_cnt    <= addri_cnt + 1;
      end if;
    end if;
  end process;

  --output
  enb_i_s <= '0'    when fifo_mq = underflow_st else
             '0'    when fifo_mq = n_empty_st   else
             ena_i  when fifo_mq = empty_st     else
             enb_i;

  output_p : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      addro_cnt <= (others=>'0');
    elsif clk_i'event and clk_i = '1' then
      if enb_i_s = '1' then
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


  dp_ram_u : dp_ram
    generic map (
      ram_type  => fifo_type_dec(ram_type),
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
      wea_i   => ena_i,
      enb_i   => enb_i_s
    );

  fifo_status_o.overflow  <= '1' when fifo_mq = overflow_st  else '0';
  fifo_status_o.full      <= '1' when fifo_mq = full_st      else '0';
  fifo_status_o.gofull    <= '1' when fifo_mq = gofull_st    else '0';
  fifo_status_o.steady    <= '1' when fifo_mq = steady_st    else '0';
  fifo_status_o.goempty   <= '1' when fifo_mq = goempty_st   else
                             '1' when fifo_mq = n_empty_st   else
                             '0';
  fifo_status_o.empty     <= '1' when fifo_mq = empty_st     else '0';
  fifo_status_o.underflow <= '1' when fifo_mq = underflow_st else '0';

  debug_gen : if debug generate
    signal delta_s : std_logic_vector(addri_cnt'range);
  begin
    delta_s <= addri_cnt - addro_cnt;
  end generate;


end behavioral;
