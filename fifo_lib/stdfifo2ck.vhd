----------------------------------------------------------------------------------
-- fifo_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
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

      fifo_status_a_o : out fifo_status;
      fifo_status_b_o : out fifo_status
    );
end stdfifo2ck;

architecture behavioral of stdfifo2ck is

  constant debug        : boolean := false;

  signal input_fifo_mq  : fifo_state_t := steady_st;
  signal output_fifo_mq : fifo_state_t := steady_st;

  signal addri_cnt      : gray_vector(fifo_size-1 downto 0);
  signal addro_cnt      : gray_vector(fifo_size-1 downto 0);

  signal addri_cnt_s    : gray_vector(fifo_size-1 downto 0);
  signal addro_cnt_s    : gray_vector(fifo_size-1 downto 0);

  signal ena_i_s        : std_logic;
  signal ena_sync_s     : std_logic;
  signal ena_up_s       : std_logic;

  signal enb_i_s        : std_logic;
  signal enb_sync_s     : std_logic;
  signal enb_up_s       : std_logic;

  signal underflow_s    : std_logic;
  signal overflow_s     : std_logic;

begin

  --Input
  enb_st_u : stretch_async
  port map (
    clkin_i  => clkb_i,
    clkout_i => clka_i,
    din      => enb_i,
    dout     => enb_sync_s
  );

  enb_det_u : det_up
    port map (
      mclk_i => clkb_i,
      rst_i  => '0',
      din    => enb_sync_s,
      dout   => enb_up_s
    );

  ena_i_s <= '0' when input_fifo_mq = full_st else
             '0' when input_fifo_mq = overflow_st else
             ena_i;

  input_p : process(clka_i, rsta_i)
    variable addri_v : std_logic_vector(addri_cnt'range);
    variable addro_v : std_logic_vector(addro_cnt'range);
  begin
    if rsta_i = '1' then
      addri_cnt     <= (others=>'0');
      input_fifo_mq <= empty_st;
    elsif clka_i'event and clka_i = '1' then
      if ena_i_s = '1' then
        addri_cnt    <= addri_cnt + 1;
      end if;
      addri_v       := to_std_logic_vector(addri_cnt);
      addro_v       := to_std_logic_vector(addro_cnt_s);
      input_fifo_mq <= async_state(ena_i,enb_up_s,addri_v,addro_v,input_fifo_mq);
    end if;
  end process;

  --output
  --fall through: we need to get first data as soon as we have it.
  ena_st_u : async_stretch
  port map (
    clkin_i  => clka_i,
    clkout_i => clkb_i,
    din      => ena_i,
    dout     => ena_sync_s
  );

  ena_det_u : det_up
    port map (
      mclk_i => clkb_i,
      rst_i  => '0',
      din    => ena_sync_s,
      dout   => ena_up_s
    );

  enb_i_s <= '0'      when output_fifo_mq = underflow_st else
             '1'      when output_fifo_mq = f_empty_st   else
             '0'      when output_fifo_mq = t_empty_st   else
             '0'      when output_fifo_mq = empty_st     else
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
      output_fifo_mq <= async_state(ena_up_s,enb_i,addri_v,addro_v,output_fifo_mq);
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
      addrb_i => to_std_logic_vector(addro_cnt),
      datab_o => datab_o,
      ena_i   => '1',
      wea_i   => ena_i_s,
      enb_i   => enb_i_s
    );

    fifo_status_a_o <= fifo_status_f(input_fifo_mq);
    fifo_status_b_o <= fifo_status_f(output_fifo_mq);

  debug_gen : if debug generate
    signal delta_s : unsigned(addri_cnt'range);
  begin
    delta_s <= to_unsigned(addri_cnt - addro_cnt);
  end generate;

end behavioral;
