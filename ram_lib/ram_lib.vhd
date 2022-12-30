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

package ram_lib is

    --this may either be adjusted or leave as is for intended technology.
    constant blockram_size : positive := 9216;

    --xilinx attribute
    attribute ram_style : string;
    --intel attribute
    attribute ramstyle : string;

    type mem_t is (blockram, ultra, registers, distributed);

    component tdp_ram
        generic (
            mem_size        : integer := 8;
            port_size       : integer := 8;
            ram_type        : string  := "auto";
            fall_through    : boolean := false
        );
        port (
            clka_i  : in  std_logic;
            rsta_i  : in  std_logic;
            clkb_i  : in  std_logic;
            rstb_i  : in  std_logic;
            addra_i : in  std_logic_vector(mem_size-1 downto 0);
            addrb_i : in  std_logic_vector(mem_size-1 downto 0);
            dataa_i : in  std_logic_vector(port_size-1 downto 0);
            datab_i : in  std_logic_vector(port_size-1 downto 0);
            dataa_o : out std_logic_vector(port_size-1 downto 0);
            datab_o : out std_logic_vector(port_size-1 downto 0);
            ena_i   : in  std_logic;
            enb_i   : in  std_logic;
            wea_i   : in  std_logic;
            web_i   : in  std_logic
        );
    end component tdp_ram;

    component dp_ram
        generic (
            mem_size        : integer := 8;
            port_size       : integer := 8;
            ram_type        : string  := "auto";
            fall_through    : boolean := false
        );
        port (
            clka_i  : in  std_logic;
            rsta_i  : in  std_logic;
            clkb_i  : in  std_logic;
            rstb_i  : in  std_logic;
            addra_i : in  std_logic_vector( mem_size-1 downto 0);
            dataa_i : in  std_logic_vector(port_size-1 downto 0);
            dataa_o : out std_logic_vector(port_size-1 downto 0);
            addrb_i : in  std_logic_vector( mem_size-1 downto 0);
            datab_o : out std_logic_vector(port_size-1 downto 0);
            ena_i   : in  std_logic;
            enb_i   : in  std_logic;
            wea_i   : in  std_logic
        );
    end component;

    component tdp_ram_difport is
        generic (
            mem_size        : integer := 8;
            porta_size      : integer := 1;
            portb_size      : integer := 8;
            ram_type        : string  := "auto";
            fall_through    : boolean := false
        );
        port (
            --general
            clka_i   : in  std_logic;
            rsta_i   : in  std_logic;
            clkb_i   : in  std_logic;
            rstb_i   : in  std_logic;
            addra_i  : in  std_logic_vector(mem_size-1 downto 0);
            addrb_i  : in  std_logic_vector(mem_size-1 downto 0);
            dataa_i  : in  std_logic_vector(porta_size-1 downto 0);
            datab_i  : in  std_logic_vector(portb_size-1 downto 0);
            dataa_o  : out std_logic_vector(porta_size-1 downto 0);
            datab_o  : out std_logic_vector(portb_size-1 downto 0);
            ena_i    : in  std_logic;
            enb_i    : in  std_logic;
            wea_i    : in  std_logic;
            web_i    : in  std_logic
        );
    end component;

    function ram_type_dec ( ram_type : string; port_size : positive; ram_size : positive ) return mem_t;

end package;

package body ram_lib is

    function ram_type_dec ( ram_type : string; port_size : positive; ram_size : positive ) return mem_t is
    begin
        if ram_type = "block" then
            return blockram;
        elsif ram_type = "distributed" then
            return distributed;
        elsif ram_type = "registers" then
            report "Register based RAM is usually a waste of resources. Try using block or distributed RAM types." severity warning;
            return registers;
        elsif ram_type = "auto" then
            if 2**ram_size*port_size < blockram_size/64 then
                report "Using 'Auto'. Selected RAM is DISTRIBUTED." severity warning;
                return distributed;
            else
                report "Using 'Auto'. Selected RAM is BLOCK." severity warning;
                return blockram;
            end if;
        else
            assert false
                report "The value '" & ram_type & "' is invalid. Valid RAM types are 'auto', 'block', 'distributed' or 'register'."
                severity FAILURE;
        end if;
    end function ram_type_dec;


end package body;
