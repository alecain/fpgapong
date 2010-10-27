LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY DISPLAY_DECODER IS
	PORT(			
			value		: IN  integer range 0 to 9;
			update	: IN std_logic;
			display	: OUT std_logic_vector(6 downto 0)
		);
END DISPLAY_DECODER;

ARCHITECTURE behv OF DISPLAY_DECODER IS	
BEGIN

process(update)
begin
	if (rising_edge(update)) then
		if (value = 0) then
			display <= "1000000";
		elsif (value = 1) then
			display <= "1111001";
		elsif (value = 2) then
			display <= "0100100";
		elsif (value = 3) then
			display <= "0110000";
		elsif (value = 4) then
			display <= "0011001";
		elsif (value = 5) then
			display <= "0010010";
		elsif (value = 6) then
			display <= "0000011";
		elsif (value = 7) then
			display <= "1111000";
		elsif (value = 8) then
			display <= "0000000";
		elsif (value = 9) then
			display <= "0011000";
		end if;
	end if;
end process;

END behv;