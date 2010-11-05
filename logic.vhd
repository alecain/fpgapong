LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY logic IS
	GENERIC (
		LBOUND 				: INTEGER := 40;
		RBOUND 				: INTEGER := 578;
		TBOUND 				: INTEGER := 10;
		BBOUND 				: INTEGER := 455;
		PADDLE_HEIGHT 		: INTEGER := 80;
		PADDLE_WIDTH 		: INTEGER := 10;
		BALL_RADIUS 		: INTEGER := 10;
		MAX_PADDLE_SPEED	: INTEGER := 10;
		MAX_BALL_SPEED 	: INTEGER := 25
	);

	PORT (
		l_paddle		: OUT INTEGER RANGE 0 TO 480;
		r_paddle  	: OUT INTEGER RANGE 0 TO 480;
		ball_x 		: OUT INTEGER RANGE 0 TO 640;
		ball_y 		: OUT INTEGER RANGE 0 TO 480;
		game_clock	: IN  STD_LOGIC;
		l_up			: IN  STD_LOGIC;
		l_down		: IN  STD_LOGIC;
		r_up			: IN  STD_LOGIC;
		r_down		: IN	STD_LOGIC;
		l_score		: OUT INTEGER RANGE 0 TO 99;
		r_score		: OUT INTEGER RANGE 0 TO 99
	);
END logic;

ARCHITECTURE behavioral OF logic IS
	SIGNAL s_l_paddle 		: INTEGER RANGE 0 TO 480    := 240;
	SIGNAL s_r_paddle 		: INTEGER RANGE 0 TO 480    := 240;
	SIGNAL s_ball_x 			: INTEGER RANGE 0 TO 640    := 320;
	SIGNAL s_ball_y		 	: INTEGER RANGE 0 TO 480    := 240;
	SIGNAL s_x_speed 			: INTEGER RANGE -128 TO 128 := 10;
	SIGNAL s_y_speed		 	: INTEGER RANGE -128 TO 128 := 6;
	SIGNAL s_l_score			: INTEGER RANGE 0 TO 99     := 0;
	SIGNAL s_r_score			: INTEGER RANGE 0 TO 99     := 0;

	SIGNAL l_paddle_speed	: INTEGER := 0;
	SIGNAL r_paddle_speed	: INTEGER := 0;

BEGIN

	l_paddle <= s_l_paddle;
	r_paddle <= s_r_paddle;
	ball_x   <= s_ball_x;
	ball_y   <= s_ball_y;
	l_score  <= s_l_score;
	r_score  <= s_r_score;

	PROCESS(game_clock, l_up, l_down ,r_up, r_down)
	BEGIN
		IF RISING_EDGE(game_clock) THEN

			IF s_y_speed > MAX_BALL_SPEED THEN
				s_y_speed <= MAX_BALL_SPEED;
			ELSIF s_y_speed < -MAX_BALL_SPEED THEN
				s_y_speed <= -MAX_BALL_SPEED;
			END IF;

			IF l_up = '1' AND l_paddle_speed > -MAX_PADDLE_SPEED THEN
				l_paddle_speed <= l_paddle_speed - 1;
			ELSIF l_down = '1' AND l_paddle_speed < MAX_PADDLE_SPEED THEN
				l_paddle_speed <= l_paddle_speed + 1;
			ELSIF l_up = '0' AND l_down = '0' THEN
				IF l_paddle_speed < 0 THEN
					l_paddle_speed <= l_paddle_speed + 1;
				ELSIF l_paddle_speed > 0 THEN
					l_paddle_speed <= l_paddle_speed - 1;
				END IF;
			END IF;

			IF s_l_paddle + l_paddle_speed > TBOUND AND s_l_paddle + l_paddle_speed < BBOUND THEN
				s_l_paddle <= s_l_paddle + l_paddle_speed;
			END IF;

			IF r_up = '1' AND r_paddle_speed > -MAX_PADDLE_SPEED THEN
				r_paddle_speed <= r_paddle_speed - 1;
			ELSIF r_down = '1' AND r_paddle_speed < MAX_PADDLE_SPEED THEN
				r_paddle_speed <= r_paddle_speed + 1;
			ELSIF r_up = '0' AND r_down = '0' THEN
				IF r_paddle_speed < 0 THEN
					r_paddle_speed <= r_paddle_speed + 1;
				ELSIF r_paddle_speed > 0 THEN
					r_paddle_speed <= r_paddle_speed - 1;
				END IF;
			END IF;

			IF s_r_paddle + r_paddle_speed > TBOUND AND s_r_paddle + r_paddle_speed < BBOUND THEN
				s_r_paddle <= s_r_paddle + r_paddle_speed;
			END IF;

			-- Check the left paddle
			IF s_ball_x + s_x_speed < LBOUND THEN
				IF s_l_paddle - s_ball_y < PADDLE_HEIGHT/2
						AND s_ball_y - s_l_paddle < PADDLE_HEIGHT/2 THEN
					s_x_speed <= -s_x_speed;
					s_y_speed <= s_y_speed + l_paddle_speed/2;
					s_ball_x <= LBOUND + LBOUND - (s_ball_x + s_x_speed);
					s_ball_y <= s_ball_y + s_y_speed;
				ELSE
					IF s_r_score = 99 THEN
						s_r_score <= 0;
					ELSE
						s_r_score <= s_r_score + 1;
					END IF;

					s_y_speed <= -s_y_speed/3;
					s_ball_x <= 320;
					s_ball_y <= 240;
				END IF;
			-- Check the right paddle
			ELSIF (s_ball_x + s_x_speed) > RBOUND THEN
				IF (s_r_paddle - s_ball_y) < (PADDLE_HEIGHT/2)
						AND (s_ball_y-s_r_paddle) < (PADDLE_HEIGHT/2) THEN
					s_x_speed <= -s_x_speed;
					s_y_speed <= s_y_speed + r_paddle_speed/2;
					s_ball_x <= RBOUND - (s_ball_x + s_x_speed) - RBOUND;
					s_ball_y <= s_ball_y + s_y_speed;

				ELSE
					s_ball_x <= 320;
					s_ball_y <= 240;
					s_y_speed <= -s_y_speed/3;
					
					IF s_l_score = 99 THEN
						s_l_score <= 0;
					ELSE
						s_l_score <= s_l_score + 1;
					END IF;
				END IF;
			ELSE
				s_ball_x <= s_ball_x + s_x_speed;
				s_ball_y <= s_ball_y + s_y_speed;
			END IF;

			-- Check the top and bottom
			IF (s_ball_y + s_y_speed) < TBOUND OR (s_ball_y + s_y_speed) > BBOUND THEN
				s_y_speed <= -s_y_speed;			
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;