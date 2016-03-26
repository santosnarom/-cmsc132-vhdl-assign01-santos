-- File Name: t1l-santos-tb.vhdl
-- Module: Test Bench

-- Libray Statements
library IEEE; use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Entity Definition
entity alarm_tb is -- constants are defined here
	constant MAX_COMB: integer := 64; -- number of input combinations (8 bits)
	constant DELAY: time := 10 ns; -- delay value in testing
end entity alarm_tb;

architecture tb of alarm_tb is
	signal alarm_output: std_logic; -- alarm indicator from the UUT
	signal buzzer_in: std_logic_vector(2 downto 0); -- in buzzers
	signal buzzer_out: std_logic_vector(2 downto 0); -- out buzzers
	
	--Component declaration
	component alarm is
		port(output: out std_logic; -- alarm
		in_buzzer: in std_logic_vector(2 downto 0); -- in buzzer
		out_buzzer: in std_logic_vector(2 downto 0)); -- out buzzer
	end component alarm;

begin -- begin main body of the tb architecture
	-- instantiate the unit under test
	UUT: component alarm port map(alarm_output, encoded, i);

	--main process: generate test vectors and check results
	main: process is
		variable temp: unsigned(7 downto 0); -- used in calculations
		variable expected_valid: std_logic;
		variable expected_encoded: std_logic_vector(2 downto 0);
		variable error_count: integer := 0; -- number of simulation errors

	begin
		report "Start simulation.";

		--generate all possible input values, since max = 255
		for count in 0 to 255 loop
			temp := TO_UNSIGNED(count,8);
			i(7) <= std_logic(temp(7)); -- 8th bit
			i(6) <= std_logic(temp(6)); -- 7th bit
			i(5) <= std_logic(temp(5)); -- 6th bit
			i(4) <= std_logic(temp(4)); -- 5th bit
			i(3) <= std_logic(temp(3)); -- 4th bit
			i(2) <= std_logic(temp(2)); -- 3rd bit
			i(1) <= std_logic(temp(1)); -- 2nd bit
			i(0) <= std_logic(temp(0)); -- 1st bit

			-- compute expected values
			if(count=0) then
				expected_valid := '0';
				expected_encoded := "000";
			else
				expected_valid := '1'; 	
				if (count=1) then expected_encoded := "000"; -- 0000 0001
				elsif (count<=3) then expected_encoded := "001"; -- 0000 001X
				elsif (count<=7) then expected_encoded := "010"; -- 0000 01XX
				elsif (count<=15) then expected_encoded := "011"; -- 0000 1XXX
				elsif (count<=31) then expected_encoded := "100"; -- 0001 XXXX
				elsif (count<=63) then expected_encoded := "101"; -- 001X XXXX
				elsif (count<=127) then expected_encoded := "110"; -- 01XX XXXX
				else expected_encoded := "111";
				end if; -- of checks with i > 0
			end if; -- of if (i=0) .. else

			wait for DELAY; -- wait, and then compare with UUT outputs

			-- check if output of circuit is the same as the expected value
			assert ((expected_valid = valid) and (expected_encoded = encoded))
				report "ERROR: Expected valid " &
					std_logic'image(expected_valid) & "and encoded " &
					std_logic'image(expected_encoded(2)) &					
					std_logic'image(expected_encoded(1)) &
					std_logic'image(expected_encoded(0)) &
					" at time " & time'image(now);

			-- increment number of errors
			if((expected_valid/=valid) or (expected_encoded /= encoded)) then
				error_count := error_count + 1;
			end if;
		end loop;

		wait for DELAY;

		-- report errors
		assert (error_count=0)
			report "ERROR: There were " &
				integer'image(error_count) & " errors!";

		-- there are no erros
		if(error_count = 0) then
			report "Simulation completed with NO errors.";
		end if;

		wait; -- terminate the simulation
	end process;
end architecture tb;

