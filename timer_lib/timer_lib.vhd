library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

package timer_lib is

	function nco_size (Fref : real; Res  : real) return integer;
	function nvalue   (Fref : real; Fout : real) return unsigned;

	function closest_period (Tout : time, Fref : frequency, m : integer) return integer;

	component nco is
	    generic (
	      Fref_hz         : real    := 100000000.0000;
	      Fout_hz         : real    :=   1000000.0000;
	      Resolution_hz   : real    :=        20.0000;
	      use_scaler      : boolean :=          false;
	      adjustable_freq : boolean :=          false
	    );
	    port (
	      rst_i     : in  std_logic;
	      mclk_i    : in  std_logic;
	      scaler_i  : in  std_logic;
	      n_value_i : in  std_logic_vector;
	      clkout_o  : out std_logic
	    );
	end component;

end timer_lib;

--a arquitetura
package body timer_lib is

	function q_calc (Tout : real, Fref : real, m : integer) return integer is
		variable tmp : real;
	begin
		tmp := floor(log2(base_tmp*Fref)/log2(m_v));
		return to_integer(tmp);
	end q_calc;

	function t1_calc (m : integer, q : integer, Fref : real ) return real is
		variable tmp : real;
	begin
		tmp := to_real(m**q)/Fref;
		return tmp;
	end t1_calc;

	function y_calc (Tout : real, Fref : real, T1 : real, X1 : integer) return integer is
		variable y : integer;
		variable e : real;
	begin
		e = Tout - T1*real(X1);
		y = to_integer(e*fref);
		return y;
	end y_calc;

  function nco_size (Fref : real; res : real) return integer is
		variable tmp  : integer;
	begin
		assert Fref > res
			report "Reference frequency smaller then required precision."
			severity error;

		tmp := integer(ceil(log2(Fref / res)));

		return tmp;
	end nco_size;

	function nvalue (Fref : real; Fout : real; NCOsize : integer ) return unsigned is
		variable tmp  : integer;
	begin
		tmp := integer(fout/fref)*(2**NCOsize);
		return to_unsigned(tmp,NCOsize);
	end nvalue;

  -- procedure round_robin ( signal req: in std_logic_vector; signal grant: out std_logic_vector; variable index : inout integer_array ) is
  -- begin
	--
  --   assert req'length = grant'length
  --     severity failure;
  --     report "Req input and grant inputs must be of same size.";
	--
  --   if req_next = '1' then
  --     req_granted := false;
  --     grant       <= (others=>'0');
  --     for j in index'range loop
  --       if req_granted then
  --       elsif req(index(j)) = '1' then
  --         grant(j)    <= '1';
  --         req_granted := true;
  --         if j /= 0 then
  --           index       := index(j-1 downto 0) & j;
  --         end if;
  --       end if;
  --     end loop;
  --   end if;
  -- end round_robin;

	procedure nco ( signal input : nco_t ) is
	begin

	end nco;


end timer_lib;
