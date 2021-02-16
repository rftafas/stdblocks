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
library expert;
  use expert.std_logic_expert.all;

package prbs_lib is

	constant MAX_PRBS : integer := 31;

	type prbs_t is protected
		impure function get_data ( input : positive ) return std_logic_vector;
		impure function check_data ( input : std_logic_vector ) return boolean;
		impure function check_sync ( input : std_logic_vector ) return boolean;
		procedure set_seed   ( input : std_logic_vector );
		procedure set_order  ( input : positive         );
		procedure reset;
	end protected prbs_t;

	type prbs_handler_t is record
		regs  : std_logic_vector(MAX_PRBS downto 1);
		order : positive;
	end record;

	function prbs_xor (
		prbs_sr : std_logic_vector; prbs_order : integer ) return std_logic;

	procedure prbs_shift ( prbs : inout prbs_handler_t; data_o : out std_logic );

	procedure prbs_shift ( prbs : inout prbs_handler_t; data_o : out std_logic_vector );

	procedure add_scramble (
		prbs   : inout prbs_handler_t;
		data_i : in    std_logic;
		data_o : out   std_logic
	);

	procedure add_scramble ( 
		prbs   : inout prbs_handler_t;
		data_i : in std_logic_vector;
		data_o : out std_logic_vector
	);

	procedure mult_scramble (
		prbs   : inout prbs_handler_t;
		data_i : in    std_logic;
		data_o : out   std_logic
	);

	procedure mult_scramble (
		prbs   : inout prbs_handler_t;
		data_i : in    std_logic_vector;
		data_o : out   std_logic_vector
	 );

end prbs_lib;

package body prbs_lib is

	type prbs_t is protected body
		variable prbs : prbs_handler_t := (
			regs  => (others=>'1'),
			order => 23
		);
		variable check : prbs_handler_t := (
			regs  => (others=>'1'),
			order => 23
		);
		variable sync : prbs_handler_t := (
			regs  => (others=>'1'),
			order => 23
		);

		variable seed : std_logic_vector(MAX_PRBS downto 1) := (others=>'1');

		impure function get_data ( input : positive ) return std_logic_vector is
			variable result_tmp : std_logic_vector(input-1 downto 0);
		begin
			prbs_shift(prbs,result_tmp);
			return result_tmp;
		end function;

		impure function check_data ( input : std_logic_vector ) return boolean is
			variable result_tmp : std_logic_vector(input'range);
		begin
			prbs_shift(check,result_tmp);
			if result_tmp = input then
				return true;
			end if;
			report "Lost PRBS Sequence. Expected: " & to_string(result_tmp) & " / got: " & to_string(input);
			return false;
		end function;

		impure function check_sync ( input : std_logic_vector ) return boolean is
			variable data_tmp : std_logic_vector(input'range);
		begin
			mult_scramble(sync,input,data_tmp);
			if data_tmp = (input'range => '0') then
				return true;
			end if;
			return false;
		end function;

		procedure set_seed ( input : std_logic_vector ) is
			variable tmp : std_logic_vector(input'length downto 1);
		begin
			assert input'length < MAX_PRBS
				report "Seed size is " & to_string(input'length) & " bits. Maximum size is " & to_string(MAX_PRBS) & " bits of length. Discarding upper bits."
				severity note;
			
			assert input'length > MAX_PRBS
				report "Seed size is " & to_string(input'length) & " bits. Minimum size is " & to_string(MAX_PRBS) & " bits of length. Filling with '1' remaining bits."
				severity note;

			tmp := input;
			if input'length >= seed'length then
				seed := tmp(seed'range);
			else
				seed := (tmp'range => tmp, others=>'1');
			end if;
		end procedure;

		procedure set_order ( input : positive ) is
		begin
			prbs.order  := input;
			check.order := input;
			sync.order  := input;

		end procedure;

		procedure reset is
		begin
			prbs.regs  := seed;
			check.regs := seed;
			sync.regs  := seed;
		end procedure;

	end protected body prbs_t;

	function prbs_xor ( prbs_sr : std_logic_vector; prbs_order : integer ) return std_logic is
		variable prbs_tmp  : std_logic_vector(prbs_sr'length downto 1);
	begin
		prbs_tmp := prbs_sr;

		case prbs_order is
			when 3 =>
				return prbs_tmp(3) xor prbs_tmp(2);
			when 5 =>
				return prbs_tmp(5) xor prbs_tmp(3);
			when 9 =>
				return prbs_tmp(9) xor prbs_tmp(5);
			when 11 =>
				return prbs_tmp(11) xor prbs_tmp(9);
			when 15 =>
				return prbs_tmp(15) xor prbs_tmp(14);
			when 20 =>
				return prbs_tmp(20) xor prbs_tmp(3);
			when 23 =>
				return prbs_tmp(23) xor prbs_tmp(18);
			when 29 =>
				return prbs_tmp(29) xor prbs_tmp(27);
			when 31 =>
				return prbs_tmp(31) xor prbs_tmp(28);
			when others =>
				report "Unimplemented PRBS size. Please, a valid value. Output is 0.";
				return '0';
		end case;
	end prbs_xor;

	procedure prbs_shift ( prbs : inout prbs_handler_t; data_o : out std_logic ) is
	begin
		data_o     := prbs_xor(prbs.regs,prbs.order);
		prbs.regs  := prbs.regs(MAX_PRBS-1 downto 1) & prbs_xor(prbs.regs,prbs.order);
		prbs.order := prbs.order;
	end prbs_shift;

	procedure prbs_shift ( prbs : inout prbs_handler_t; data_o : out std_logic_vector ) is
	begin
		for j in data_o'range loop
			prbs_shift( prbs, data_o(j) );
		end loop;
	end prbs_shift;

	procedure mult_scramble ( prbs : inout prbs_handler_t; data_i : in std_logic; data_o : out std_logic ) is
	begin
		prbs_shift( prbs, data_o);
		prbs.regs(1) := prbs.regs(1) xor data_i;
		data_o :=  prbs.regs(1);
	end mult_scramble;

	procedure mult_scramble ( prbs : inout prbs_handler_t; data_i : in std_logic_vector; data_o : out std_logic_vector ) is
	begin
		assert data_i'length = data_o'length
			report "Error mult_scramble(): Additive Scrambler requires input and output vector of same size."
			severity failure;

		for j in data_i'range loop
			mult_scramble(prbs,data_i(j),data_o(j));
		end loop;
	end mult_scramble;

	procedure add_scramble ( prbs : inout prbs_handler_t; data_i : in std_logic; data_o : out std_logic ) is
		variable prbs_tmp : std_logic_vector(MAX_PRBS downto 1);
		variable tmp  : std_logic;
	begin
		prbs_shift(prbs,tmp);
		data_o := tmp xor data_i;
	end add_scramble;

	procedure add_scramble ( prbs : inout prbs_handler_t; data_i : in std_logic_vector; data_o : out std_logic_vector ) is
	begin
		assert data_i'length = data_o'length
			report "Error add_scramble(): Additive Scrambler requires input and output vector of same size."
			severity failure;
			
		for j in data_i'range loop
			add_scramble(prbs,data_i(j),data_o(j));
		end loop;
	end add_scramble;

end prbs_lib;
