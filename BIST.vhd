
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



ENTITY BIST IS
	generic (
		INPUT_SIZE : 			integer:= 7;
		OUTPUT_SIZE : 			integer:= 7;
		REGISTER_SIZE :		integer := 7
	);
	
	PORT (
		INPUT_IN		: 	IN std_logic_vector (INPUT_SIZE downto 0);
		INPUT_OUT	: 	OUT std_logic_vector (INPUT_SIZE downto 0);
		
		OUTPUT_IN	: 	IN std_logic_vector (OUTPUT_SIZE downto 0);
		OUTPUT_OUT	: 	OUT std_logic_vector (OUTPUT_SIZE downto 0);
		
		VECTOR:			std_logic_vector(REGISTER_SIZE downto 0);
		
		CLK			:  IN std_logic;
		TEST_EN		: 	IN	STD_logic;
		
		TEST_DONE	:  OUT std_logic:='0';
		TEST_FAIL	:  OUT std_logic:='1';
		VECTOR_OUT	:	OUT std_logic_vector(REGISTER_SIZE downto 0)
	);
end BIST;

architecture behavioral of BIST is

	
	component PRBS_REG is 
		generic (
			OUTPUT_SIZE : 			integer:= 8
		);
		PORT (
			INPUT_OUT	: 	OUT std_logic_vector (INPUT_SIZE downto 0);
			CLK			:  IN std_logic;
			TEST_EN		: 	IN	STD_logic
		);
	end component;
	
	
	signal TEST_RUNNING: std_logic :='0';
	signal PRBS 		: std_logic_vector (INPUT_SIZE downto 0);
	signal Comp_in		: std_logic_vector (OUTPUT_SIZE downto 0);
	signal comp_out	: std_logic_vector (REGISTER_SIZE downto 0);
	signal counter		: integer :=0 ;
	signal s_OUTPUT_OUT: std_logic_vector (OUTPUT_SIZE downto 0);
	

BEGIN
	generator: PRBS_REG 	generic map (OUTPUT_SIZE => INPUT_SIZE) 
								port map (PRBS, CLK, TEST_RUNNING);
								
	compressor: entity WORK.COMP_REG generic map (INPUT_SIZE=>OUTPUT_SIZE,REGISTER_SIZE=>REGISTER_SIZE)
								port map (Comp_in,comp_out,CLK, TEST_RUNNING);
				
	OUTPUT_OUT <= s_OUTPUT_OUT;
	--VECTOR_OUT <= comp_out;
	
	
	process(CLK)
	begin
		if (rising_edge(CLK)) then
			-- handle input/output routing
			if (TEST_EN = '1' or counter /=0) then
				if (counter =  (2**OUTPUT_SIZE)-1) then
					TEST_RUNNING<='0';
					TEST_DONE<='1';
					counter<=0;
					INPUT_OUT <= INPUT_IN;
					s_OUTPUT_OUT <= OUTPUT_IN;
					
					VECTOR_OUT <= comp_out;
					if (comp_out = VECTOR) then
						TEST_FAIL<='0';
					else
						TEST_FAIL<='1';
					end if;
				else
					TEST_FAIL<='0';
					TEST_DONE<='0';
					TEST_RUNNING<='1';
					INPUT_OUT <= PRBS;
					Comp_in <= OUTPUT_IN;
					s_OUTPUT_OUT <= conv_std_logic_vector(0,OUTPUT_SIZE+1);
					counter <= counter + 1;
				end if;
			else
				counter <= 0;
				INPUT_OUT <= INPUT_IN;
				s_OUTPUT_OUT <= OUTPUT_IN;
			end if;
			
		end if;
	end process;
end architecture;
	