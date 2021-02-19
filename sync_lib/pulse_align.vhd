----------------------------------------------------------------------------------
--Copyright 2020 Ricardo F Tafas Jr

--Licensed under the Apache License, Version 2.0 (the "License"); you may not
--use this file except in compliance with the License. You may obtain a copy of
--the License at

--   http://www.apache.org/licenses/LICENSE-2.0

--Unless required by applicable law or agreed to in writing, software distributed
--under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
--OR CONDITIONS OF ANY KIND, either express or implied. See the License for
--the specific language governing permissions and limitations under the License.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
library stdblocks;
    use stdblocks.sync_lib.all;


entity pulse_align is
    generic (
      port_size : integer := 8
    );
    port (
      rst_i  : in  std_logic;
      mclk_i : in  std_logic;
      en_i   : in  std_logic_vector(port_size-1 downto 0);
      en_o   : out std_logic_vector(port_size-1 downto 0)
    );
end pulse_align;

architecture behavioral of pulse_align is

  --for the future: include attributes for false path.
  type align_t is (idle, wait_others, active, wait_restart);
  type fsm_vector_t is array (en_i'range) of align_t;
  signal mq_align : fsm_vector_t;

  procedure next_state_logic (
    signal enable        : in    std_logic_vector;
    signal fsm_mq        : inout fsm_vector_t
  ) is
    variable tmp : align_t;
  begin
    for j in en_i'range loop
      tmp := fsm_mq(j);
      case tmp is
          when idle        =>
            if enable(j) = '1' then
              tmp :=  wait_others;
            end if;

        when wait_others =>
          tmp := active;
          for j in fsm_mq'range loop
            if fsm_mq(j) /= wait_others then
              tmp :=  wait_others;
            end if;
          end loop;

        when others      =>
          if enable(j) = '0' then
            tmp := idle;
          end if;

      end case;
      fsm_mq(j) <= tmp;
    end loop;
  end procedure;

  function decode_out( fsm_mq : fsm_vector_t ) return std_logic_vector is
    variable tmp : std_logic_vector(en_i'range);
    begin
      for j in en_i'range loop
        if fsm_mq(j) = active then
          tmp(j) := '1';
        else
          tmp(j) := '0';
        end if;
      end loop;
      return tmp;
  end function;

begin

  process(mclk_i, rst_i)
    variable status_v : std_logic_vector(en_i'range) := (others=>'0');
  begin
    if rst_i = '1' then
      mq_align <= (others=>idle);
    elsif rising_edge(mclk_i) then
      next_state_logic(en_i, mq_align);
    end if;
  end process;

  en_o <= decode_out(mq_align);

end behavioral;
