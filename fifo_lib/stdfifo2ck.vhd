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
  use stdblocks.sync_lib.all;
  use stdblocks.ram_lib.all;
  use stdblocks.fifo_lib.all;

entity stdfifo2ck is
    generic (
      ram_type  : fifo_t := blockram;
      fifo_size : integer := 8;
      port_size : integer := 8
    );
    port (
      --general
      clka_i       : in  std_logic;
      rsta_i       : in  std_logic;
      clkb_i       : in  std_logic;
      rstb_i       : in  std_logic;
      dataa_i      : in  std_logic_vector(port_size-1 downto 0);
      datab_o      : out std_logic_vector(port_size-1 downto 0);
      ena_i        : in  std_logic;
      enb_i        : in  std_logic;
      --status_port_a
      overflowa_o  : out std_logic;
      fulla_o      : out std_logic;
      gofulla_o    : out std_logic;
      steadya_o    : out std_logic;
      goemptya_o   : out std_logic;
      emptya_o     : out std_logic;
      underflowa_o : out std_logic;
      --status_port_b
      overflowb_o  : out std_logic;
      fullb_o      : out std_logic;
      gofullb_o    : out std_logic;
      steadyb_o    : out std_logic;
      goemptyb_o   : out std_logic;
      emptyb_o     : out std_logic;
      underflowb_o : out std_logic
    );
end stdfifo2ck;

architecture behavioral of stdfifo2ck is

  signal input_fifo_mq      : fifo_state_t := steady_st;
  signal output_fifo_mq     : fifo_state_t := steady_st;

  signal addri_cnt     : gray_vector(fifo_size-1 downto 0);
  signal addro_cnt     : gray_vector(fifo_size-1 downto 0);
  signal addro_s       : gray_vector(fifo_size-1 downto 0);

  signal addri_cnt_s   : gray_vector(fifo_size-1 downto 0);
  signal addro_cnt_s   : gray_vector(fifo_size-1 downto 0);

  signal enb_s         : std_logic;
  signal enb_i_s       : std_logic;
  signal ena_i_s       : std_logic;

begin

  --Input
  ena_i_s <= '0' when input_fifo_mq = full_st else
             '0' when input_fifo_mq = overflow_st else
             ena_i;

  input_p : process(clka_i, rsta_i)
    variable addri_v : std_logic_vector(addri_cnt'range);
    variable addro_v : std_logic_vector(addro_cnt'range);
  begin
    if rsta_i = '1' then
      addri_cnt     <= (others=>'0');
      input_fifo_mq <= steady_st;
    elsif clka_i'event and clka_i = '1' then
      if ena_i_s = '1' then
        addri_cnt    <= addri_cnt + 1;
      end if;
      addri_v       := to_std_logic_vector(addri_cnt);
      addro_v       := to_std_logic_vector(addro_cnt_s);
      input_fifo_mq <= async_input_state(ena_i,addri_v,addro_v,input_fifo_mq);
    end if;
  end process;

  --output
  enb_i_s <= '0' when output_fifo_mq = empty_st else
             '0' when output_fifo_mq = underflow_st else
             enb_i;
  output_p : process(clkb_i, rstb_i)
    variable addri_v : std_logic_vector(addri_cnt'range);
    variable addro_v : std_logic_vector(addro_cnt'range);
  begin
    if rstb_i = '1' then
      addro_cnt      <= (others=>'0');
      output_fifo_mq <= empty_st;
    elsif clkb_i'event and clkb_i = '1' then
      if enb_i_s = '1' then
        addro_cnt    <= addro_cnt + 1;
      end if;
      addri_v := to_std_logic_vector(addri_cnt_s);
      addro_v := to_std_logic_vector(addro_cnt);
      output_fifo_mq <= async_output_state(enb_i,addri_v,addro_v,output_fifo_mq);
    end if;
  end process;

  --This block transfer the counters from siade A to side B and B to A.
  sync_gen : for j in fifo_size-1 downto 0 generate

    sync_a : sync_r
      generic map (
        stages => 1
      )
      port map (
        mclk_i => clka_i,
        rst_i  => '0',
        din    => addro_cnt(j),
        dout   => addro_cnt_s(j)
      );

      sync_b : sync_r
        generic map (
          stages => 1
        )
        port map (
          mclk_i => clkb_i,
          rst_i  => '0',
          din    => addri_cnt(j),
          dout   => addri_cnt_s(j)
        );

  end generate;

  --fallthrough
  addro_s <= addro_cnt  when output_fifo_mq = empty_st else
             addro_cnt + 1;
  enb_s   <= '1'    when output_fifo_mq = empty_st else
             enb_i;


  dp_ram_i : dp_ram
    generic map (
      ram_type  => fifo_type_dec(ram_type),
      mem_size  => fifo_size,
      port_size => port_size
    )
    port map (
      clka_i  => clka_i,
      rsta_i  => rsta_i,
      clkb_i  => clkb_i,
      rstb_i  => rstb_i,
      addra_i => to_std_logic_vector(addri_cnt),
      dataa_i => dataa_i,
      addrb_i => to_std_logic_vector(addro_s),
      datab_o => datab_o,
      ena_i   => ena_i,
      wea_i   => ena_i,
      enb_i   => enb_i
    );


end behavioral;
