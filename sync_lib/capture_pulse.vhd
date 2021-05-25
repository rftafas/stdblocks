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

entity capture_pulse is
    port (
      rst_i     : in  std_logic;
      mclk_i    : in  std_logic;
      input_i   : in  std_logic;
      trigger_i : in  std_logic;
      output_o  : out std_logic
    );
end capture_pulse;

architecture behavioral of capture_pulse is

  signal da_tmp      : std_logic := '0';

begin

  process(mclk_i)
  begin
    if rst_i = '1' then
      da_tmp <= '0';
      db_tmp <= '0';
    elsif rising_edge(mclk_i) then
      if input_i = '1' and trigger_i = '1' then
        da_tmp <= '0';
      elsif trigger_i = '1' and da_tmp = '1' then
        da_tmp <= '0';
      elsif input_i = '1' then
        da_tmp <= '1';
      end if;
    end if;
  end process;

  output_o <= '1' when ( input_i and trigger_i ) = '1' else
              '1' when ( da_tmp  and trigger_i ) = '1' else
              '0';

end behavioral;
