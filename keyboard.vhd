
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



ENTITY keyboard IS
PORT (
			kb_clk			: IN  std_logic;
			kb_data			: IN  std_logic;
			l_down			: OUT std_logic;
			l_up				: OUT std_logic;
			r_down			: OUT std_logic;
			r_up				: OUT std_logic;
			
			
			led				: OUT std_logic_vector ( 17 downto 0)
		);
END keyboard;


architecture behavioral of keyboard is
	CONSTANT BREAKCODE : integer := 240;
	CONSTANT LUP : integer := 29;    -- Scan code for 'W' up
	CONSTANT LDOWN : integer := 27;    -- Scan code for 'S' up
	CONSTANT RUP : integer := 99;    -- Scan code for <up> up
	CONSTANT RDOWN : integer := 96;    -- Scan code for <down> up
		
	signal data : std_logic_vector(10 downto 0);
	signal scancode : std_logic_vector(7 downto 0);
	signal keyup : std_logic := '0';
	signal resetdata : std_logic := '0';
	
	signal srup : std_logic := '0';
	signal srdown : std_logic := '0';
	signal slup : std_logic := '0';
	signal sldown : std_logic := '0';
	
	signal flag : std_logic := '0';
	
begin

	l_up <= slup;
	l_down <= sldown;
	r_up <= srup;
	r_down <= srdown;

	led(17) <= srup;
	led(16) <= srdown;
	LED(15) <= slup;
	LED(14) <= sldown;
	LED(13) <= keyup;
	
	led(12) <= flag;


	process(kb_clk)
	
	begin
		if rising_edge(kb_clk) then
			if (resetdata = '1') then
				data <= "11111111111";
			else
				data(9 downto 0) <= data(10 downto 1);
			end if;
			
			data(10) <= kb_data;
		end if;
	end process;
	
	process(data)
	begin
		if (data(0) = '0' and data(10) = '1' and data(9) /=
				(data(1) xor data(8) xor data(7) xor data(6)xor data(5) xor data(4) xor data(3) xor data(2))) then
				
			scancode <= data(8 downto 1);
			resetdata <= '1';
		else
			resetdata <= '0';
		end if;
	end process;
	
	process(scancode)
	begin		
		--led(7 downto 0) <= scancode;
		
		if (keyup = '0') then
			if (scancode = LUP) then
				slup <= '1';
			elsif (scancode = LDOWN) then
				flag <= '0';
				sldown <= '1';
			elsif (scancode = RUP) then
				srup <= '1';
			elsif (scancode = RDOWN) then
				srdown <= '1';
			elsif (scancode = BREAKCODE) then
				keyup <= '1';
			end if;
			
			if (scancode /= LUP and scancode /= LDOWN and scancode /= RUP and scancode /= RDOWN) then
				led(7 downto 0) <= scancode;
			end if;
		else
			keyup <= '0';
			if (scancode = LUP) then
				slup <= '0';
			elsif (scancode = LDOWN) then
				flag <= '1';
				sldown <= '0';
			elsif (scancode = RUP) then
				srup <= '0';
			elsif (scancode = RDOWN) then
				srdown <= '0';
			elsif (scancode = BREAKCODE) then
				keyup <= '1';
			end if;
		end if;
	end process;
	
end architecture;