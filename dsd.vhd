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
		LEDR : OUT std_logic_vector(17 downto 0);
		PS2_DAT : IN std_logic;
		PS2_CLK : IN std_logic;
		HEX0 : OUT std_logic_vector(6 downto 0);
		HEX1 : OUT std_logic_vector(6 downto 0);
		HEX2 : OUT std_logic_vector(6 downto 0);
		HEX3 : OUT std_logic_vector(6 downto 0);
		HEX4 : OUT std_logic_vector(6 downto 0);
		HEX5 : OUT std_logic_vector(6 downto 0);
		HEX6 : OUT std_logic_vector(6 downto 0);
		HEX7 : OUT std_logic_vector(6 downto 0)
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
			r_down			: IN	std_logic;
			l_score			: OUT integer range 0 to 99;
			r_score			: OUT integer range 0 to 99
		);
		end component;
		
		component keyb
		PORT(
			keyboard_clk	: IN  std_logic;
			keyboard_data	: IN  std_logic;
			clock_25Mhz		: IN  std_logic;
			l_down			: OUT std_logic;
			l_up				: OUT std_logic;
			r_down			: OUT std_logic;
			r_up				: OUT std_logic;
			led				: OUT std_logic_vector(17 downto 0)
		);
		END component;
		
		component DISPLAY_DECODER
		PORT(			
			value		: IN  integer range 0 to 9;
			update	: IN std_logic;
			display	: OUT std_logic_vector(6 downto 0)
		);
		end component;
		
		--signals for vgabuffer
		signal send_pixels	: std_logic;
		
		signal l_paddle		:  integer range 0 to 480;
		signal r_paddle  		:  integer range 0 to 480;
		signal ball_x 			:  integer range 0 to 640;
		signal ball_y 			:  integer range 0 to 480;
		
		signal game_clk			:  std_logic;

		signal x: integer range 0 to GAME_CLOCK_DIV; --game clock divider

		
		
		signal pixel_R		: std_logic_vector (9 downto 0);
		signal pixel_G		: std_logic_vector (9 downto 0);
		signal pixel_B		: std_logic_vector (9 downto 0);
		signal frame_sync		: std_logic;
		
  		signal l_up : std_logic;
		signal l_down : std_logic;
		signal r_up : std_logic;
		signal r_down : std_logic;
		
		signal k_ready : std_logic;
		signal l_score	: integer range 0 to 99;
		signal r_score	: integer range 0 to 99;
  
  
  BEGIN
  
	LEDR(17 downto 11) <= conv_std_logic_vector(l_score,7);
	LEDR(10 downto 4) <= conv_std_logic_vector(r_score,7);
	
 
  
	U1 : renderer
	PORT MAP(
			x 				=> horizontal_counter-HBP-HSYNC_TIME,
			y				=> vertical_counter-VBP-VSYNC_TIME,
			frame_sync 	=>frame_sync,
			enable  		=>send_pixels,
			
			pixel_R 		=>	pixel_R,
			pixel_G		=>	pixel_G, 
			pixel_B		=>	pixel_B, 
			
			lpaddle		=> l_paddle,
			rpaddle		=> r_paddle,
			ballx			=> ball_x,
			bally			=> ball_y
		  );
		  
	U2 : logic
	PORT MAP(
		l_paddle			=>l_paddle,
		r_paddle  		=>r_paddle,
		ball_x 			=>ball_x,
		ball_y 			=>ball_y,
		game_clock		=>game_clk,
		--l_up				=>KEY(3),
		--l_down			=>KEY(2),
		--r_up				=>KEY(1),
		--r_down			=>KEY(0),
		l_up				=>l_up,
		l_down			=>l_down,
		r_up				=>r_up,
		r_down			=>r_down,
		l_score			=>l_score,
		r_score			=>r_score
	);
	
	U3 : keyb
	PORT MAP(
			keyboard_clk	=> PS2_CLK,
			keyboard_data	=> PS2_DAT,
			clock_25Mhz 	=> CLOCK_25,
			l_down			=> l_down,
			l_up				=> l_up,
			r_down			=> r_down,
			r_up				=> r_up
	
	);
		
	U4 : DISPLAY_DECODER
	PORT MAP(			
			value		=> r_score mod 10,
			update	=> CLOCK_25,
			display	=> HEX4
	);
	
	U5 : DISPLAY_DECODER
	PORT MAP(			
			value		=> r_score/10,
			update	=> CLOCK_25,
			display	=> HEX5
	);
	
	U6 : DISPLAY_DECODER
	PORT MAP(			
			value		=> l_score mod 10,
			update	=> CLOCK_25,
			display	=> HEX6
	);
	
	U7 : DISPLAY_DECODER
	PORT MAP(			
			value		=> l_score/10,
			update	=> CLOCK_25,
			display	=> HEX7
	);
  
  VGA_SYNC<= '0';
  HEX0 <= "1111111";
  HEX1 <= "1111111";
  HEX2 <= "1111111";
  HEX3 <= "1111111";
  
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