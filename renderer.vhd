LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY renderer IS
	GENERIC (
		depth: INTEGER := 1
	);

	PORT (
		x 					: IN  INTEGER RANGE 0 TO 640;
		y 					: IN  INTEGER RANGE 0 TO 480;
		frame_sync		: IN  STD_LOGIC;
		enable			: IN  STD_LOGIC;
			
		pixel_R			: OUT STD_LOGIC_VECTOR(9 DOWNTO 0); 
		pixel_G			: OUT STD_LOGIC_VECTOR(9 DOWNTO 0); 
		pixel_B			: OUT STD_LOGIC_VECTOR(9 DOWNTO 0); 
			
		lpaddle			: IN  INTEGER;
		rpaddle			: IN  INTEGER;
		ballx				: IN  INTEGER;
		bally				: IN  INTEGER
	);
END renderer;


ARCHITECTURE behv OF renderer IS
BEGIN			

	PROCESS(x,y)
	BEGIN
		IF x <= ballx + 10 AND x >= ballx - 10 AND y <= bally + 10 AND y >= bally - 10 THEN
			-- Draw white pixels
			pixel_R <= "1111111111";
			pixel_G <= "1111111111";
			pixel_B <= "1111111111";
		ELSIF x <= 20 + 10 AND x >= 20 - 10 AND y <= lpaddle + 40 AND y >= lpaddle - 40 THEN
			-- Draw red pixels
			pixel_R <= "1111111111";
			pixel_G <= "0000000000";
			pixel_B <= "0000000000";
		ELSIF x <= 600 + 10 AND x >= 600 - 10 AND	y <= rpaddle + 40 AND y >= rpaddle - 40 THEN
			-- Draw blue pixels
			pixel_R <= "0000000000";
			pixel_G <= "0000000000";
			pixel_B <= "1111111111";
		ELSE
			-- Draw dark green pixels
			pixel_R <= "0000000000";
			pixel_G <= "0001111111";
			pixel_B <= "0000000000";
		END IF;
		
	END PROCESS;

END behv;