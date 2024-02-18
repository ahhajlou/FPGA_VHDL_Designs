library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity FullAdder_Sub_Module is
 
    Port ( 		
					a 		: in  	STD_LOGIC;
					b 		: in  	STD_LOGIC;
					Cin 	: in  	STD_LOGIC;
					Sum 	: out  	STD_LOGIC;
					Cout 	: out  	STD_LOGIC
			 );
			 
end FullAdder_Sub_Module;

architecture Behavioral of FullAdder_Sub_Module is
 
begin
 
Sum		<=		a xor b xor Cin;
Cout		<=		(a and b) or (a and Cin) or (b and Cin);
 


end Behavioral;
