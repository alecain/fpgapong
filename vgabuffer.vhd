
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



ENTITY vgabuffer IS
	GENERIC(
		DEPTH : INTEGER := 1
	);

	PORT (
		clk_in 			: IN  STD_LOGIC;
		frame_ready		: in  STD_LOGIC;

		frame_sync		: IN  STD_LOGIC;
		clk_out			: IN  STD_LOGIC;

		srl_in			: IN  STD_LOGIC_VECTOR(3*DEPTH - 1 DOWNTO 0);
		srl_out			: OUT STD_LOGIC_VECTOR(3*DEPTH - 1 DOWNTO 0)
	);
END vgabuffer;


ARCHITECTURE behavioral OF vgabuffer IS
	SIGNAL buffer_in	: STD_LOGIC_VECTOR(3*DEPTH*640*480 - 1 DOWNTO 0);
	SIGNAL frame		: STD_LOGIC_VECTOR(3*DEPTH*640*480 - 1 DOWNTO 0);
	SIGNAL buffer_out	: STD_LOGIC_VECTOR(3*DEPTH*640*480 - 1 DOWNTO 0);
BEGIN
	PROCESS(clk_in)
	BEGIN
		IF RISING_EDGE(clk_in) THEN
			--shift data in
			buffer_in(3*DEPTH*640*480 - 1 DOWNTO 3*DEPTH) <= buffer_in(3*DEPTH*640*480 - 3*DEPTH - 1 DOWNTO 0);
			buffer_in(3*DEPTH - 1 DOWNTO 0) <= srl_in;
		END IF;	
	END PROCESS;
	
	PROCESS (frame_ready)
	BEGIN
		IF RISING_EDGE(frame_ready) THEN
			frame <= buffer_in;
		END IF;
	END PROCESS;
	
	PROCESS (frame_sync)
	BEGIN
		IF RISING_EDGE(frame_sync) THEN
			buffer_out <= frame;
		END IF;
	END PROCESS;
		
	PROCESS(clk_out)
	BEGIN
		IF RISING_EDGE(clk_out) THEN
				--shift data out
				buffer_out(3*DEPTH*640*480 - 1 DOWNTO 3*DEPTH) <= buffer_in(3*DEPTH*640*480 - 3*DEPTH - 1 DOWNTO 0);
		END IF;
	END PROCESS;

	srl_out <= buffer_out(3*DEPTH*640*480 - 1 DOWNTO 3*DEPTH*640*480 - 3*DEPTH - 1);
END architecture;