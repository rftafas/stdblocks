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

entity fixed_priority is
    generic (
      n_elements : integer := 8
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
end fixed_priority;

architecture behavioral of fixed_priority is

begin

  fix_p : process(all)
      variable index : integer := 0;
  begin
    if rst_i = '1' then
      index   := 0;
      index_o <= 0;
      grant_o <= (others=>'0');
    elsif rising_edge(clk_i) then
      if grant_o(index) = '1' then
        if ack_i(index) = '1' then
          grant_o <= (others=>'0');
        end if;
      else
        index   := index_of_1(request_i);
        grant_o <= (index => '1', others=>'0');
        index_o <= index;
      end if;
    end if;
  end process;

end behavioral;
