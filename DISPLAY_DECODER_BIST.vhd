LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY DISPLAY_DECODER_BIST IS
	PORT(			
			value		: IN  integer range 0 to 9;
			update	: IN std_logic;
			display	: OUT std_logic_vector(6 downto 0);
			TEST_EN	: IN	std_logic;
			TEST_DONE: OUT std_logic;
			TEST_FAIL: OUT std_logic;
			VECTOR_OUT: OUT std_logic_vector(7 downto 0)
		);
END DISPLAY_DECODER_BIST;

ARCHITECTURE behv OF DISPLAY_DECODER_BIST IS	
		signal INPUT_OUT	: std_logic_vector (3 downto 0);
		signal OUTPUT_IN	: std_logic_vector (6 downto 0);
		signal TEST	: std_logic;

BEGIN

	BIST: entity WORK.BIST
		generic map(3,6,7)
		port map(conv_std_logic_vector(value,4),
					INPUT_OUT,
					OUTPUT_IN,
					display,
					"11101110",
					update,
					TEST_EN,
					TEST_done,
					TEST_FAIL,
					VECTOR_OUT);
		
	DISP: entity WORK.DISPLAY_DECODER
		port map (conv_integer(INPUT_OUT),update,OUTPUT_IN);

END architecture; 
