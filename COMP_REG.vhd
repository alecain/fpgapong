LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY COMP_REG IS
	generic (
		INPUT_SIZE : 			integer:= 8;
		REGISTER_SIZE :		integer := 8
	);
	
	PORT (
		COMP_IN		: 	IN std_logic_vector (INPUT_SIZE downto 0);
		COMP_OUT		: 	OUT std_logic_vector (REGISTER_SIZE downto 0);
		CLK			:  IN std_logic;
		TEST_EN		: 	IN	STD_logic
	);
end COMP_REG;


architecture behavioral of COMP_REG is
	signal COMP 		: std_logic_vector (REGISTER_SIZE downto 0);
	
BEGIN
	COMP_OUT<= COMP;

	process(CLK)
		variable padding		: std_logic_vector (REGISTER_SIZE-INPUT_SIZE-1 downto 0);
	begin
		if (rising_edge(CLK)) then
			-- handle input/output routing
			if (TEST_EN = '1') then
				padding := conv_std_logic_vector(0,REGISTER_SIZE-INPUT_SIZE);

				--4 bits
				if(REGISTER_SIZE = 3) then
					COMP <= (COMP (REGISTER_SIZE-1 downto 0) & (COMP(2) xor COMP(3))) xor padding & COMP_IN;
					
				--8 bits
				elsif (REGISTER_SIZE = 7) then
					COMP <= (COMP(REGISTER_SIZE-1 downto 0) 
									& (COMP(6) xor COMP(5) xor COMP(4) xor COMP(2)) ) 
								xor  (padding & COMP_IN);
					
				--10 bits
				elsif (INPUT_SIZE = 9) then
					COMP <= (COMP(REGISTER_SIZE-1 downto 0) & (COMP(9) xor COMP(6))) xor  padding & COMP_IN;
				end if;
					
				--2	x2 + x + 1						3
				--3	x3 + x2 + 1						7
				--4	x4 + x3 + 1						15
				--5	x5 + x3 + 1						31
				--6	x6 + x5 + 1						63
				--7	x7 + x6 + 1						127
				--8	x8 + x6 + x5 + x4 + 1		255
				--9	x9 + x5 + 1						511
				--10	x10 + x7 + 1					1023
				--11	x11 + x9 + 1					2047
				--12	x12 + x11 + x10 + x4 + 1	4095
				--13	x13 + x12 + x11 + x8 + 1	8191
				--14	x14 + x13 + x12 + x2 + 1	16383
				--15	x15 + x14 + 1					32767
				--16	x16 + x14 + x13 + x11 + 1	65535
				--17	x17 + x14 + 1					131071
				--18	x18 + x11 + 1					262143
				--19	x19 + x18 + x17 + x14 + 1	524287
			
			else
				for i in 0 to REGISTER_SIZE loop --if test isn't enabled, make sure to start at 0
					COMP(i)<='1';
				end loop;
			end if;
		end if;
	end process;
end architecture;