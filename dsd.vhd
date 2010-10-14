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
		LEDR : OUT std_logic_vector(17 downto 0));
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
		
		
		 component vgabuffer
		 PORT (
			srl_in			: IN std_logic_vector (2 downto 0);
			clk_in 			: IN std_logic;
			frame_ready		: in std_logic;
			
			frame_sync		: IN std_logic;
			srl_out			: OUT std_logic_vector (2 downto 0);
			clk_out			: IN std_logic
		 );
		END component;

		--signals for vgabuffer
		signal pxl_clk_out 	: std_logic;
		signal send_pixels	: std_logic;
		signal pixeldata		: std_logic_vector (2 downto 0);
		signal frame_sync		: std_logic;
		
  BEGIN
  
	U1 : vgabuffer
    port map (
				srl_in => "000",
				clk_in => '0',
				frame_ready	=>'0',
				
				frame_sync => frame_sync,
				srl_out=> pixeldata,
				clk_out=> pxl_clk_out
			);

  
  
  VGA_SYNC<= '0';
  

  
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
	pxl_clk_out<=CLOCK_25 and send_pixels;

	process (CLOCK_25) 
	begin
		
		
		if rising_edge(CLOCK_25) then
	  
		 if (horizontal_counter >= HBP+HSYNC_TIME ) -- 144
		 and (horizontal_counter < LINE_TIME-HFP ) -- 784
		 and (vertical_counter >= VBP+VSYNC_TIME ) -- 39
		 and (vertical_counter < FRAME_TIME-VFP ) -- 519
		 then
			send_pixels <='1';
			LEDR(2)<='1';
			--Send pixel data
			VGA_R(9) <= pixeldata(2);
			VGA_B(9) <= pixeldata(1);
			VGA_G(9) <= pixeldata(0);
			VGA_BLANK <= '1';
		 
		else
			send_pixels <='0';
			
			LEDR(2)<='0';
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
			LEDR(9)<='1';
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

			 LEDR(8 downto 4) <= conv_std_logic_vector(frames,5);
			 
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