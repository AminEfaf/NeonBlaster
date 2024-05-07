library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA_Display is
  port ( CLK_24MHz		: in std_logic;
			RESET				: in std_logic;
			BtnUp          : in std_logic_vector(3 downto 0);  --use Key(0) to BtnUP
			end_game       : in bit;
			score          : out integer := 0;
			lose           : out bit;
			ColorOut			: out std_logic_vector(5 downto 0); -- RED & GREEN & BLUE
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0)
  );
end VGA_Display;

architecture Behavioral of VGA_Display is
   	signal flag_reset: bit := '0';
	signal flag_lose: bit := '0';
	signal H1player : integer;	
	signal H2player : integer;	
	signal V1player : integer:= 430; 
	signal V2player : integer:= 480;
	signal tirH1 : integer;
	signal tirH2 : integer; 
	signal tirV1 : integer;
	signal tirV2 : integer;
	signal random_number: std_logic_vector(31 downto 0) :=(others => '0');
	signal H1Thresh : integer; --width of the cube
	signal H2Thresh : integer;
	signal V1Thresh : integer;-- height of the cube
	signal V2Thresh : integer;
	signal h_Thresh : integer;	
	signal count_score: integer;
	signal HDir : std_logic := '0';
	signal VDir : std_logic := '0';
	signal H_flag : integer := 1; 
	signal V_flag : integer := 1; 
	signal speed_cube : integer := 1; 
	begin
	process(CLK_24MHz, RESET) 	
	function lfsr32(x : std_logic_vector(31 downto 0)) return std_logic_vector is
		begin
			return x(30 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31));
	end function;
	variable counter: integer := 0;
	variable flag_right: std_logic := '0'; 
	variable flag_left: std_logic := '0';  
	variable start_flag: std_logic := '0'; 
	variable health: integer := 1;
	variable tempH: integer := 0;
	begin
	if RESET = '1' then	
		count_score	<= 0;
		H1player <= 400; 
		H2player <= 450;
		counter := 0;  
		flag_reset <= '1';
		start_flag:= '0';
		flag_lose <= '0';
		-- enemy
		H1Thresh <= 350 ;
		H2Thresh <= 400;
		V1Thresh <= 10 ;
		V2Thresh <= 60;	
		h_Thresh <= 1;
		-- tir
		tirH1 <= H1player + 20;
		tirH2 <= tirH1 + 10; 
		tirV1 <= -10;
		tirV2 <= -20; 
	elsif(CLK_24MHz'event and CLK_24MHz = '1') then
		if flag_reset = '1' and end_game = '0' then
			if h_Thresh = 0 then 
				h_Thresh <= health;
				H1Thresh <= tempH;
				H2Thresh <= tempH + 50;
				V1Thresh <= 10;
				V2Thresh <= 60;	
			end if;
			random_number <= lfsr32(random_number);	 
		    	random_number <= lfsr32(random_number);
				if random_number(0) = '0' then 
						H_flag <= 1;
						V_flag <= 0; 
					elsif random_number(0) = '1' then 
						H_flag <= 0;
						V_flag <= 0; 
					end if;
			case random_number(1 downto 0) is 
				when "00" => tempH := 100;
				when "01" => tempH := 250;
				when "11" => tempH := 350;
				when "10" => tempH := 500;
				when others => tempH := 345;
			end case;
			case random_number(4 downto 2) is 
				when "000" => health := 2;
				when "001" => health := 3;
				when "010" => health := 4;
				when "011" => health := 5;
				when "111" => health := 6;
				when others => health := 1;
			end case;
			if count_score <= 8  then  -- choose speed of cube(enemy)
						speed_cube <= 1;
				elsif count_score > 8 and count_score <= 16 then 
						speed_cube <= 2; 
				else
						speed_cube <= 3;
					end if;
			counter := counter + 1;
			if(counter = 200000) then
				counter := 0;
				if BtnUp(0) = '0' then 
					flag_right := '1'; 
					start_flag := '1';
				else 
					flag_right := '0';	
				end if;	 
				if BtnUp(1) = '0' then 
					flag_left := '1'; 
					start_flag := '1';
				else 
					flag_left := '0';	
				end if;
				if flag_right = '1' then 
					if H2player > 638 then 
						H1player <= H1player;
						H2player <= H2player;
					else
						H1player <= H1player + 1;
						H2player <= H2player + 1;  
					end if;
				end if;
				if flag_left = '1' then 
					if H1player < 2 then 
						H1player <= H1player;
						H2player <= H2player;
					else
						H1player <= H1player - 1;
						H2player <= H2player - 1;
					end if;
				end if;	
				if V2Thresh >= 430 then
					if (H2Thresh > H1player and H2Thresh <= H2player) or (H1Thresh >= H1player and H1Thresh < H2player) then
						flag_lose <= '1';
					end if;
				end if;
				if start_flag = '1' then 
					-- move enemy	   
					
						if (HDir = '0')then
							H2Thresh <= H2Thresh + 2;
							H1Thresh <= H1Thresh + 2;
						end if;
						
						if (VDir = '0') then
							V2Thresh <= V2Thresh + 2;
							V1Thresh <= V1Thresh + 2;
						end if;
						
						if (HDir = '1') then
							H2Thresh <= H2Thresh - 2;
							H1Thresh <= H1Thresh - 2;
						end if;
						
						if (VDir = '1') then
							V2Thresh <= V2Thresh - 2;
							V1Thresh <= V1Thresh - 2;
						end if;
						
						--direction change thresholds set below
						
						if H1Thresh > 600 then
							HDir <= '1';
						end if;
						
						if H2Thresh < 30 then
							HDir <= '0';
						end if;
						
						if V1Thresh > 440 then
							VDir <= '1';
						end if;
						
						if V2Thresh < 30 then
							VDir <= '0';
						end if;
						-- move tir
						if (H1Thresh <= tirH1 and H2Thresh >= tirH2) and (V1Thresh <= tirV1 and V2Thresh >= tirV2) then
							h_Thresh <= h_Thresh - 1;
							count_score <= count_score + 1;
							--tirV1 <= -20; 
							--tirV2 <= -30;
							tirH1 <= 460;
							tirH2 <= 460; 
							tirV1 <= 460;
							tirV2 <= 460;
						end if;
						if tirV1 < 0 then 
							tirH1 <= H1player + 20;
							tirH2 <= H2player - 20; 
							tirV1 <= 460;
							tirV2 <= 470;
						else
							tirV1 <= tirV1 - 4;	
							tirV2 <= tirV2 - 4;
						end if;
						
				end if; 
			end if;	
		end if;	
	end if;	
	end process;
	
	lose <= flag_lose;
   	score <= count_score;
	ColorOut <= "110000" when (ScanlineX <= H2Thresh and ScanlineX >= H1Thresh and ScanlineY <= V2Thresh and ScanlineY >= V1Thresh + 25) and (h_Thresh = 1) 
		else "110000" when (ScanlineX <= H2Thresh and ScanlineX >= H1Thresh and ScanlineY <= V2Thresh and ScanlineY >= V1Thresh + 24) and (h_Thresh = 2)
		else "110010" when (ScanlineX <= H2Thresh and ScanlineX >= H1Thresh and ScanlineY <= V2Thresh and ScanlineY >= V1Thresh + 18) and (h_Thresh = 3)
		else "110000" when (ScanlineX <= H2Thresh and ScanlineX >= H1Thresh and ScanlineY <= V2Thresh and ScanlineY >= V1Thresh + 12) and (h_Thresh = 4) 
		else "110000" when (ScanlineX <= H2Thresh and ScanlineX >= H1Thresh and ScanlineY <= V2Thresh and ScanlineY >= V1Thresh + 6) and (h_Thresh = 5) 
		else "110000" when (ScanlineX <= H2Thresh and ScanlineX >= H1Thresh and ScanlineY <= V2Thresh and ScanlineY >= V1Thresh) and (h_Thresh = 6) 
		else "000000" when (ScanlineX <= tirH2 and ScanlineX > tirH1 ) and (ScanlineY <= tirV2 and ScanlineY > tirV1)
		else "000000" when (ScanlineX <= H2player and ScanlineX > H1player) and (ScanlineY <= V2player and ScanlineY > V1player)
		else "111111";


end Behavioral;
