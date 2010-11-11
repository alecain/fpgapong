LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.ALL;
USE  IEEE.STD_LOGIC_ARITH.ALL;
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY DISPLAY_DECODER IS
	PORT(			
			value		: IN  INTEGER RANGE 0 TO 9;
			update	: IN  STD_LOGIC;
			display	: OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
END DISPLAY_DECODER;

ARCHITECTURE behv OF DISPLAY_DECODER IS	
BEGIN

	PROCESS(update)
	BEGIN
		IF RISING_EDGE(update) THEN
			IF (value = 0)    THEN display <= "1000000";
			ELSIF (value = 1) THEN display <= "1111001";
			ELSIF (value = 2) THEN display <= "0100100";
			ELSIF (value = 3) THEN display <= "0110000";
			ELSIF (value = 4) THEN display <= "0011001";
			ELSIF (value = 5) THEN display <= "0010010";
			ELSIF (value = 6) THEN display <= "0000011";
			ELSIF (value = 7) THEN display <= "1111000";
			ELSIF (value = 8) THEN display <= "0000000";
			ELSIF (value = 9) THEN display <= "0011000";
			ELSE                   display <= "0000000";
			END IF;
		END IF;
	END process;

END behv;