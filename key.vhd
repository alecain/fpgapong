LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY keyb IS
	PORT(	--keyboard_clk, keyboard_data, clock_25Mhz , 
			--reset, rd		: IN STD_LOGIC;
			--scan_code		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			--scan_ready		: OUT STD_LOGIC);
			
			
			keyboard_clk	: IN  std_logic;
			keyboard_data	: IN  std_logic;
			clock_25Mhz		: IN  std_logic;
			l_down			: OUT std_logic;
			l_up				: OUT std_logic;
			r_down			: OUT std_logic;
			r_up				: OUT std_logic;
			
			led				: OUT std_logic_vector(17 downto 0)
		);
END keyb;

ARCHITECTURE a OF keyb IS
CONSTANT BREAKCODE : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11110000";
CONSTANT LUP : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00011101";    -- Scan code for 'W' up
CONSTANT LDOWN : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00011011";    -- Scan code for 'S' up
CONSTANT RUP : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000011";    -- Scan code for 'I' up
CONSTANT RDOWN : STD_LOGIC_VECTOR (7 DOWNTO 0) :="01000010";    -- Scan code for 'K' up
	
SIGNAL INCNT			            : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL SHIFTIN 				        : STD_LOGIC_VECTOR(8 downto 0);
SIGNAL READ_CHAR 			        : STD_LOGIC;
SIGNAL INFLAG, ready_set		    : STD_LOGIC;
SIGNAL keyboard_clk_filtered 		: STD_LOGIC;
SIGNAL filter 					    : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL lower_code_buf				: STD_LOGIC_VECTOR(3 downto 0);
SIGNAL high_code_buf				: STD_LOGIC_VECTOR(3 downto 0);		
signal scan_code		: STD_LOGIC_VECTOR(7 DOWNTO 0);
signal last_code		: STD_LOGIC_VECTOR(7 DOWNTO 0);

signal keyup		: std_logic := '0';

signal srup : std_logic := '0';
signal srdown : std_logic := '0';
signal slup : std_logic := '0';
signal sldown : std_logic := '0';
signal scan_ready : std_logic := '0';
signal rd: std_logic := '0';

	
BEGIN

	PROCESS (rd, ready_set,clock_25Mhz)
	BEGIN
		if (rising_edge(clock_25Mhz)) then
		  IF rd = '1' THEN 
				scan_ready <= '0';
		  ELSIF ready_set = '1' THEN
			scan_ready <= '1';
		  END IF;
		end if;
	END PROCESS;

	
	l_up <= slup;
	l_down <= sldown;
	r_up <= srup;
	r_down <= srdown;

	led(17) <= slup;
	led(16) <= sldown;
	led(15) <= srup;
	led(14) <= srdown;

	led(13) <= READ_CHAR;
	led(12) <= ready_set;
	led(10)   <= keyup;


	--This process filters the raw clock signal coming from the keyboard using a shift register and two AND gates
	--Clock_filter: PROCESS
	--BEGIN
	--	WAIT UNTIL clock_25Mhz'EVENT AND clock_25Mhz= '1';
	--	filter (6 DOWNTO 0) <= filter(7 DOWNTO 1) ;
	--	filter(7) <= keyboard_clk;

	--	IF filter = "11111111" THEN		-- If 0hFF set keyboard_clk_filtered
	--		keyboard_clk_filtered <= '1';
	--	ELSIF  filter= "00000000" THEN 
	--		keyboard_clk_filtered <= '0';
	--	END IF;

	--END PROCESS Clock_filter;

	--This process reads in serial data coming from the terminal
	PROCESS
	BEGIN
	WAIT UNTIL (KEYBOARD_CLK'EVENT AND KEYBOARD_CLK='1');
	  IF KEYBOARD_DATA='0' AND READ_CHAR='0' THEN
			  READ_CHAR<= '1';
			  ready_set<= '0';
	  ELSE

		 -- Shift in next 8 data bits to assemble a scan code
		IF READ_CHAR = '1' THEN
			IF INCNT < "1001" THEN	-- If less than 9-bits keep shifting in data from keyboard
				INCNT <= INCNT + 1;
				SHIFTIN(7 DOWNTO 0) <= SHIFTIN(8 DOWNTO 1);
				SHIFTIN(8) <= KEYBOARD_DATA;
				ready_set <= '0';
			-- End of scan code character, so set flags and exit loop
			ELSE
				scan_code <= SHIFTIN(7 DOWNTO 0);
				READ_CHAR <='0';
				ready_set <= '1'; --let the above procesess know that it's ready to read
				INCNT <= "0000";
			end if;
		 END IF;
	 END IF;
END PROCESS;

	
	process
	begin
	WAIT UNTIL (clock_25Mhz'EVENT AND clock_25Mhz='1');
		--mark the we read
		if (scan_ready = '1' and rd = '0' ) then
			rd <= '1';
			led(7 downto 0) <= scan_code;
					
			last_code<= scan_code;

			if (keyup = '1') then
					keyup <='0';
	
					
				if (scan_code = LUP) then
					slup <= '0';
				elsif (scan_code = LDOWN) then
					sldown <= '0';
				elsif (scan_code = RUP) then
					srup <= '0';
				elsif (scan_code = RDOWN) then
					srdown <= '0';
				end if;			
			else
				if (scan_code = BREAKCODE) then
					keyup <='1';
				end if;		
				if(scan_code = LUP) then
					slup <= '1';
				end if;
				if (scan_code = LDOWN) then
					sldown <= '1';
				end if;
				if (scan_code = RUP) then
					srup <= '1';
				end if;
				if (scan_code = RDOWN) then
					srdown <= '1';
				end if;
			end if;
		elsif (READ_CHAR= '1') then --if we're reading in a new character, release read
			rd <= '0';
		end if;
	END PROCESS;
	
	
	
end a;