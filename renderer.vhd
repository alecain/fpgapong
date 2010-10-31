
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



ENTITY renderer IS
	generic(
			depth: integer := 1
			  );
PORT (
			x 					: IN integer range 0 to 640;
			y 					: IN integer range 0 to 480;
			frame_sync		: in std_logic;
			enable			: in std_logic;
			
			pixel_R			: OUT std_logic_vector(9 downto 0); 
			pixel_G			: OUT std_logic_vector(9 downto 0); 
			pixel_B			: OUT std_logic_vector(9 downto 0); 
			
			lpaddle			:in integer;
			rpaddle			:in integer;
			ballx				:in integer;
			bally				:in integer
			
			
		);
END renderer;


architecture behavioral of renderer is
		--signal x : integer range 0 to 640 :=0;
		--signal y : integer range 0 to 480 :=0;
		
begin			

process(x,y)
begin
		if (x<=ballx+10 and
				x>=ballx-10 and
				y <=bally+10 and
				y >= bally-10) then
				pixel_R<="1111111111";
				pixel_G<="1111111111";
				pixel_B<="1111111111";
				
			elsif (x<=20+10 and
				 x>=20-10 and
				y <=lpaddle+40 and
				y >= lpaddle-40) then
				pixel_R<="1111111111";
				pixel_G<="0000000000";
				pixel_B<="0000000000";
			elsif (x<=600+10 and
				 x>=600-10 and
				y <=rpaddle+40 and
				y >=rpaddle-40) then
				pixel_R<="0000000000";
				pixel_G<="0000000000";
				pixel_B<="1111111111";
		else
			pixel_R<="0000000000";
			pixel_G<="0001111111";
			pixel_B<="0000000000";
		end if;
		
	end process;
	--pixel_G<="1111111111";

end;