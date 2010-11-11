LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY dsd IS
	PORT (
			clock_50 	: IN STD_LOGIC;							--50Mhz clock
			key			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0); --RESET
			vga_b			: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			vga_r			: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			vga_g			: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			vga_clk 		: OUT STD_LOGIC;
			vga_blank	: OUT STD_LOGIC; 							--ACTIVE LOW
			vga_sync		: OUT STD_LOGIC;
			vga_hs		: OUT STD_LOGIC;
			vga_vs		: OUT STD_LOGIC;
			ledr			: OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
			ps2_dat		: IN  STD_LOGIC;
			ps2_clk		: IN  STD_LOGIC;
			hex0 			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			hex1 			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			hex2 			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			hex3 			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			hex4 			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			hex5 			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			hex6 			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			hex7 			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
END dsd;

ARCHITECTURE vg OF dsd IS
	CONSTANT HFP			: INTEGER := 24;		-- Front porch (horizontal)
	CONSTANT HBP			: INTEGER := 47;		-- Back porch (horizontal)
	CONSTANT H_VIDEO		: INTEGER := 640;		-- Active video time (horizontal)
	CONSTANT HSYNC_TIME	: INTEGER := 94;		-- H_Sync pulse lenght 
	CONSTANT LINE_TIME	: INTEGER := 794;

	--vertical consts (in lines)

	CONSTANT FRAME_TIME		: INTEGER := 525;
	CONSTANT VSYNC_TIME		: INTEGER := 2; 	-- V_Sync pulse lenght 
	CONSTANT V_VIDEO_TIME	: INTEGER := 480;
	CONSTANT VFP				: INTEGER := 10; 	--Front porch (vertical)
	CONSTANT VBP				: INTEGER := 33; 	--Back porch (vertical)
	CONSTANT GAME_CLOCK_DIV	: INTEGER := 1000000;
	

	SIGNAL clock_25				: STD_LOGIC;	--25Mhz clock
	SIGNAL horizontal_counter	: INTEGER RANGE 0 TO 794;
	SIGNAL vertical_counter		: INTEGER RANGE 0 TO 525;
	SIGNAL frames					: INTEGER;

	--signals for vgabuffer

	SIGNAL send_pixels	: STD_LOGIC;

	SIGNAL l_paddle	: INTEGER RANGE 0 TO 480;
	SIGNAL r_paddle  	: INTEGER RANGE 0 TO 480;
	SIGNAL ball_x 		: INTEGER RANGE 0 TO 640;
	SIGNAL ball_y 		: INTEGER RANGE 0 TO 480;

	SIGNAL game_clk	: STD_LOGIC;
	SIGNAL x				: INTEGER RANGE 0 TO GAME_CLOCK_DIV;	--game clock divider

	SIGNAL pixel_R		: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL pixel_G		: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL pixel_B		: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL frame_sync	: STD_LOGIC;

	SIGNAL l_up 		: STD_LOGIC;
	SIGNAL l_down 		: STD_LOGIC;
	SIGNAL r_up 		: STD_LOGIC;
	SIGNAL r_down 		: STD_LOGIC;

	SIGNAL k_ready 	: STD_LOGIC;
	SIGNAL l_score		: INTEGER RANGE 0 TO 99;
	SIGNAL r_score		: INTEGER RANGE 0 TO 99;
		
	signal TEST_DONE	:	std_logic :='0';
	signal TEST_FAIL	:	std_logic :='1';


	COMPONENT renderer
		PORT (
			x 				: IN  INTEGER RANGE 0 TO 640;
			y 				: IN  INTEGER RANGE 0 TO 480;
			frame_sync	: in  STD_LOGIC;
			enable		: in  STD_LOGIC;
	
			pixel_R		: OUT STD_LOGIC_VECTOR(9 DOWNTO 0); 
			pixel_G		: OUT STD_LOGIC_VECTOR(9 DOWNTO 0); 
			pixel_B		: OUT STD_LOGIC_VECTOR(9 DOWNTO 0); 
	
			lpaddle		: in  INTEGER;
			rpaddle		: in  INTEGER;
			ballx			: in  INTEGER;
			bally			: in  INTEGER
		);
	END COMPONENT;

	COMPONENT logic
		PORT (
			l_paddle		: OUT INTEGER RANGE 0 TO 480;
			r_paddle  	: OUT INTEGER RANGE 0 TO 480;
			ball_x 		: OUT INTEGER RANGE 0 TO 640;
			ball_y 		: OUT INTEGER RANGE 0 TO 480;
			game_clock	: IN  STD_LOGIC;
			l_up			: IN  STD_LOGIC;
			l_down		: IN  STD_LOGIC;
			r_up			: IN  STD_LOGIC;
			r_down		: IN  STD_LOGIC;
			l_score		: OUT INTEGER RANGE 0 TO 99;
			r_score		: OUT INTEGER RANGE 0 TO 99
		);
	END COMPONENT;

	COMPONENT keyb
		PORT(
			keyboard_clk	: IN  STD_LOGIC;
			keyboard_data	: IN  STD_LOGIC;
			clock_25Mhz		: IN  STD_LOGIC;
			l_down			: OUT STD_LOGIC;
			l_up				: OUT STD_LOGIC;
			r_down			: OUT STD_LOGIC;
			r_up				: OUT STD_LOGIC;
			led				: OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT DISPLAY_DECODER
		PORT(
			value		: IN  INTEGER RANGE 0 TO 9;
			update	: IN  STD_LOGIC;
			display	: OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;


BEGIN
	LEDR(17 DOWNTO 11) <= CONV_STD_LOGIC_VECTOR(l_score, 7);
	LEDR(10 DOWNTO 4)  <= CONV_STD_LOGIC_VECTOR(r_score, 7);

	U1 : renderer
	PORT MAP(
		x 				=> horizontal_counter - HBP - HSYNC_TIME,
		y				=> vertical_counter - VBP - VSYNC_TIME,
		frame_sync 	=> frame_sync,
		enable 	 	=> send_pixels,

		pixel_R 	=>	pixel_R,
		pixel_G	=>	pixel_G, 
		pixel_B	=>	pixel_B, 

		lpaddle	=> l_paddle,
		rpaddle	=> r_paddle,
		ballx		=> ball_x,
		bally		=> ball_y
	);

	U2 : logic
	PORT MAP(
		l_paddle		=> l_paddle,
		r_paddle  	=> r_paddle,
		ball_x 		=> ball_x,
		ball_y 		=> ball_y,
		game_clock	=> game_clk,
		l_up			=> l_up,
		l_down		=> l_down,
		r_up			=> r_up,
		r_down		=> r_down,
		l_score		=> l_score,
		r_score		=> r_score
	);

	U3 : keyb
	PORT MAP(
		keyboard_clk	=> ps2_clk,
		keyboard_data	=> ps2_dat,
		clock_25Mhz 	=> clock_25,
		l_down			=> l_down,
		l_up				=> l_up,
		r_down			=> r_down,
		r_up				=> r_up
	);

	U4 : DISPLAY_DECODER
	PORT MAP(
		value		=> r_score mod 10,
		update	=> clock_25,
		display	=> hex4
	);

	U5 : DISPLAY_DECODER
	PORT MAP(
			value		=> r_score/10,
			update	=> clock_25,
			display	=> hex5
	);

	U6 : DISPLAY_DECODER
	PORT MAP(
			value		=> l_score mod 10,
			update	=> clock_25,
			display	=> hex6
	);

	--U7 : DISPLAY_DECODER
	--PORT MAP(
	--		value		=> l_score/10,
	--		update	=> clock_25,
	--		display	=> hex7
	--);
	
	U7: entity WORK.DISPLAY_DECODER_BIST
		port map(l_score/10, CLOCK_25 , HEX7 , (not KEY(0)) ,TEST_DONE, TEST_FAIL);
	
	LEDR(0)<= TEST_DONE and (TEST_FAIL);

	vga_sync <= '0';

	hex0	<= "1111111";
	hex1  <= "1111111";
	hex2  <= "1111111";
	hex3  <= "1111111";

	--generate a 2Hz clock
	PROCESS (clock_50)
	BEGIN
		IF RISING_EDGE(clock_50) THEN
			x <= x+1;

			IF x < GAME_CLOCK_DIV/2 THEN
				game_clk <= '1';
			ELSE
				game_clk <= '0';
			END IF;
		END IF;
	END PROCESS;

	-- generate a 25Mhz clock
	PROCESS (clock_50)
	BEGIN
		IF RISING_EDGE(clock_50) THEN
			IF (clock_25 = '0') THEN
				clock_25 <= '1';
				vga_clk <= '1';
			ELSE
				clock_25 <= '0';
				vga_clk <= '0';
			END IF;
		END IF;
	END PROCESS;

	-- Only get new pixels when we are sending them
	PROCESS (clock_25) 
	BEGIN
		IF RISING_EDGE(clock_25) THEN
			IF horizontal_counter >= HBP + HSYNC_TIME 	-- 144
				AND horizontal_counter < LINE_TIME - HFP 	-- 784
				AND vertical_counter >= VBP + VSYNC_TIME	-- 39
				AND vertical_counter < FRAME_TIME - VFP 	-- 519		 
			THEN
				send_pixels <='1';
				--Send pixel data

				vga_r <= pixel_R;
				vga_g <= pixel_G;
				vga_b <= pixel_B;

				vga_blank <= '1';

			ELSE
				send_pixels <='0';

				vga_blank <= '0';

				vga_r <= "0000000000";
				vga_b <= "0000000000";
				vga_g <= "0000000000";
			END IF;

			--Horizontal Sync

			IF horizontal_counter > 0 
				AND horizontal_counter < HSYNC_TIME	-- 96+1
			THEN
				vga_hs <= '0';
			ELSE
				vga_hs <= '1';
			END IF;

			--Vertical Sync
			IF vertical_counter > 0 
				AND vertical_counter < VSYNC_TIME	-- 2+1
			THEN
				vga_vs <= '0';
				frame_sync <='1';
			ELSE
				vga_vs <= '1';
				frame_sync <='0';
			END IF;
		END IF;
	END PROCESS;

	PROCESS(clock_25)
	BEGIN
		IF RISING_EDGE(clock_25) THEN
			--check for end of line
			IF (horizontal_counter >= LINE_TIME) THEN
				vertical_counter <= vertical_counter + 1;
				horizontal_counter <= 1;
				frames <= frames + 1;
			ELSE
				--increment horizontal counter
				horizontal_counter <= horizontal_counter + 1;
			END IF;

			--check for end of frame
			IF vertical_counter = FRAME_TIME THEN		    
				vertical_counter <= 0;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;
