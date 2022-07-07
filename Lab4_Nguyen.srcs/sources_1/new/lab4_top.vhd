----------------------------------------------------------------------------------
--  
-- This lab is to design a VGA controller and implement a checkerboard display with a red square that moves along the board in response to pressing the push-buttons.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity lab4_top is
Port ( 
           -- Clock
           CLK100MHZ : in STD_LOGIC;
           -- Switch 0 as active high reset
           SW: in STD_LOGIC_VECTOR(15 downto 0); 
           
           --Push Buttons
           BTNU : in STD_LOGIC;
           BTND : in STD_LOGIC;
           BTNL : in STD_LOGIC;
           BTNR : in STD_LOGIC;
         
           -- VGA
           VGA_R: out STD_LOGIC_VECTOR(3 downto 0);
           VGA_G: out STD_LOGIC_VECTOR(3 downto 0);
           VGA_B: out STD_LOGIC_VECTOR(3 downto 0);
           VGA_HS: out STD_LOGIC;
           VGA_VS: out STD_LOGIC;
          
           --Seg7 Display Signals
           SEG7_CATH : out STD_LOGIC_VECTOR (7 downto 0);
           AN : out STD_LOGIC_VECTOR (7 downto 0)
           );
end lab4_top;

architecture Behavioral of lab4_top is
    signal reset : std_logic;
    -- 7 segments display
    signal char0: std_logic_vector(31 downto 28);
    signal char1: std_logic_vector(27 downto 24);
    signal char2: std_logic_vector(23 downto 20);
    signal char3: std_logic_vector(19 downto 16);
    signal char4: std_logic_vector(15 downto 12);
    signal char5: std_logic_vector(11 downto 8);
    signal char6: std_logic_vector(7 downto 4);
    signal char7: std_logic_vector(3 downto 0);
    
    --VGA signals       
    signal horizontal_counter: unsigned (9 downto 0);
    signal vertical_counter: unsigned (9 downto 0);       
    signal vgaRedT: std_logic;
    signal vgaGreenT: std_logic;
    signal vgaBlueT: std_logic;
    signal hcnt: unsigned(7 downto 0) ; -- 8bits counter horizontal position of the red square(match the horizontal_counter (9 downto 5)) 
    signal vcnt: unsigned(7 downto 0); -- 8 bits counter vertical position of the red square match the vertical_counter (9 downto 5)) 
    constant HMax: unsigned(7 downto 0) := to_unsigned(20, 7+1); -- max column is 20
    constant VMax: unsigned(7 downto 0) := to_unsigned(15, 7+1); -- max row is 15
    
    -- BTNU
    signal btnUp_bd: std_logic; --button up debounce output
    signal btnUp_db_prev: std_logic; -- button up debounce is one clock cycle delayed
    signal btnUp_press_event: std_logic; 
    
    -- BTND
    signal btnDown_bd: std_logic; --button down debounce output
    signal btnDown_db_prev: std_logic; -- button up debounce is one clock cycle delayed
    signal btnDown_press_event: std_logic; 
    
    -- BTNL
    signal btnLeft_bd: std_logic; --button left debounce output
    signal btnLeft_db_prev: std_logic; -- button up debounce is one clock cycle delayed
    signal btnLeft_press_event: std_logic; 
    
    -- BTNR
    signal btnRight_bd: std_logic; --button right debounce output
    signal btnRight_db_prev: std_logic; -- button up debounce is one clock cycle delayed
    signal btnRight_press_event: std_logic; 
    
