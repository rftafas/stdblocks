----------------------------------------------------------------------------------
-- Priority Engine for granting resources to those requesting it.
-- Usage: choose one of the priority types.
-- Raise the request input to request a resource. wait for grant.
-- when done using, ack it.
-- This block does not prevent bad behavior. that can be made outside with
-- nice counters.
--
-- if you are asking why natural, try asking the guys from vivadosim. they are still
-- not accepting functions on parameters...
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library expert;
  use expert.std_logic_expert.all;

entity round_robin_hard is
    generic (
      n_elements : integer := 8;
      mode       : integer := 0
    );
    port (
      --general
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      --python script port creation starts
      request_i    : in  std_logic_vector(n_elements-1 downto 0);
      ack_i        : in  std_logic_vector(n_elements-1 downto 0);
      grant_o      : out std_logic_vector(n_elements-1 downto 0);
      index_o      : out natural
    );
end round_robin_hard;

architecture behavioral of round_robin_hard is

  type index_sr_t is array (n_elements-1 downto 0) of integer;
  signal index_sr         : index_sr_t := (others=>0);
  signal moving_index_s   : natural := 0;
  signal priority_index_s : natural := 0;

begin

    rr_p : process(all)
    begin
      if rst_i = '1' then
        grant_o        <= (others=>'0');
        moving_index_s <= 0;
      elsif rising_edge(clk_i) then
        if grant_o(moving_index_s) = '1' then --we test VHDL2008 hability to read out ports.
          if ack_i(moving_index_s) = '1' then
              moving_index_s <= integer_count(moving_index_s,n_elements-1,true);
              grant_o        <= (others=>'0');
          end if;
        elsif request_i(moving_index_s) = '1' then
          grant_o <= (moving_index_s => '1', others=>'0');
        end if;
      end if;
    end process;
    index_o <= moving_index_s;

end behavioral;
