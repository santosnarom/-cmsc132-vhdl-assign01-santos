-- File Name: t1l-santos-tb.vhdl
-- Module: Test Bench

-- Libray Statements
library IEEE; use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


-- Entity Definition
entity t1l_santos_tb is -- constants are defined here
	constant MAX_COMB: integer := 64; -- number of input combinations (8 bits)
	constant DELAY: time := 10 ns; -- delay value in testing
end entity t1l_santos_tb;

architecture tb of t1l_santos_tb is
	signal output: std_logic; -- alarm indicator from the UUT
	signal in_buzzer: std_logic_vector(2 downto 0); -- in buzzers
	signal out_buzzer: std_logic_vector(2 downto 0); -- out buzzers
	
	--Component declaration
	component alarm is
		port(output: out std_logic; -- alarm
		in_buzzer: in std_logic_vector(2 downto 0); -- in buzzer
		out_buzzer: in std_logic_vector(2 downto 0)); -- out buzzer
	end component alarm;

begin -- begin main body of the tb architecture
	-- instantiate the unit under test
	UUT: component alarm port map(output, in_buzzer, out_buzzer);

	--main process: generate test vectors and check results
	main: process is
		variable temp: unsigned(5 downto 0); -- used in calculations
		variable expected_alarm: std_logic;
		variable error_count: integer := 0; -- number of simulation errors

	begin
		report "Start simulation.";

		--generate all possible input values
		for count in 0 to 63 loop
			temp := TO_UNSIGNED(count,6);
			in_buzzer(2) <= std_logic(temp(5)); -- 6th bit input
			in_buzzer(1) <= std_logic(temp(4)); -- 5th bit input
			in_buzzer(0) <= std_logic(temp(3)); -- 4th bit input
			out_buzzer(2) <= std_logic(temp(2)); -- 3rd bit input
			out_buzzer(1) <= std_logic(temp(1)); -- 2nd bit input
			out_buzzer(0) <= std_logic(temp(0)); -- 1st bit input

			-- check alarm
			if((count < 9) or (count mod 8 = 0)) then expected_alarm := '0';
			else expected_alarm := '1';		

			end if;

			wait for DELAY; -- wait, and then compare with UUT outputs

			-- check if output of circuit is the same as the expected value
			assert (expected_alarm = output)
				report "ERROR: Expected output " &
					std_logic'image(expected_alarm) & " but output is " & std_logic'image(output) &
					" at time " & time'image(now);

			-- increment number of errors
			if(expected_alarm/=output) then
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

