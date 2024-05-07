library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main is
	Port(
		--//////////// CLOCK //////////
		CLOCK_24 	: in std_logic;
		
		--//////////// KEY //////////
		RESET_N	: in std_logic;
		
		
		--//////////// VGA //////////
		VGA_B		: out std_logic_vector(1 downto 0);
		VGA_G		: out std_logic_vector(1 downto 0);
		VGA_HS	: out std_logic;
		VGA_R		: out std_logic_vector(1 downto 0);
		VGA_VS	: out std_logic;
		
		--//////////// KEYS //////////
		Key : in std_logic_vector(3 downto 0);
		SW : in std_logic_vector(7 downto 0);
		
		--//////////// LEDS //////////
		Leds : out std_logic_vector(7 downto 0);
		
		--////////////Segments////////
		outseg         : out bit_vector(3 downto 0); --Enable of segments to choose one
		sevensegments  : out bit_vector(7 downto 0)
	);
end main;

--}} End of automatically maintained section

architecture main of main is

Component VGA_controller
	port ( CLK_24MHz		: in std_logic;
         VS					: out std_logic;
			HS					: out std_logic;
			RED				: out std_logic_vector(1 downto 0);
			GREEN				: out std_logic_vector(1 downto 0);
			BLUE				: out std_logic_vector(1 downto 0);
			RESET				: in std_logic;
			ColorIN			: in std_logic_vector(5 downto 0);
			ScanlineX		: out std_logic_vector(10 downto 0);
			ScanlineY		: out std_logic_vector(10 downto 0)
  );
end component;

Component VGA_Display
	port ( CLK_24MHz		: in std_logic;
			RESET				: in std_logic;
			BtnUp          : in std_logic_vector(3 downto 0);
			end_game       : in bit;
			score          : out integer;
			lose           : out bit;
			ColorOut			: out std_logic_vector(5 downto 0); -- RED & GREEN & BLUE
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0)
  );
