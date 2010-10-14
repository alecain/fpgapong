
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



ENTITY vgabuffer IS
	generic(
			depth: integer := 1
			  );
PORT (
			clk_in 			: IN std_logic;
			frame_ready		: in std_logic;
			
			frame_sync		: IN std_logic;
			clk_out			: IN std_logic;

			srl_in			: IN std_logic_vector (3*depth-1 downto 0);
			srl_out			: OUT std_logic_vector (3*depth-1 downto 0)

		);
END vgabuffer;


architecture behavioral of vgabuffer is
		
		signal buffer_in: std_logic_vector (3*depth*640*480-1 downto 0);
		signal frame: std_logic_vector (3*depth*640*480-1 downto 0);
		signal buffer_out: std_logic_vector (3*depth*640*480-1 downto 0);
begin
	process(clk_in)
	begin
		if rising_edge(clk_in) then
			--shift data in
			buffer_in(3*depth*640*480-1 downto 3*depth) <= buffer_in(3*depth*640*480-3*depth-1 downto 0);
			buffer_in(3*depth-1 downto 0) <=srl_in;
		end if;	
	end process;
	
	process (frame_ready)
	begin
		if rising_edge(frame_ready) then
			frame<= buffer_in;
		end if;	
	end process;
	
	process (frame_sync)
	begin 
		if rising_edge(frame_sync) then
			buffer_out<= frame;
		end if;	
	end process;
		
	process(clk_out)
	begin 
		if rising_edge(clk_out) then
				--shift data out
				buffer_out(3*depth*640*480-1 downto 3*depth) <= buffer_in(3*depth*640*480-3*depth-1 downto 0);
				
		end if;	
	end process;

	srl_out<=buffer_out(3*depth*640*480-1 downto 3*depth*640*480-3*depth-1);
	
	
end architecture;