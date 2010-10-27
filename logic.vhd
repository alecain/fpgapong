
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
		MAX_PADDLE_SPEED: integer := 10;
		MAX_BALL_SPEED : integer := 25
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
			r_down			: IN	std_logic;
			l_score			: OUT integer range 0 to 99;
			r_score			: OUT integer range 0 to 99
			
		);
END logic;


architecture behavioral of logic is
		signal s_l_paddle : integer range 0 to 480 := 240;
		signal s_r_paddle : integer range 0 to 480 := 240;
		signal s_ball_x 	: integer range 0 to 640 := 320;
		signal s_ball_y 	: integer range 0 to 480 := 240;
		signal s_x_speed 	: integer range -128 to 128 := 10;
		signal s_y_speed 	: integer range -128 to 128 := 6;
		signal s_l_score	: integer range 0 to 99 := 0;
		signal s_r_score	: integer range 0 to 99 := 0;
		signal l_paddle_speed:		integer := 0;
		signal r_paddle_speed:		integer := 0;

		
begin

	l_paddle <= s_l_paddle;
	r_paddle <= s_r_paddle;
	ball_x <= s_ball_x;
	ball_y <= s_ball_y;
	l_score <= s_l_score;
	r_score <= s_r_score;
	
	process(game_clock,l_up,l_down,r_up,r_down)
	begin
		if rising_edge(game_clock) then

			if (s_y_speed> MAX_BALL_SPEED) then
				s_y_speed<=MAX_BALL_SPEED;
			elsif (s_y_speed < -MAX_BALL_SPEED) then
				s_y_speed<=-MAX_BALL_SPEED;
			end if;
				
			
			
			if (l_up = '1' and l_paddle_speed > -MAX_PADDLE_SPEED) then
				l_paddle_speed <= l_paddle_speed-1;
			elsif(l_down = '1'and l_paddle_speed<MAX_PADDLE_SPEED) then
				l_paddle_speed <= l_paddle_speed+1;
			elsif(l_up = '0' and l_down = '0') then
				if (l_paddle_speed <0) then
					l_paddle_speed<=l_paddle_speed+1;
				elsif (l_paddle_speed>0) then
					l_paddle_speed<=l_paddle_speed-1;
				end if;
			end if;
			
			if (s_l_paddle+l_paddle_speed > TBOUND and  s_l_paddle + l_paddle_speed < BBOUND ) then
				s_l_paddle <= s_l_paddle + l_paddle_speed;
			end if;
			
			
			if (r_up = '1'and r_paddle_speed>-MAX_PADDLE_SPEED) then
				r_paddle_speed<=r_paddle_speed-1;
			elsif(r_down = '1'and r_paddle_speed<MAX_PADDLE_SPEED) then
				r_paddle_speed<=r_paddle_speed+1;
			elsif(r_up = '0' and r_down = '0') then
				if (r_paddle_speed <0) then
					r_paddle_speed<=r_paddle_speed+1;
				elsif (r_paddle_speed>0) then
					r_paddle_speed<=r_paddle_speed-1;
				end if;
			end if;
			
			if (s_r_paddle+r_paddle_speed  > TBOUND and s_r_paddle +r_paddle_speed < BBOUND) then
				s_r_paddle <= s_r_paddle + r_paddle_speed;
			end if;
			

			-- Check the left paddle
			if ((s_ball_x + s_x_speed) < LBOUND) then
				if ( (s_l_paddle - s_ball_y) < (PADDLE_HEIGHT/2)
					and (s_ball_y-s_l_paddle  ) < (PADDLE_HEIGHT/2)) then
					s_x_speed <= -s_x_speed;
					s_y_speed <= s_y_speed + l_paddle_speed/2;
					s_ball_x <= LBOUND + LBOUND - (s_ball_x + s_x_speed);
					s_ball_y <= s_ball_y + s_y_speed;
				else
					if (s_r_score = 99) then
						s_r_score <=0;
					else
						s_r_score <= s_r_score + 1;
					end if;
					
					s_y_speed <=-s_y_speed/3;
					s_ball_x <= 320;
					s_ball_y <= 240;
					
				end if;
			-- Check the right paddle
			elsif ((s_ball_x + s_x_speed) > RBOUND) then
				if ((s_r_paddle - s_ball_y) < (PADDLE_HEIGHT/2)
				and (s_ball_y-s_r_paddle  ) < (PADDLE_HEIGHT/2)) then
					s_x_speed <= -s_x_speed;
					s_y_speed <= s_y_speed + r_paddle_speed/2;
					s_ball_x <= RBOUND - ((s_ball_x + s_x_speed) - RBOUND);
					s_ball_y <= s_ball_y + s_y_speed;

				else
					s_ball_x <= 320;
					s_ball_y <= 240;
					s_y_speed <=-s_y_speed/3;
					if (s_l_score = 99) then
						s_l_score <=0;
					else
						s_l_score <= s_l_score + 1;
					end if;
					
				end if;
			else
				s_ball_x <= s_ball_x + s_x_speed;
				s_ball_y <= s_ball_y + s_y_speed;
			end if;
			
			-- Check the top and bottom
			if ((s_ball_y + s_y_speed) < TBOUND or (s_ball_y + s_y_speed) > BBOUND) then
				s_y_speed <= -s_y_speed;			
			end if;

			
			
	
		end if;
	end process;
end architecture;