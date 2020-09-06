library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use IEEE.math_real.all;

package timer_lib is

	type frequency is range 0 to 10000000000
	units
		Hz;
		kHz = 1000.0000 Hz;
		MHz = 1000.0000 kHz;
		GHz = 1000.0000 MHz;
	end units;

	function to_real ( input : frequency ) return real;
	function to_real ( input :      time ) return real;

	function nco_size_calc (
		res : frequency;
		Fref : frequency
	) return integer;

	function increment_value_calc (
		Fref : frequency;
		Fout : frequency;
		size : integer
	) return integer;

	 function counter_cell_calc (Tout : time, Fref : frequency, cell_size : integer) return integer;

	component nco is
	    generic (
	      Fref_hz         : frequency := 100 MHz;
	      Fout_hz         : frequency :=  10 MHz;
	      Resolution_hz   : frequency :=  20  Hz;
	      use_scaler      : boolean   :=   false;
	      adjustable_freq : boolean   :=   false
	    );
	    port (
	      rst_i     : in  std_logic;
	      mclk_i    : in  std_logic;
	      scaler_i  : in  std_logic;
	      n_value_i : in  std_logic_vector;
	      clkout_o  : out std_logic
	    );
	end component;

	component pwm is
	  generic (
			Fref_hz  : frequency := 100 MHz;
			Fout_hz  : frequency :=  10 MHz;
	    PWM_size : integer   :=  16
	  );
	  port (
	    rst_i       : in  std_logic;
	    mclk_i      : in  std_logic;
	    threshold_i : in  std_logic_vector(PWM_size-1 ownto 0);
	    pwm_o       : out std_logic
	  );
	end component;

	component long_counter is
	  generic (
			Fref_hz  : frequency := 100 MHz;
	    Tout_s  : time      :=  10 sec;
	    sr_size : integer   :=  32
	  );
	  port (
	    rst_i       : in  std_logic;
	    mclk_i      : in  std_logic;
	    enable_i    : in  std_logic;
	    enable_o    : out std_logic
	  );
	end component;

	component long_counter_cell is
	  generic (
	    sr_size : integer   :=  32
	  );
	  port (
	    rst_i       : in  std_logic;
	    mclk_i      : in  std_logic;
	    enable_i    : in  std_logic;
	    enable_o    : out std_logic
	  );
	end component;

	component precise_long_counter is
	  generic (
	    Fref_hz : frequency := 100 MHz;
	    Tout_s  : time      :=  10 sec;
	    sr_size : integer   :=  32
	  );
	  port (
	    rst_i       : in  std_logic;
	    mclk_i      : in  std_logic;
	    enable_i    : in  std_logic;
	    enable_o    : out std_logic
	  );
	end component;

	component adpll is
	  generic (
	    Fref_hz       : real := 100000000.0000;
	    Fout_hz       : real :=   1000000.0000;
	    Resolution_hz : real :=        20.0000
	  );
	  port (
	    rst_i    : in  std_logic;
	    mclk_i   : in  std_logic;
	    clkin_i  : in  std_logic;
	    clkout_o : out std_logic
	  );
	end component;

end timer_lib;

--a arquitetura
package body timer_lib is

	function to_real ( input : frequency ) return real is
	begin
		return real(frequency / 1 hz);
	end to_real;

	function to_real ( input :      time ) return real is
	begin
		return real(input / 1 sec);
	end to_real;

	function nco_size_calc (res : frequency; Fref : frequency) return integer is
		variable res_tmp  : real;
		variable fref_tmp : real;
	begin
		res_tmp  := to_real(res);
		fref_tmp := to_real(fref);
		return integer(ceil(log2(fref_tmp/res_tmp)));
	end nco_size_calc;

	function increment_value_calc (Fref : frequency; Fout : frequency; size : integer ) return integer is
		variable fout_tmp : real;
		variable fref_tmp : real;
		variable size_tmp : real;
	begin
		fout_tmp := to_real(Fout);
		fref_tmp := to_real(fref);
		size_tmp := to_real(2**size);
		return integer(fout_tmp*size_tmp/fref_tmp);
	end increment_value_calc;

--------------------------------------------------------------------------------------------------------
-- LONG COUNTER CALCULATIONS
--------------------------------------------------------------------------------------------------------
	function timer_valid_check (period : time; Fref : frequency ) return boolean is
		variable period_tmp    : real;
		variable fref_tmp      : real;
	begin
		period_tmp    := to_real(period);
		Fref_tmp      := to_real(frequency);
		tmp           := (Fref_tmp*period_tmp);
		if tmp >= 1000.0000 then
			return true;
		end if;
		return false;
	end timer_valid_check;

	function cell_num_calc (period : time; Fref : frequency; cell_size : integer) return integer is
		variable X_tmp         : real;
		variable fref_tmp      : real;
		variable cell_size_tmp : real;
	begin
		X_tmp         := log2(to_real(period)*to_real(frequency));
		cell_size_tmp := real(cell_size);
		return to_integer(X_tmp/log2(cell_size_tmp));
	end cell_num_calc;

	function cell_num_calc2 (period : time; Fref : frequency; s_value : real) return integer is
		variable X_tmp  : real;
	begin
		X_tmp := log2(to_real(period)*to_real(frequency));
		return integer(X_tmp / s_value - 1);
	end cell_num_calc2;

	function rem_counter_limit (period : time; Fref : frequency; cell_size : integer; cell_num : integer) return real is
		variable period_tmp    : real;
		variable fref_tmp      : real;
		variable tmp           : real;
	begin
		period_tmp    := to_real(period);
		Fref_tmp      := to_real(frequency);
		tmp           := (period_tmp*fref_tmp) - real(cell_size**(cell_num+1));
		return to_integer(tmp);
	end rem_counter_limit;

end timer_lib;
