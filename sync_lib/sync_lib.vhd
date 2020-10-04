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
library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;
  use IEEE.math_real.all;

package sync_lib is

  component sync_r
    generic (
      stages : integer := 2
    );
    port (
      rst_i  : in  std_logic;
      mclk_i : in  std_logic;
      din    : in  std_logic;
      dout   : out std_logic
    );
  end component sync_r;

  component det_down
    port (
      rst_i  : in  std_logic;
      mclk_i : in  std_logic;
      din    : in  std_logic;
      dout   : out std_logic
    );
  end component det_down;

  component det_up
    port (
      rst_i  : in  std_logic;
      mclk_i : in  std_logic;
      din    : in  std_logic;
      dout   : out std_logic
    );
  end component det_up;

  component det_updown
    port (
      mclk_i : in  std_logic;
      rst_i  : in  std_logic;
      din    : in  std_logic;
      dout   : out std_logic
    );
  end component det_updown;

  component pulse_align
    generic (
      port_size : integer := 8
    );
    port (
      rst_i  : in  std_logic;
      mclk_i : in  std_logic;
      en_i   : in  std_logic_vector(port_size-1 downto 0);
      en_o   : out std_logic_vector(port_size-1 downto 0)
    );
  end component pulse_align;

  component stretch_async
    port (
      clkin_i  : in  std_logic;
      clkout_i : in  std_logic;
      din      : in  std_logic;
      dout     : out std_logic
    );
  end component stretch_async;

  component stretch_sync is
      port (
        rst_i  : in  std_logic;
        mclk_i : in  std_logic;
        da_i   : in  std_logic;
        db_i   : in  std_logic;
        dout_o : out std_logic
      );
  end component;

  component debounce is
    port (
      rst_i  : in  std_logic;
      mclk_i : in  std_logic;
      din    : in  std_logic;
      dout   : out std_logic
    );
  end component;

end package;

package body sync_lib is

end package body;
