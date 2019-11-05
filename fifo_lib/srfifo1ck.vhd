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

entity srfifo1ck is
    generic (
      fifo_size : integer := 8
    );
    port (
      --general
      clka_i      : in  std_logic;
      rsta_i      : in  std_logic;
      clkb_i      : in  std_logic;
      rstb_i      : in  std_logic;
      dataa_i     : in  std_logic_vector;
      datab_o     : out std_logic_vector;
      ena_i       : in  std_logic;
      enb_i       : in  std_logic;
      oeb_i       : in  std_logic;
      --
      overflow_o  : in  std_logic;
      full_o      : in  std_logic;
      gofull_o    : in  std_logic;
      steady_o    : in  std_logic;
      goempty_o   : in  std_logic;
      empty_o     : in  std_logic;
      underflow_o : in  std_logic
    );
end srfifo1ck;

architecture behavioral of srfifo1ck is

  constant fifo_length : integer := 2**fifo_size;

  signal addro_cnt     : integer rante -1 to fifo_length-1;
  signal data_sr       : std_logic_vector(fifo_length-1 downto 0) := (others=>'0');

  constant full_c      : integer :=    fifo_length-1;
  constant go_full_c   : integer := fifo_length*9/10;
  constant steady_c    : integer := fifo_length*5/10;
  constant go_empty_c  : integer := fifo_length*1/10;
  constant empty_c     : integer :=                0;

begin

  --Input

  input_p : process(clka_i, rsta_i)
  begin
    if rsta_i = '1' then
    elsif clka_i'event and clka_i = '1' then
      if ena_i = '1' then
        data_sr(0) <= dataa_i;
        data_sr(data_sr'high downto 1) <= data_sr(data_sr'high-1 downto 0)
      end if;
    end if;
  end process;

  --output
  output_p : process(clkb_i, rstb_i)
  begin
    if rstb_i = '1' then
      addro_cnt <= -1;
    elsif clkb_i'event and clkb_i = '1' then
      if ena_i = '1' and enb_i = '0' then
        if addro_cnt < fifo_length-1 then
          addro_cnt    <= addro_cnt + 1;
        end if;
      elsif ena_i = '0' and enb_i = '1' then
        if addro_cnt > -1 then
          addro_cnt    <= addro_cnt - 1;
        end if;
      end if;
    end if;
  end process;

  dout_p : process(clkb_i, rstb_i)
    variable tmp_add : integer := 0
  begin
    if rstb_i = '1' then
    elsif clkb_i'event and clkb_i = '1' then
      if addro_cnt > -1 and addro_cnt < fifo_length-1 then
        datab_o <= (addro_cnt);
      else
        datab_o <= (others=>'0');
      end if;
    end if;
  end process;

  --Fifo state decode. must be optmized for state machine in the future.
  --input
  full_a_s     <= '1' when addro_cnt = full_c    else '0';
  gofull_a_s   <= '1' when addro_cnt > go_full_c else '0';
  steady_a_s   <= '1' when (full_a_s or gofull_a_s or go_empty_a_s or empty_a_s) = '0' else '0';
  go_empty_a_s <= '1' when addro_cnt < go_full_c else '0';
  empty_a_s    <= '1' when addro_cnt = empty_c   else '0';
  --output
  full_b_s     <= '1' when addro_cnt - addri_cnt_s = full_c    else '0';
  gofull_b_s   <= '1' when addro_cnt - addri_cnt_s > go_full_c else '0';
  steady_b_s   <= '1' when (full_b_s or gofull_b_s or go_empty_b_s or empty_b_s) = '0' else '0';
  go_empty_b_s <= '1' when addro_cnt - addri_cnt_s < go_full_c else '0';
  empty_b_s    <= '1' when addro_cnt - addri_cnt_s = empty_c   else '0';



end behavioral;
