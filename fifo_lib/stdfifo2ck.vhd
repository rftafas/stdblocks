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

entity stdfifo2ck is
    generic (
      ram_type  : fifo_t := "block";
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
      oeb_i        : in  std_logic;
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

  signal addri_cnt     : gray_vector(fifo_size-1 downto 0);
  signal addro_cnt     : gray_vector(fifo_size-1 downto 0);

  signal addri_cnt_s   : gray_vector(fifo_size-1 downto 0);
  signal addro_cnt_s   : gray_vector(fifo_size-1 downto 0);

  constant fifo_length : integer := 2**fifo_size;

  constant full_c      : gray_vector := to_gray_vector(   fifo_length-1,fifo_size);
  constant go_full_c   : gray_vector := to_gray_vector(fifo_length*9/10,fifo_size);
  constant steady_c    : gray_vector := to_gray_vector(fifo_length*5/10,fifo_size);
  constant go_empty_c  : gray_vector := to_gray_vector(fifo_length*1/10,fifo_size);
  constant empty_c     : gray_vector := to_gray_vector(               0,fifo_size);

  signal enb_i_s       : std_logic;
  signal ena_i_s       : std_logic;

begin

  --Input
  input_p : process(clka_i, rsta_i)
  begin
    if rsta_i = '1' then
    elsif clka_i'event and clka_i = '1' then
      if ena_i = '1' then
        addri_cnt    <= addri_cnt + 1;
      end if;
    end if;
  end process;

  --output
  input_p : process(clkb_i, rstb_i)
  begin
    if rstb_i = '1' then
    elsif clkb_i'event and clkb_i = '1' then
      if enb_i = '1' then
        addro_cnt    <= addro_cnt + 1;
      end if;
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
        din    => addro_cnt,
        dout   => addro_cnt_s
      );

      sync_b : sync_r
        generic map (
          stages => 1
        )
        port map (
          mclk_i => clkb_i,
          rst_i  => '0',
          din    => addri_cnt,
          dout   => addri_cnt_s
        );

  end generate;

  --Fifo state decode. must be optmized for state machine in the future.
  --input
  full_a_s     <= '1' when addro_cnt_s - addri_cnt = full_c    else '0';
  gofull_a_s   <= '1' when addro_cnt_s - addri_cnt > go_full_c else '0';
  steady_a_s   <= '1' when (full_a_s or gofull_a_s or go_empty_a_s or empty_a_s) = '0' else '0';
  go_empty_a_s <= '1' when addro_cnt_s - addri_cnt < go_full_c else '0';
  empty_a_s    <= '1' when addro_cnt_s - addri_cnt = empty_c   else '0';
  --output
  full_b_s     <= '1' when addro_cnt - addri_cnt_s = full_c    else '0';
  gofull_b_s   <= '1' when addro_cnt - addri_cnt_s > go_full_c else '0';
  steady_b_s   <= '1' when (full_b_s or gofull_b_s or go_empty_b_s or empty_b_s) = '0' else '0';
  go_empty_b_s <= '1' when addro_cnt - addri_cnt_s < go_full_c else '0';
  empty_b_s    <= '1' when addro_cnt - addri_cnt_s = empty_c   else '0';

  dp_ram_i : dp_ram
    generic map (
      ram_type => fifo_type_dec(ram_type)
    )
    port map (
      clka_i  => clka_i,
      rsta_i  => rsta_i,
      clkb_i  => clkb_i,
      rstb_i  => rstb_i,
      addra_i => addri_cnt,
      dataa_i => dataa_i,
      addrb_i => addro_cnt,
      datab_o => datab_o,
      ena_i   => ena_i,
      enb_i   => enb_i
    );

    --mudar para stretch para garantir que enables rpápidos sejam
    --capturados por clocks lentos.
    sync_ena : sync_r
      generic map (
        stages => 1
      )
      port map (
        mclk_i => clkb_i,
        rst_i  => '0',
        din    => ena_i,
        dout   => ena_i_s
      );

    sync_enb : sync_r
      generic map (
        stages => 1
      )
      port map (
        mclk_i => clka_i,
        rst_i  => '0',
        din    => enb_i,
        dout   => enb_i_s
      );

    --
    overflowa_o  <= full_a_s and ena_i;
    fulla_o      <= full_a_s;
    gofulla_o    <= gofull_a_s;
    steadya_o    <= steady_a_s;
    goemptya_o   <= go_empty_a_s;
    emptya_o     <= empty_a_s;
    underflowa_o <= empty_a_s and enb_i_s;
    --
    overflowb_o  <= full_b_s and ena_i_s;
    fullb_o      <= full_b_s;
    gofullb_o    <= gofull_b_s;
    steadyb_o    <= steady_b_s;
    goemptyb_o   <= go_empty_b_s;
    emptyb_o     <= empty_b_s;
    underflowb_o <= empty_b_s and enb_i;

end behavioral;
