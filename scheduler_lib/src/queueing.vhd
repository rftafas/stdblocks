----------------------------------------------------------------------------------
-- Priority Engine for granting resources to those requesting it.
-- Usage: choose one of the priority types.
-- Raise the request input to request a resource. wait for grant.
-- when done using, ack it.
-- This block does not prevent bad behavior. that can be made outside with
-- nice counters.
--
-- if you are asking why natural, try asking the guys from vivadosim.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library expert;
  use expert.std_logic_expert.all;

entity queueing is
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
end queueing;

architecture behavioral of queueing is



  signal index_sr         : integer_array(n_elements-1 downto 0) := start_queue(n_elements);
  signal moving_index_s   : natural := 0;
  signal priority_index_s : natural := 0;

begin

      -- Transmitters go last.
      -- priority is given to channels that are not trasmitting. this ensures no starvation.
      -- Packet order is lost.
      process(all)
        variable locked : boolean := false;
      begin
        if rst_i = '1' then
          grant_o  <= (others=>'0');
          index_sr <= start_queue(n_elements);
          moving_index_s <= 0;
        elsif rising_edge(clk_i) then
          if grant_o(moving_index_s) = '1' then
            if ack_i(moving_index_s) = '1' then
              grant_o(moving_index_s) <= '0';
              index_sr(moving_index_s downto 0) <= index_sr(moving_index_s downto 0) rll 1;
              moving_index_s <= n_elements-1;
            end if;
          elsif request_i(moving_index_s) = '1' then
            grant_o(moving_index_s) <= '1';
          else
            moving_index_s <= integer_count(moving_index_s,n_elements-1,false);
          end if;
        end if;
      end process;
      index_o <= moving_index_s;

end behavioral;
