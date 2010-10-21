
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



ENTITY logic IS
	generic (
		LBOUND : 			integer := 40;
		RBOUND : 			integer := 578;
		TBOUND : 			integer := 10;
		BBOUND : 			integer := 455;
		PADDLE_HEIGHT : 	integer := 80;
		PADDLE_WIDTH : 	integer := 10;
		BALL_RADIUS : 		integer := 10;
		PADDLE_SPEED :		integer := 3
	);

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
END logic;


architecture behavioral of logic is
		signal s_l_paddle : integer range 0 to 480 := 0;
		signal s_r_paddle : integer range 0 to 480 := 0;
		signal s_ball_x : integer range 0 to 640 := 320;
		signal s_ball_y : integer range 0 to 480 := 240;
		signal s_x_speed : integer range -128 to 128 := 5;
		signal s_y_speed : integer range -128 to 128 := 2;
		
begin

	l_paddle <= s_l_paddle;
	r_paddle <= s_r_paddle;
	ball_x <= s_ball_x;
	ball_y <= s_ball_y;
	
	process(game_clock)
	begin
		if rising_edge(game_clock) then
			if (l_up = '0' and s_l_paddle > TBOUND+PADDLE_SPEED) then
				s_l_paddle <= s_l_paddle - PADDLE_SPEED;
			elsif (l_down = '0' and  s_l_paddle < BBOUND - PADDLE_SPEED) then
				s_l_paddle <= s_l_paddle + PADDLE_SPEED;
			end if;
			
			if (r_up = '0' and s_r_paddle > TBOUND+PADDLE_SPEED) then
				s_r_paddle <= s_r_paddle - PADDLE_SPEED;
			elsif (r_down = '0' and s_r_paddle > TBOUND+PADDLE_SPEED) then
				s_r_paddle <= s_r_paddle + PADDLE_SPEED;
			end if;

			-- Check the left paddle
			if ((s_ball_x + s_x_speed) < LBOUND) then
				if ( (s_l_paddle - s_ball_y) < (PADDLE_HEIGHT/2)
					and (s_ball_y-s_l_paddle  ) < (PADDLE_HEIGHT/2)) then
					s_x_speed <= -s_x_speed;
					s_ball_x <= LBOUND + LBOUND - (s_ball_x + s_x_speed);
				else
					s_ball_x <= 320;
					s_ball_y <= 240;
				end if;
			else
				s_ball_x <= s_ball_x + s_x_speed;
			end if;
			
			-- Check the right paddle
			if ((s_ball_x + s_x_speed) > RBOUND) then
				if ((s_r_paddle - s_ball_y) < (PADDLE_HEIGHT/2)
				and (s_ball_y-s_r_paddle  ) < (PADDLE_HEIGHT/2)) then
					s_x_speed <= -s_x_speed;
					s_ball_x <= RBOUND - ((s_ball_x + s_x_speed) - RBOUND);
				else
					s_ball_x <= 320;
					s_ball_y <= 240;
				end if;
			else
				s_ball_x <= s_ball_x + s_x_speed;
			end if;
			
			-- Check the top and bottom
			if ((s_ball_y + s_y_speed) < TBOUND or (s_ball_y + s_y_speed) > BBOUND) then
				s_y_speed <= -s_y_speed;			
			end if;

			s_ball_y <= s_ball_y + s_y_speed;
			
			
	
		end if;
	end process;
end architecture;