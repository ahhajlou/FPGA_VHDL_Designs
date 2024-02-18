library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity Shift_right_left is

	GENERIC(N : NATURAL);
	PORT(
			Shift_direction : IN STD_LOGIC;
			Shift_in  : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			Shift_out : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
	);

end Shift_right_left;

architecture Behavioral of Shift_right_left is
begin

	WITH Shift_direction SELECT
	
	Shift_out <= "0" & Shift_in(N-1 DOWNTO 1)   WHEN '1', -- Shift Right
					 Shift_in(N-2 DOWNTO 0) & "0"   WHEN '0',   -- Shift Left
					 (OTHERS => '0') WHEN OTHERS;


--	Shift_out <= Shift_in(0) & Shift_in(N-1 DOWNTO 1) WHEN Shift_direction = '1' ELSE-- Shift Right
--					 Shift_in(N-2 DOWNTO 0) & Shift_in(N-1) WHEN Shift_direction = '0' ELSE -- Shift Left
--					 (OTHERS => '0');

						
	
end Behavioral;