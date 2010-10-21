LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY dsd IS
PORT (CLOCK_50 : IN std_logic;          --50Mhz clock
      KEY : IN std_logic_vector(3 downto 0); --RESET
      VGA_B: OUT std_logic_vector(9 downto 0); 
      VGA_R: OUT std_logic_vector(9 downto 0); 
      VGA_G: OUT std_logic_vector(9 downto 0); 
      VGA_CLK : OUT std_logic; 
      VGA_BLANK :OUT std_logic; --active low
      VGA_SYNC : OUT std_logic;
      VGA_HS : OUT std_logic; 
      VGA_VS : OUT std_logic;
		LEDR : OUT std_logic_vector(17 downto 0)
		);
END dsd;

architecture vg OF dsd IS
       SIGNAL CLOCK_25 : std_logic;    --25Mhz clock
		 
		 signal horizontal_counter : integer range 0 to 794 ;
		 signal vertical_counter   : integer range 0 to 525;
		 signal frames					: integer;
		
	
		 CONSTANT HFP : integer := 24;    --Front porch (horizontal)
       CONSTANT HBP : integer := 47;    --Back porch (horizontal)
		 CONSTANT H_VIDEO: integer := 640; --Active video time (horizontal)
       CONSTANT HSYNC_TIME : integer := 94; -- H_Sync pulse lenght 
		 CONSTANT LINE_TIME: integer := 794;
		 
		 --vertical consts (in lines)
		 
		 CONSTANT FRAME_TIME: integer := 525;
		 CONSTANT VSYNC_TIME : integer := 2; -- V_Sync pulse lenght 
       CONSTANT V_VIDEO_TIME: integer := 480;
		 CONSTANT VFP : integer := 10; --Front porch (vertical)
       CONSTANT VBP : integer := 33; --Back porch (vertical)
		
		 CONSTANT GAME_CLOCK_DIV : integer := 1000000;
		
		 component renderer
		 PORT (
			clk_in 			: IN std_logic;
			frame_sync		: in std_logic;
			enable			: in std_logic;
			
			pixel_R			: OUT std_logic_vector(9 downto 0); 
			pixel_G			: OUT std_logic_vector(9 downto 0); 
			pixel_B			: OUT std_logic_vector(9 downto 0); 
			
			lpaddle			:in integer;
			rpaddle			:in integer;
			ballx				:in integer;
			bally				:in integer;

			LEDR : OUT std_logic_vector(17 downto 0)
			
		  );
		END component;
		
		component logic
		 PORT (
			l_paddle			: OUT integer range 0 to 480;
			r_paddle  		: OUT integer range 0 to 480;
			ball_x 			: OUT integer range 0 to 640;
			ball_y 			: OUT integer range 0 to 480;
			game_clock		: IN  std_logic;
			l_up				: IN  std_logic;
			l_down			: IN  std_logic;
			r_up				: IN  std_logic;
			r_down			: IN	std_logic
		);
		end component;

		--signals for vgabuffer
		signal send_pixels	: std_logic;
		
		signal l_paddle			:  integer range 0 to 480;
		signal r_paddle  		:  integer range 0 to 480;
		signal ball_x 			:  integer range 0 to 640;
		signal ball_y 			:  integer range 0 to 480;
		
		signal game_clk			:  std_logic;

		signal x: integer range 0 to GAME_CLOCK_DIV; --game clock divider

		
		
		signal pixel_R		: std_logic_vector (9 downto 0);
		signal pixel_G		: std_logic_vector (9 downto 0);
		signal pixel_B		: std_logic_vector (9 downto 0);
		signal frame_sync		: std_logic;
		
  BEGIN
  
	U1 : renderer
	PORT MAP(
			clk_in 		=> CLOCK_25,
			frame_sync 	=>frame_sync,
			enable  		=>send_pixels,
			
			pixel_R 		=>	pixel_R,
			pixel_G		=>	pixel_G, 
			pixel_B		=>	pixel_B, 
			
			lpaddle		=> l_paddle,
			rpaddle		=> r_paddle,
			ballx			=> ball_x,
			bally			=> ball_y,
			LEDR			=> LEDR
		  );
	U2 : logic
	
	PORT MAP(
		l_paddle			=>l_paddle,
		r_paddle  		=>r_paddle,
		ball_x 			=>ball_x,
		ball_y 			=>ball_y,
		game_clock		=>game_clk,
		l_up				=>KEY(3),
		l_down			=>KEY(2),
		r_up				=>KEY(1),
		r_down			=>KEY(0)
	);

  
  
  VGA_SYNC<= '0';
  
	--generate a 2Hz clock
	process (CLOCK_50)
	begin
		if  rising_edge(CLOCK_50) then
			x<=x+1;
			
			if (x<GAME_CLOCK_DIV/2) then
				game_clk<='1';
			else
				game_clk<='0';
			end if;
		end if;
	
	
	end process;
	
  
  
	-- generate a 25Mhz clock
	process (CLOCK_50)
	begin
	  if  rising_edge(CLOCK_50) then
		 if (CLOCK_25 = '0') then
			CLOCK_25 <= '1';
			VGA_CLK <= '1';
		 else
			CLOCK_25 <= '0';
			VGA_CLK <= '0';
		 end if;
	  end if;
	end process;

	-- Only get new pixels when we are sending them

	process (CLOCK_25) 
	begin
		
		
		if rising_edge(CLOCK_25) then
	  
		 if (horizontal_counter >= HBP+HSYNC_TIME ) -- 144
		 and (horizontal_counter < LINE_TIME-HFP ) -- 784
		 and (vertical_counter >= VBP+VSYNC_TIME ) -- 39
		 and (vertical_counter < FRAME_TIME-VFP ) -- 519		 
		 then
			send_pixels <='1';

			--Send pixel data
			
			--VGA_R <= conv_std_logic_vector(horizontal_counter,10);
			--VGA_B <= conv_std_logic_vector(vertical_counter,10);
			--VGA_G <= conv_std_logic_vector(horizontal_counter*vertical_counter,10);
			
			VGA_R <= pixel_R;
			VGA_G <= pixel_G;
			VGA_B <= pixel_B;
			
			VGA_BLANK <= '1';
		 
		else
			send_pixels <='0';
			
			VGA_BLANK <= '0';
			VGA_R <= "0000000000";
			VGA_B <= "0000000000";
			VGA_G <= "0000000000";
		 end if;
		 
		 
		 --Horizontal Sync
		 
		 if (horizontal_counter > 0 )
			and (horizontal_counter < HSYNC_TIME ) -- 96+1
		 then
			VGA_HS <= '0';
		 else
			VGA_HS <= '1';
		 end if;
		 
		 --Vertical Sync
		 if (vertical_counter > 0 )
			and (vertical_counter < VSYNC_TIME ) -- 2+1
		 then
			VGA_VS <= '0';
			frame_sync<='1';
		 else
			VGA_VS <= '1';
			frame_sync <='0';
		 end if;
	end if;
end process;
	
	process(CLOCK_25)
	begin
		if rising_edge(CLOCK_25) then

			 
			 --check for end of line
			 if (horizontal_counter >= LINE_TIME) then
				vertical_counter <= vertical_counter+1;
				horizontal_counter <= 1;
				frames<=frames+1;
			 else
			 	 --increment horizontal counter
				 horizontal_counter <= horizontal_counter+1;
			 end if;
			 
			 --check for end of frame
			 if (vertical_counter = FRAME_TIME) then		    
				vertical_counter <= 0;
			 end if;
	  end if;
	end process;
END ARCHITECTURE;