begin
   -- switch 0 is reset
   reset <= sw(0);            
     
              
     --------------------------------- VGA --------------------------    
     -- vga port map -- 
     vga: entity work.vga port map 
        (
           clk100MHz => CLK100MHZ,             
           reset => reset,                         
           Hsync => VGA_HS,
           VSync => VGA_VS,
           vgaRed => VGA_R,
           vgaGreen => VGA_G,
           vgaBlue => VGA_B,
           v_counter => vertical_counter,
           h_counter => horizontal_counter
        );
        
        -- Make checkerboard
        -- Alternating the green and blue square
        -- Check for the bit(5) of vertical_counter and horizontal_counter. 
        -- if the
        checkerboard: process (horizontal_counter,vertical_counter)
        begin
            if(horizontal_counter(9 downto 5) = hcnt and vertical_counter(9 downto 5) = vcnt )then
                vgaGreenT <= '0';  
                vgaBlueT <= '0';
                vgaRedT <= '1';
            elsif((horizontal_counter(5) = '1' and vertical_counter(5) = '1')
                or (horizontal_counter(5) = '0' and vertical_counter(5) = '0') ) then
                vgaGreenT <= '1';  
                vgaBlueT <= '0';
                vgaRedT <= '0';
            else
                vgaGreenT <= '0';  
                vgaBlueT <= '1';
                vgaRedT <= '0';
            end if;          
        end process checkerboard;
    
    --Write a CSA to assign '0' to signals vgaGreenT and vgaBlueT. 
    --vgaGreenT <= '0';
    --vgaBlueT <= '0';
    
    VGA_R <= "1111" when vgaRedT = '1' else "0000";
    VGA_G <= "1111" when vgaGreenT = '1' else "0000";
    VGA_B <= "1111" when vgaBlueT = '1' else "0000";
       
     
     -------------------- BUTTONS --------------------------
     
     --------BUTTON UP -------------
     -- button up debounce port map
     btnUpDebounce: entity btn_debounce port map
     (
        clk => CLK100MHZ,
        reset => reset,
        pb0 => BTNU,
        pb0db => btnUp_bd
     );
     
     btnU_enable: process(CLK100MHZ, reset)
     begin
        if (reset = '1') then
            btnUp_db_prev <= '0';
        elsif (rising_edge(CLK100MHZ)) then
            btnUp_db_prev <= btnUp_bd;
        end if;    
     end process btnU_enable;
     
     btnUp_press_event <= '1' when btnUp_bd = '1' and btnUp_db_prev = '0' else '0';
        
    ----- BUTTON DOWN ----------
    -- button down debounce port map
     btnDownDebounce: entity btn_debounce port map
     (
        clk => CLK100MHZ,
        reset => reset,
        pb0 => BTND,
        pb0db => btnDown_bd
     );
     
     btnD_enable: process(CLK100MHZ, reset)
     begin
        if (reset = '1') then
            btnDown_db_prev <= '0';
        elsif (rising_edge(CLK100MHZ)) then
            btnDown_db_prev <= btnDown_bd;
        end if;    
     end process btnD_enable;
     
     btnDown_press_event <= '1' when btnDown_bd = '1' and btnDown_db_prev = '0' else '0'; 
     
     --------BUTTON LEFT -------------
     -- button left debounce port map
      btnLeftDebounce: entity btn_debounce port map
     (
        clk => CLK100MHZ,
        reset => reset,
        pb0 => BTNL,
        pb0db => btnLeft_bd
     );
     
     btnL_enable: process(CLK100MHZ, reset)
     begin
        if (reset = '1') then
            btnLeft_db_prev <= '0';
        elsif (rising_edge(CLK100MHZ)) then
            btnLeft_db_prev <= btnLeft_bd;
        end if;    
     end process btnL_enable;
     
     btnLeft_press_event <= '1' when btnLeft_bd = '1' and btnLeft_db_prev = '0' else '0';
        
    ----- BUTTON RIGHT ----------
    -- button right debounce port map
      btnRightDebounce: entity btn_debounce port map
     (
        clk => CLK100MHZ,
        reset => reset,
        pb0 => BTNR,
        pb0db => btnRight_bd
     );
     
     btnR_enable: process(CLK100MHZ, reset)
     begin
        if (reset = '1') then
            btnRight_db_prev <= '0';
        elsif (rising_edge(CLK100MHZ)) then
            btnRight_db_prev <= btnRight_bd;
        end if;    
     end process btnR_enable;
     
     btnRight_press_event <= '1' when btnRight_bd = '1' and btnRight_db_prev = '0' else '0';
       
    -- Design a process for a 8-bits counter with an enable that counts everytime the enable goes high
    btn_counter: process(CLK100MHZ, reset)
    begin
        if(reset = '1') then
            hcnt <= (others => '0');
            vcnt <= (others => '0');
         elsif(rising_edge(CLK100MHZ)) then
             if(vcnt = VMax) then
                 vcnt <= (others => '0');
             else
                if(btnUp_press_event = '1') then 
                    if(vcnt = "00000000") then
                        vcnt <= VMax - 1;
                    else
                        vcnt <= vcnt - 1;
                    end if;
                    
                elsif (btnDown_press_event = '1') then
                    vcnt <= vcnt + 1;
                else
                    vcnt <= vcnt;
                end if;
             end if;
             if(hcnt = HMax) then
                 hcnt <= (others => '0');
             else
                if (btnLeft_press_event = '1') then
                    if(hcnt = "00000000") then
                        hcnt <= HMax - 1;
                    else
                         hcnt <= hcnt - 1;
                    end if;
                   
                 elsif (btnRight_press_event = '1') then
                   hcnt <= hcnt + 1;
                else
                    hcnt <= hcnt;
                end if;
             end if;                            
        end if;
    end process btn_counter;

    ---------------- 7 SEGMENTS DISPLAY ----------------
    
    -- 7 segments controller port map     
   seg7Controller: entity seg7_controller port map 
    (
        clk => CLK100MHZ, 
        reset =>  reset,
        character0 => char0, 
        character1 => char1,  
        character2  => char2, 
        character3  => char3, 
        character4  => char4,
        character5  => char5, 
        character6  => char6,
        character7 => char7, 
        encode_character => SEG7_CATH, -- cathodes
        AN => AN                       -- anodes
    );
    
    -- display the 8bit counters using the seven-segment display   
    -- the first 2 segments display (char0 and char1) display the vertical position of the red square
    -- the next 2 segments display (char 2 and char3) display the horizontal position of the red square
    -- the last 4 segments display hardcode to 0
    char0 <= std_logic_vector(vcnt(3 downto 0));
    char1 <= std_logic_vector(vcnt(7 downto 4));
    char2 <= std_logic_vector(hcnt(3 downto 0));
    char3 <= std_logic_vector(hcnt(7 downto 4));
    char4 <= (others => '0');
    char5 <= (others => '0');
    char6 <= (others => '0');
    char7 <= (others => '0');
        
          
end Behavioral;