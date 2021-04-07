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
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use IEEE.math_real.all;

package timer_lib is

	type frequency is range 0 to 1000000000
	units
		Hz;
		kHz = 1000 Hz;
		MHz = 1000 kHz;
		GHz = 1000 MHz;
	end units;

	function to_real ( input : frequency ) return real;
	function to_real ( input :      time ) return real;

	function nco_size_calc (
		Fref       : real;
		res        : real
	) return integer;

	function increment_value_calc (
		Fref : real;
		Fout : real;
		size : integer
	) return integer;

	function timer_valid_check (period : real; Fref : real ) return boolean;
	function time_check (cell_size : integer; cell_num : integer; Fref : real ) return real;

	function cell_num_calc (
		period    : real;
		Fref      : real;
		cell_size : integer
	) return integer;

	function rem_counter_limit (
		period    : real;
		Fref      : real;
		cell_size : integer;
		cell_num  : integer
	) return integer;

	component nco is
	    generic (
	      Fref_hz         : real    := 100.0000e6;
	      Fout_hz         : real    :=  10.0000e6;
	      Resolution_hz   : real    :=  20.0000;
	      use_scaler      : boolean :=  false;
	      adjustable_freq : boolean :=  false;
	      NCO_size_c      : natural :=  16
	    );
	    port (
	      rst_i     : in  std_logic;
	      mclk_i    : in  std_logic;
	      scaler_i  : in  std_logic;
		  sync_i    : in  std_logic;
	      n_value_i : in  std_logic_vector;
	      clkout_o  : out std_logic
	    );
	end component;

	component pwm is
	  generic (
			Fref_hz  : real     := 100.0000e6;
			Fout_hz  : real    :=   10.0000e6;
	    PWM_size : integer :=   16
	  );
	  port (
	    rst_i       : in  std_logic;
	    mclk_i      : in  std_logic;
	    threshold_i : in  std_logic_vector(PWM_size-1 downto 0);
	    pwm_o       : out std_logic
	  );
	end component;

	component long_counter is
	  generic (
			fref_hz : real    := 100.0000e6;
	    period  : real    :=  10.0000;
	    sr_size : integer :=  32
	  );
	  port (
	    rst_i       : in  std_logic;
	    mclk_i      : in  std_logic;
	    enable_i    : in  std_logic;
	    clkout_o    : out std_logic
	  );
	end component;

	component long_counter_cell is
	  generic (
	    sr_size : integer   :=  32
	  );
	  port (
	    rst_i    : in  std_logic;
	    mclk_i   : in  std_logic;
	    enable_i : in  std_logic;
	    enable_o : out std_logic
	  );
	end component;

	component precise_long_counter is
	  generic (
	    fref_hz : real    := 100.0000e6;
	    period  : real    :=  10.0000;
	    sr_size : integer :=  32
	  );
	  port (
	    rst_i    : in  std_logic;
	    mclk_i   : in  std_logic;
	    enable_i : in  std_logic;
	    clkout_o : out std_logic
	  );
	end component;

	component adpll is
	  generic (
			Fref_hz       : real := 100.0000e+6;
	    Fout_hz       : real :=  10.0000e+6;
	    Bandwidth_hz  : real := 500.0000e+3;
	    Resolution_hz : real :=  20.0000
	  );
	  port (
	    rst_i    : in  std_logic;
	    mclk_i   : in  std_logic;
	    clkin_i  : in  std_logic;
	    clkout_o : out std_logic
	  );
	end component;

	component nco_int is
		generic (
      NCO_size_c : natural := 16
    );
    port (
      rst_i     : in  std_logic;
      mclk_i    : in  std_logic;
      scaler_i  : in  std_logic;
      sync_i    : in  std_logic;
      n_value_i : in  std_logic_vector(NCO_size_c-1 downto 0);
      clkout_o  : out std_logic
    );
	end component;

end package timer_lib;

--a arquitetura
package body timer_lib is

	function to_real ( input : frequency ) return real is
	begin
		return real(input / 1 hz);
	end to_real;

	function to_real ( input : time ) return real is
		variable norm : time;
		variable corr : real;
	begin
		if input > 1 sec then
			norm := 1 sec;
			corr := 1.0000;
		elsif input > 1 ms then
			norm := 1 ms;
			corr := 1.0000e-3;
		elsif input > 1 us then
			norm := 1 us;
			corr := 1.0000e-6;
		elsif input > 1 ns then
			norm := 1 ns;
			corr := 1.0000e-9;
		else
			norm := 1 ps;
			corr := 1.0000e-12;
		end if;
		return real( input / norm ) * corr;
	end to_real;

	function nco_size_calc (Fref : real; res : real) return integer is
	begin
		return integer(ceil(log2(Fref/res)));
	end nco_size_calc;

	function increment_value_calc (Fref : real; Fout : real; size : integer ) return integer is
	begin
		return integer(Fout*(2.000**size)/Fref);
	end increment_value_calc;

--------------------------------------------------------------------------------------------------------
-- LONG COUNTER CALCULATIONS
--------------------------------------------------------------------------------------------------------
	function timer_valid_check (period : real; Fref : real ) return boolean is
		variable tmp        : real;
	begin
		tmp := Fref*period;
		if tmp >= 1000.0000 then
			return true;
		end if;
		return false;
	end timer_valid_check;

	function time_check (cell_size : integer; cell_num : integer; Fref : real ) return real is
		variable tmp : real;
	begin
		tmp := real(cell_size**cell_num);
		tmp := tmp / Fref;
		return tmp;
	end time_check;

	function cell_num_calc (period : real; Fref : real; cell_size : integer) return integer is
		variable tmp : real;
		variable int : integer;
	begin
		tmp := real(cell_size);
		tmp := log2(period*Fref)/log2(tmp);
		int := integer(tmp);
		report "Will use as reference " & to_string(time_check(cell_size,int,Fref)) & " seconds.";
		return int;
	end cell_num_calc;

	function rem_counter_limit (period : real; Fref : real; cell_size : integer; cell_num : integer) return integer is
		variable tmp           : real;
	begin
		tmp           := (period*Fref) - real(cell_size**(cell_num+1));
		return integer(tmp);
	end rem_counter_limit;

end timer_lib;
