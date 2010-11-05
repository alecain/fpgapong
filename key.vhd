LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY keyb IS
	PORT(	keyboard_clk	: IN  std_logic;
			keyboard_data	: IN  std_logic;
			clock_25Mhz		: IN  std_logic;
			l_down			: OUT std_logic;
			l_up				: OUT std_logic;
			r_down			: OUT std_logic;
			r_up				: OUT std_logic;
			led				: OUT std_logic_vector(17 downto 0)
		);
END keyb;

ARCHITECTURE behv OF keyb IS
CONSTANT BREAKCODE 	: STD_LOGIC_VECTOR(7 DOWNTO 0) := "11110000";    -- Breakcode
CONSTANT LUP 			: STD_LOGIC_VECTOR(7 DOWNTO 0) := "00011101";    -- Scan code for 'W' up
CONSTANT LDOWN 		: STD_LOGIC_VECTOR(7 DOWNTO 0) := "00011011";    -- Scan code for 'S' up
CONSTANT RUP 			: STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000011";    -- Scan code for 'I' up
CONSTANT RDOWN 		: STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000010";    -- Scan code for 'K' up
	
SIGNAL incnt						: STD_LOGIC_VECTOR(3 downto 0);
SIGNAL shiftin						: STD_LOGIC_VECTOR(8 downto 0);
SIGNAL read_char					: STD_LOGIC;
SIGNAL inflag						: STD_LOGIC;
SIGNAL ready_set					: STD_LOGIC;
SIGNAL keyboard_clk_filtered	: STD_LOGIC;
SIGNAL filter						: STD_LOGIC_VECTOR(7 downto 0);
SIGNAL lower_code_buf			: STD_LOGIC_VECTOR(3 downto 0);
SIGNAL high_code_buf				: STD_LOGIC_VECTOR(3 downto 0);		
SIGNAL scan_code					: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL last_code					: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL keyup						: STD_LOGIC := '0';
SIGNAL srup							: std_logic := '0';
SIGNAL srdown						: std_logic := '0';
SIGNAL slup							: std_logic := '0';
SIGNAL sldown						: std_logic := '0';
SIGNAL scan_ready					: std_logic := '0';
SIGNAL rd							: std_logic := '0';

	
BEGIN

	PROCESS (rd, ready_set,clock_25Mhz)
	BEGIN
		IF RISING_EDGE(clock_25Mhz) THEN
			IF rd = '1' THEN 
				scan_ready <= '0';
			ELSIF ready_set = '1' THEN
				scan_ready <= '1';
			END IF;
		END IF;
	END PROCESS;

	
	l_up    <= slup;
	l_down  <= sldown;
	r_up    <= srup;
	r_down  <= srdown;

	led(17) <= slup;
	led(16) <= sldown;
	led(15) <= srup;
	led(14) <= srdown;

	led(13) <= READ_CHAR;
	led(12) <= ready_set;
	led(10) <= keyup;

	--This process reads in serial data coming from the terminal
	PROCESS
	BEGIN
		WAIT UNTIL (keyboard_clk'event AND keyboard_clk='1');
		
		IF keyboard_data='0' AND read_char='0' THEN
			read_char <= '1';
			ready_set <= '0';
		ELSE
			-- Shift in next 8 data bits to assemble a scan code
			IF read_char = '1' THEN
				IF incnt < "1001" THEN	-- If less than 9-bits keep shifting in data from keyboard
					incnt <= incnt + 1;
					shiftin(7 DOWNTO 0) <= shiftin(8 DOWNTO 1);
					shiftin(8) <= keyboard_data;
					ready_set <= '0';
				-- End of scan code character, so set flags and exit loop
				ELSE
					scan_code <= shiftin(7 DOWNTO 0);
					read_char <='0';
					ready_set <= '1'; --let the above procesess know that it's ready to read
					incnt <= "0000";
				END IF;
			END IF;
		END IF;
	END PROCESS;

	
	PROCESS
	BEGIN
		WAIT UNTIL (clock_25Mhz'event AND clock_25Mhz='1');
		-- Mark that we read
		IF scan_ready = '1' and rd = '0' THEN
			rd <= '1';
			led(7 downto 0) <= scan_code;
					
			last_code <= scan_code;

			IF keyup = '1' THEN
				keyup <='0';
					
				IF    scan_code = LUP   THEN slup   <= '0';
				ELSIF scan_code = LDOWN THEN sldown <= '0';
				ELSIF scan_code = RUP   THEN srup   <= '0';
				ELSIF scan_code = RDOWN THEN srdown <= '0';
				END IF;			
			ELSE
				IF    scan_code = BREAKCODE THEN keyup  <= '1';
				ELSIF scan_code = LUP       THEN slup   <= '1';
				ELSIF scan_code = LDOWN     THEN sldown <= '1';
				ELSIF scan_code = RUP       THEN srup   <= '1';
				ELSIF scan_code = RDOWN     THEN srdown <= '1';
				END IF;
			END IF;
		ELSIF READ_CHAR= '1' THEN --if we're reading in a new character, release read
			rd <= '0';
		END IF;
	END PROCESS;
END behv;