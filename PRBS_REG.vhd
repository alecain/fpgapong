LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY PRBS_REG IS
	generic (
		OUTPUT_SIZE : 			integer:= 8
	);
	
	PORT (
		INPUT_OUT	: 	OUT std_logic_vector (OUTPUT_SIZE downto 0);
		CLK			:  IN std_logic;
		TEST_EN		: 	IN	STD_logic
	);
end PRBS_REG;


architecture behavioral of PRBS_REG is
	signal PRBS 		: std_logic_vector (OUTPUT_SIZE downto 0);

BEGIN
	INPUT_OUT<=PRBS;
	process(CLK)
	begin
		if (rising_edge(CLK)) then
			-- handle input/output routing
			if (TEST_EN = '1') then
				--4 bits
				if(OUTPUT_SIZE = 3) then
					PRBS <= PRBS (2 downto 0) & ((PRBS(2) xor PRBS(3)));
					
				--8 bits
				elsif (OUTPUT_SIZE = 7) then
					PRBS <= PRBS(OUTPUT_SIZE-1 downto 0) & (PRBS(7) xor PRBS(5) xor PRBS(4) xor PRBS(3));
					
					
				--10 bits
				elsif (OUTPUT_SIZE = 9) then
					PRBS <= PRBS(OUTPUT_SIZE-1 downto 0) & (PRBS(9) xor PRBS(6));
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
				for i in 0 to OUTPUT_SIZE loop --if test isn't enabled, make sure to start PRBS at all 1s.
					PRBS(i)<='1';
				end loop;
			end if;
		end if;
	end process;
end architecture;