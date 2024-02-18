library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity FullAdder_Exponent is

	generic (N: integer);
 
    Port ( 
					a 		: in  	STD_LOGIC_VECTOR (N-1 downto 0);
					b 		: in  	STD_LOGIC_VECTOR (N-1 downto 0);
					M     : in 	   STD_LOGIC;
					Sum 	: out  	STD_LOGIC_VECTOR (N-1 downto 0)
			 );
					
end FullAdder_Exponent;
 
architecture Behavioral of FullAdder_Exponent is
 
signal C_Int :	std_logic_vector(N downto 0) := (others=>'0');
signal B_XOR_M : std_logic_vector(N-1 downto 0);

	component	FullAdder_Sub_Module
		port (
					a 		: 	in		std_logic;
					b	 	:	in 	std_logic;
					Cin   :	in 	std_logic;
					Sum   : 	out	std_logic;
					Cout	:	out	std_logic
				);
	end component;	
 
begin

C_Int(0) <= M;

				
 FullAdder: for i in 0 to N-1 generate -- First to Nth adder
	B_XOR_M(i) <= b(i) XOR M;
	
	Adder:	FullAdder_Sub_Module
		port map 
					(
						a			=>		a(i),
						b			=>		B_XOR_M(i),
						Cin    	=>		C_Int(i),
						Sum   	=>		Sum(i),
						Cout		=>		C_Int(i+1)		
					);
 end generate FullAdder;

 
 --Cout <= C_Int(N);
 
-- Overflow <= C_Int(N) XOR C_Int(N-1);
 
end Behavioral;