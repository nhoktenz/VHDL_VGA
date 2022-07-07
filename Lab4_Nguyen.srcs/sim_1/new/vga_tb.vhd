----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 

-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_tb is
--  Port ( );
end vga_tb;

architecture Behavioral of vga_tb is
    signal clock : std_logic;
    signal reset : std_logic;
    signal vgaR: std_logic_vector (3 downto 0);
    signal vgaG: std_logic_vector (3 downto 0);
    signal vgaB: std_logic_vector (3 downto 0);
    signal hsync: std_logic;
    signal vsync: std_logic;
begin
    vga_controller_cut: entity work.vga port map (             
           clk100MHz => clock,             
           reset => reset,                         
           Hsync => hsync,
           VSync => vsync,
           vgaRed => vgaR,
           vgaGreen => vgaG,
           vgaBlue => vgaB
        );
process
    begin
        clock <= '1';
        wait for 5ns;
        clock <= '0';
        wait for 5ns;
    end process;
    reset <= '1', '0' after 100 ns;

end Behavioral;
