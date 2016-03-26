-- File Name : t1l-santos.vhdl
-- Behavioral

-- Library Statements
library IEEE; use IEEE.std_logic_1164.all;

-- Entity Definition
entity alarm is
	port(output: out std_logic; -- alarm
	in_buzzer: in std_logic_vector(2 downto 0); -- in buzzer
	out_buzzer: in std_logic_vector(2 downto 0)); -- out buzzer
end entity alarm;

-- Architecture Definition
architecture alarm_architecture of alarm is
begin
	output <= (in_buzzer(0) or in_buzzer(1) or in_buzzer(2)) and (out_buzzer(0) or out_buzzer(1) or out_buzzer(2));
end architecture alarm_architecture;