end component;

  signal ScanlineX,ScanlineY	: std_logic_vector(10 downto 0);
  signal ColorTable	: std_logic_vector(5 downto 0);
  --seven_segment...
  signal seg0: bit_vector(7 downto 0):=x"c0";
  signal seg1: bit_vector(7 downto 0):=x"c0";
  signal seg2: bit_vector(7 downto 0):=x"c0";
  signal seg3: bit_vector(7 downto 0):=x"c0";
  signal seg_selectors : BIT_VECTOR(3 downto 0) := "1110" ;
  signal output: bit_vector(7 downto 0):=x"c0";
  signal input :Integer :=0;
   signal output_score: bit_vector(7 downto 0):=x"c0";
  signal input_score :Integer :=0;
  signal timer_game : Integer :=0;
  signal end_game : bit :='0';
  signal score : integer:= 0;
  signal lose: bit;
  signal leds_signal : std_logic_vector(7 downto 0) := "10101010";

  begin
	 --------- VGA Controller -----------
	 VGA_Control: vga_controller
			port map(
				CLK_24MHz	=> CLOCK_24,
				VS				=> VGA_VS,
				HS				=> VGA_HS,
				RED			=> VGA_R,
				GREEN			=> VGA_G,
				BLUE			=> VGA_B,
				RESET			=> not RESET_N,
				ColorIN		=> ColorTable,
				ScanlineX	=> ScanlineX,
				ScanlineY	=> ScanlineY
			);
		
		--------- Moving Square -----------
		VGA_DIS: VGA_Display
			port map(
				CLK_24MHz		=> CLOCK_24,
				RESET				=> not RESET_N,
				BtnUP          => Key,
				end_game			=> end_game,
				score          => score,
				lose           => lose,
				ColorOut			=> ColorTable,
				ScanlineX		=> ScanlineX,
				ScanlineY		=> ScanlineY
			);
	 
	 --change selector to choose one of segments each time
	 process(CLOCK_24) 
	 variable counter : integer range 0 to 5000 :=0;
	 begin
		 if(rising_edge(CLOCK_24)) then 
			 counter := counter +1;
			 if (counter = 4999) then 
				 counter :=0;
			    seg_selectors <= seg_selectors(0) & seg_selectors(3 downto 1);
			 end if;
		 end if;
	 end process;
	 
	 -- Timer of game : clock is 24mhz so 1s occurs after 24000000 clock edge
	 process(CLOCK_24,RESET_N) 
	 variable flag_key :bit:= '0';
	 variable flag_rst :bit:= '0';
	 variable counter : integer range 0 to 24000000 :=0;
	 begin
	    if RESET_N = '0' then
		 flag_key := '0';
		 flag_rst := '1';
		 counter := 0;
		 timer_game <= 0;
		 elsif(rising_edge(CLOCK_24)) then 
		  if( (key(0) = '0' or key(1) = '0') and flag_rst = '1')then
	      flag_key := '1';
		  end if;
	     if (flag_key = '1') then
			 counter := counter +1;
			 if (counter = 23999999) then 
				 counter :=0;
			 if( end_game = '1') then
				timer_game <= timer_game;
			 else
			    timer_game <= timer_game+1; --Add timer after 24000000 clk edge
			 end if;
			 end if;
			 end if;
		 end if;
	 end process;
	 
	 --1.score = 10(win) 2.timer_game(time is end) 3.iose = 1 (conflict happens)
	 process(timer_game)
	 begin
		if(timer_game = 61 or lose = '1')then
			end_game <= '1';
		else
		   end_game <= '0';
		end if;
	 end process;
  
	--this process handles leds. on : when game is finished else off
   process(RESET_N,CLOCK_24 )
	variable flag_rst: bit := '0';
	variable timer_leds : integer range 0 to 12000001 := 0;
	begin
	if RESET_N = '0' then
	   flag_rst := '1';
		leds <= "00000000";
		leds_signal <= "10101010";
		timer_leds := 0;
	elsif(rising_edge(CLOCK_24 )) then
	   timer_leds := timer_leds + 1;
    	if flag_rst = '1' and end_game = '1' then
		   leds <= "11111111";
		elsif flag_rst = '1' and end_game = '0' and timer_leds = 12000000  then
		   leds_signal <= leds_signal(0) & leds_signal (7 downto 1);
			leds <= leds_signal;
		end if;
	end if;
	end process;
	
   outseg <= seg_selectors;
	 
	 --seg_selectors choose one segment and segx has content of each segment
	 process(seg_selectors,seg0,seg1,seg2,seg3 )
	 begin
		case seg_selectors is
			when "1110" =>
			sevenSegments <= seg0;
			when "0111" =>
			sevenSegments <= seg3;
			when "1011" =>
			sevenSegments <= seg2;
			when "1101" =>
			sevenSegments <= seg1;
			when others =>
			sevenSegments <= x"c0";
		end case;
	end process;
	
   process( RESET_N,CLOCK_24 )
	variable flag_key :bit:= '0';--flag = 0 -> button is not pressed, flag = 1-> button is pressed
	begin
	--here content of segments is "2219"
	if RESET_N = '0' then
			-- display IDs
			seg0 <= x"B0";
			seg1 <= x"80";
		 	seg2 <= x"A4";
	    	seg3 <= x"B0";
			flag_key := '0';
	elsif(rising_edge(CLOCK_24)) then 
	if( key(0) = '0' or  key(1) = '0')then
	      flag_key := '1';
	end if;
	--this case shows score in 7 segment
 if (flag_key = '1' and end_game = '0') then
	  if( score >= 90)then
	   input_score <= score - 90; --to calculate firs digit of timer
		seg3 <= output_score;
		seg2 <= x"98";
	 elsif( score >= 80)then
	   input_score <= score - 80;
		seg3 <= output_score;
		seg2 <= x"80";
	 elsif( score >= 70)then
	   input_score <= score - 70;
		seg3 <= output_score;
		seg2 <= x"F8";
	 elsif( score >= 60)then
	   input_score <= score - 60;
		seg3 <= output_score;
		seg2 <= x"82";
	 elsif( score >= 50)then
	   input_score <= score - 50;
		seg3 <= output_score;
		seg2 <= x"92";
	 elsif( score >= 40)then
	   input_score <= score - 40;
		seg3 <= output_score;
		seg2 <= x"99";
	 elsif( score >= 30)then
	   input_score <= score - 30;
		seg3 <= output_score;
		seg2 <= x"B0";
	 elsif( score >= 20)then
	   input_score <= score - 20;
		seg3 <= output_score;
		seg2 <= x"A4";
	 elsif( score >= 10)then
	   input_score <= score - 10;
		seg3 <= output_score;
		seg2 <= x"F9";
	 else
	   input_score <= score;
		seg3 <= output_score;
		seg2 <= x"C0";
	 end if;
	 if( timer_game >= 60)then
	   input <= timer_game - 60;
		seg1 <= output;
		seg0 <= x"82";
	 elsif( timer_game >= 50)then
	   input<= timer_game - 50;
		seg1 <= output;
		seg0 <= x"92";
	 elsif( timer_game >= 40)then
	   input <= timer_game - 40;
		seg1 <= output;
		seg0 <= x"99";
	 elsif( timer_game >= 30)then
	   input <= timer_game - 30;
		seg1 <= output;
		seg0 <= x"B0";
	 elsif( timer_game >= 20)then
	   input <= timer_game - 20;
		seg1 <= output;
		seg0 <= x"A4";
	 elsif( timer_game >= 10)then
	   input <= timer_game - 10;
		seg1 <= output;
		seg0 <= x"F9";
	 else
	   input <= timer_game;
		seg1 <= output;
		seg0 <= x"C0";
	 end if;
	end if;
	if(lose='1' and end_game = '1') then
		seg0 <= x"c7"; --lose segment
		seg1 <= x"c0";
		seg2 <= x"92";
	   seg3 <= x"86";
		
   end if;
	if((timer_game=61 or score >= 99) and end_game = '1' ) then
	   seg0 <= x"92";   -- win segment
	   seg1 <= x"c1";
		seg2 <= x"c6";
	   seg3 <= x"c6";
	end if;
	end if;
	end process;
	
	--equal value of integer input in hex format to send to segment
  process (input)
  begin
  case input is
 	when 0 => output <= x"c0";
	when 1 => output <= x"F9";
	when 2 => output <= x"A4";
	when 3 => output <= x"B0";
	when 4 => output <= x"99";
	when 5 => output <= x"92";
	when 6 => output <= x"82";
	when 7 => output <= x"F8";
	when 8 => output <= x"80";
	when others => output <= x"98";
  end case;
  end process;
  
  process(input_score)
  begin
  case input_score is
 	when 0 => output_score <= x"c0";
	when 1 => output_score <= x"F9";
	when 2 => output_score <= x"A4";
	when 3 => output_score <= x"B0";
	when 4 => output_score <= x"99";
	when 5 => output_score <= x"92";
	when 6 => output_score <= x"82";
	when 7 => output_score <= x"F8";
	when 8 => output_score <= x"80";
	when others => output_score <= x"98";
  end case;
  end process;
	
	 
end main;
