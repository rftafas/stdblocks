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

entity stdfifo1ck is
    generic (
      ram_type : mem_t := "block";
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
      overflow_o  : in  std_logic;
      full_o      : in  std_logic;
      gofull_o    : in  std_logic;
      steady_o    : in  std_logic;
      goempty_o   : in  std_logic;
      empty_o     : in  std_logic;
      underflow_o : in  std_logic
    );
end stdfifo1ck;

architecture behavioral of stdfifo1ck is

  signal addri_cnt   : std_logic_vector(fifo_size-1 downto 0);
  signal addro_cnt   : std_logic_vector(fifo_size-1 downto 0);

  constant fifo_length : integer := 2**fifo_size;

  constant full_c     : integer :=    fifo_length-1;
  constant go_full_c  : integer := fifo_length*9/10;
  constant steady_c   : integer := fifo_length*5/10;
  constant go_empty_c : integer := fifo_length*1/10;
  constant empty_c    : integer :=                0;

begin

  --Input
  input_p : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
    elsif clk_i'event and clk_i = '1' then
      if ena_i = '1' then
        addri_cnt    <= addri_cnt + 1;
      end if;
    end if;
  end process;

  --output
  input_p : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
    elsif clk_i'event and clk_i = '1' then
      if enb_i = '1' then
        addro_cnt    <= addro_cnt + 1;
      end if;
    end if;
  end process;


  --Fifo state decode. must be optmized for state machine in the future.
  full_s     <= '1' when addro_cnt - addri_cnt = full_c    else '0';
  gofull_s   <= '1' when addro_cnt - addri_cnt > go_full_c else '0';
  steady_s   <= '1' when (full_s or gofull_s or go_empty_s or empty_s) = '0' else '0';
  go_empty_s <= '1' when addro_cnt - addri_cnt < go_full_c else '0';
  empty_s    <= '1' when addro_cnt - addri_cnt = empty_c   else '0';

  dp_ram_i : dp_ram
    generic map (
      ram_type => ram_type
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
      ena_i   => ena_i,
      enb_i   => enb_i,
      oeb_i   => oeb_i,
    );


end behavioral;
