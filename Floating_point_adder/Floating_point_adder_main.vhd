library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;


entity Floating_point_adder_main is

	Generic(N              : natural := 8;
			  MANTISSA_WIDTH : natural := 4
	);

	Port(
			a : in std_logic_vector(N-1 downto 0);
			b : in std_logic_vector(N-1 downto 0);
			RST, CLK, LOAD_DATA : in std_logic;
			IS_SUM : in std_logic; -- '1': Sum, '0': Subtract
			Result : out std_logic_vector(N-1 downto 0);
			IS_Ready : OUT STD_LOGIC
	);
end Floating_point_adder_main;


architecture Behavioral of Floating_point_adder_main is
-- CONSTANTS DECLARATION
	CONSTANT MANTISSA_HIGH_INDEX : INTEGER := MANTISSA_WIDTH-1;
	CONSTANT EXPONENT_WIDTH : INTEGER := a(N-2 DOWNTO MANTISSA_HIGH_INDEX+1)'length;
	CONSTANT EXPONENT_HIGH_INDEX : INTEGER := a(N-2 DOWNTO MANTISSA_HIGH_INDEX+1)'high;
	
-- STATE DECLARATIONS
	TYPE st IS (Initialize, Swap, Align, Mantisaa_adder, Pre_Normalize, Normalize, Final);
	SIGNAL state : st;
	
-- SIGNAL DECLARATIONS
	SIGNAL auxA, auxB             : STD_LOGIC_VECTOR(N-1 downto 0);


	SIGNAL A_sgn, B_sgn           : STD_LOGIC;
	SIGNAL A_exp, B_exp           : STD_LOGIC_VECTOR(EXPONENT_WIDTH-1 DOWNTO 0);
	SIGNAL A_mantissa, B_mantissa : STD_LOGIC_VECTOR(MANTISSA_WIDTH   DOWNTO 0); -- one extra bit to store '1' at msb

	
	SIGNAL a_fulladder_exponent   : STD_LOGIC_VECTOR (EXPONENT_WIDTH-1 downto 0);
	SIGNAL b_fulladder_exponent   : STD_LOGIC_VECTOR (EXPONENT_WIDTH-1 downto 0);
	SIGNAL Complement_exponent    : STD_LOGIC;
	SIGNAL sum_fulladder_exponent : STD_LOGIC_VECTOR (EXPONENT_WIDTH-1 downto 0);	
	
		
	SIGNAL a_fulladder_mantissa   : STD_LOGIC_VECTOR (MANTISSA_WIDTH downto 0);
	SIGNAL b_fulladder_mantissa   : STD_LOGIC_VECTOR (MANTISSA_WIDTH downto 0);
	SIGNAL Complement_mantissa    : STD_LOGIC;
	SIGNAL sum_fulladder_mantissa : STD_LOGIC_VECTOR (MANTISSA_WIDTH downto 0);
	SIGNAL Carry_Mantissa         : STD_LOGIC;
	
	SIGNAL Shift_direction        : STD_LOGIC;
	SIGNAL Shift_in               : STD_LOGIC_VECTOR(MANTISSA_WIDTH DOWNTO 0);
	SIGNAL Shift_out              : STD_LOGIC_VECTOR(MANTISSA_WIDTH DOWNTO 0);
	
	SIGNAL IS_READY_Signal        : STD_LOGIC;
	SIGNAL auxResult              : STD_LOGIC_VECTOR(N-1 downto 0);


	SIGNAL shiftLeft_Flag : STD_LOGIC := '0'; -- '1': Shift Left
	
	SIGNAL As_XOR_Bs, SumEqSign_OR_SubDiffSign : STD_LOGIC;
	
-- COMPONENTS
	COMPONENT FullAdder_Exponent IS -- 3 bit FullAdder 
		GENERIC (N: integer);
		 PORT ( 
				a 		: in  	STD_LOGIC_VECTOR (EXPONENT_WIDTH-1 downto 0);
				b 		: in  	STD_LOGIC_VECTOR (EXPONENT_WIDTH-1 downto 0);
				M     : in 	   STD_LOGIC;
				Sum 	: out  	STD_LOGIC_VECTOR (EXPONENT_WIDTH-1 downto 0)
				
		 );				
	END COMPONENT;


	COMPONENT FullAdder_Mantissa IS -- 4 bit FullAdder 
		GENERIC(N: integer);
		 PORT( 
				a 		: in  	STD_LOGIC_VECTOR (MANTISSA_WIDTH downto 0);
				b 		: in  	STD_LOGIC_VECTOR (MANTISSA_WIDTH downto 0);
				M     : in 	   STD_LOGIC;
				Sum 	: out  	STD_LOGIC_VECTOR (MANTISSA_WIDTH downto 0);
				Cout  : out    STD_LOGIC
		 );			
	END COMPONENT;

	COMPONENT Shift_right_left IS
		GENERIC(N : NATURAL);
		PORT(
				Shift_direction : IN STD_LOGIC;
				Shift_in  : IN  STD_LOGIC_VECTOR(MANTISSA_WIDTH DOWNTO 0);
				Shift_out : OUT STD_LOGIC_VECTOR(MANTISSA_WIDTH DOWNTO 0)
		);
	END COMPONENT;
	
begin

IS_READY <= IS_READY_Signal;
Result <= auxResult WHEN IS_READY_Signal = '1' ELSE (OTHERS => '0');



adder_exp: FullAdder_Exponent -- 3 bit full adder
	GENERIC map(N => EXPONENT_WIDTH) -- if 3 bit: N => 3
	PORT map(
				a => a_fulladder_exponent,
				b => b_fulladder_exponent,
				M => Complement_exponent,
				Sum => sum_fulladder_exponent
	);
				
adder_mantissa: FullAdder_Mantissa -- 4 bit full adder
	GENERIC map(N => MANTISSA_WIDTH+1) -- if 4 bit: N => 4+1, because one extra bit added later 
	PORT map(
				a => a_fulladder_mantissa,
				b => b_fulladder_mantissa,
				M => Complement_mantissa,
				Sum => sum_fulladder_mantissa,
				Cout => Carry_Mantissa
	);

Shift_Component: Shift_right_left
	GENERIC MAP(N => MANTISSA_WIDTH+1) -- shift in and out width, because one extra bit added later 
	PORT MAP(
			Shift_direction => Shift_direction,
			Shift_in  => Shift_in,
			Shift_out => Shift_out		
	);



Main: Process(CLK, RST)
begin

	if (RST = '0') then
		auxA <= (OTHERS => '0');
		auxB <= (OTHERS => '0');
		A_sgn <= '0';
		B_sgn <= '0';
		A_exp <= (OTHERS => '0');
		B_exp <= (OTHERS => '0');
		A_mantissa <= (OTHERS => '0');
		B_mantissa <= (OTHERS => '0');
		auxResult  <= (OTHERS => '0');
		
		IS_READY_Signal <= '0';
		shiftLeft_Flag <= '0';
		state <= Initialize;
		
	elsif (rising_edge(CLK)) then
	
		CASE state IS
		
			WHEN Initialize =>
				if (LOAD_DATA = '1') then
					auxA <= a;
					auxB <= b;
					state <= Initialize;
					
				elsif(LOAD_DATA = '0') then
					state <= Swap;
				end if;
		
			WHEN Swap =>
				if (unsigned(auxA(EXPONENT_HIGH_INDEX DOWNTO MANTISSA_HIGH_INDEX+1)) >= unsigned(auxB(EXPONENT_HIGH_INDEX DOWNTO MANTISSA_HIGH_INDEX+1))) then
					A_sgn <= a(N-1);
					B_sgn <= b(N-1);
					A_exp <= a(EXPONENT_HIGH_INDEX downto MANTISSA_HIGH_INDEX+1);
					B_exp <= b(EXPONENT_HIGH_INDEX downto MANTISSA_HIGH_INDEX+1);
					A_mantissa <= "1" & a(MANTISSA_HIGH_INDEX downto 0);
					B_mantissa <= "1" & b(MANTISSA_HIGH_INDEX downto 0);				
		
				elsif (unsigned(auxA(EXPONENT_HIGH_INDEX DOWNTO MANTISSA_HIGH_INDEX+1)) < unsigned(auxB(EXPONENT_HIGH_INDEX DOWNTO MANTISSA_HIGH_INDEX+1))) then
					A_sgn <= b(N-1);
					B_sgn <= a(N-1);
					A_exp <= b(EXPONENT_HIGH_INDEX downto MANTISSA_HIGH_INDEX+1);
					B_exp <= a(EXPONENT_HIGH_INDEX downto MANTISSA_HIGH_INDEX+1);
					A_mantissa <= "1" & b(MANTISSA_HIGH_INDEX downto 0);
					B_mantissa <= "1" & a(MANTISSA_HIGH_INDEX downto 0);					
				end if;
		
			state <= Align;
			
			WHEN Align =>
				if(unsigned(A_exp) = unsigned(B_exp)) then
					state <= Mantisaa_adder;
				
				else
					B_exp <= sum_fulladder_exponent;
					B_mantissa <= Shift_out;
					state <= Align; 
				end if;
			
			
			WHEN Mantisaa_adder =>
			 A_mantissa <= sum_fulladder_mantissa;
				if (SumEqSign_OR_SubDiffSign = '1') then -- Check a and b's sign
					if (Carry_Mantissa = '0') then						
						state <= Final;
					elsif (Carry_Mantissa = '1') then
						state <= Normalize;
					end if;
		
				else
					shiftLeft_Flag <= '1'; --'1': Shift Left
					if (Carry_Mantissa = '0') then				
						state <= Pre_Normalize;
					elsif (Carry_Mantissa = '1') then
						state <= Normalize;
					end if;
				end if;
				

			WHEN Pre_Normalize =>
					A_sgn <= NOT A_sgn; -- A Sign's Complement
					A_mantissa <= std_logic_vector(-signed(unsigned(A_mantissa))); -- 2's complement
					state <= Normalize;
				
			WHEN Normalize =>
				A_exp      <= sum_fulladder_exponent;
				A_mantissa <= Shift_out;
				
				if ((shiftLeft_Flag = '1') AND (A_mantissa(A_mantissa'high-1) /= '1')) then -- Shift Left				
					state <= Normalize;
				else	-- Shift Right						
					state <= Final;
				end if;
				
--				A_exp      <= sum_fulladder_exponent;
--				A_mantissa <= Shift_out;
				
			WHEN Final =>
				auxResult <= A_sgn & A_exp & std_logic_vector(resize(unsigned(A_mantissa), MANTISSA_WIDTH)); -- Remove first mantissa bit which added at first state

				IS_READY_Signal <= '1';
				if (LOAD_DATA = '1') then
					IS_READY_Signal <= '0';
					shiftLeft_Flag <= '0';
					state <= Initialize;
				end if;
					
		END CASE;
	
	
	end if;
	
	
end Process Main;




As_XOR_Bs <= (A_sgn XOR B_sgn);

SumEqSign_OR_SubDiffSign <= '1' WHEN ((IS_SUM='1' AND As_XOR_Bs='0') OR (IS_SUM='0' AND As_XOR_Bs='1')) ELSE -- Sum and same Signs or Subtraction and different signs
				'0';



--##S
Complement_exponent  <= '1' WHEN shiftLeft_Flag = '1' ELSE -- 2's Complement, Exponent-1
								'0';

a_fulladder_exponent <= B_exp WHEN (state = Align) ELSE
								A_exp WHEN (state = Normalize) ELSE
							   (OTHERS => '0');

b_fulladder_exponent <= std_logic_vector(to_unsigned(1, b_fulladder_exponent'length));
--##E

--##S
Complement_mantissa <= '0' WHEN (state = Mantisaa_adder) AND (SumEqSign_OR_SubDiffSign = '1') ELSE --TODO: Optimize this condition
						     '1' WHEN ((state = Mantisaa_adder) OR (state = Normalize)) AND (SumEqSign_OR_SubDiffSign = '0') ELSE
							  '0';
							  
a_fulladder_mantissa <= A_mantissa;
b_fulladder_mantissa <= B_mantissa;							  
--##E


--##S
Shift_direction <= '0' WHEN shiftLeft_Flag = '1' ELSE -- '0': Shift Left
						 '1';

Shift_in <= B_mantissa WHEN (state = Align) ELSE -- because a>=b, it is only needed to shift b
				A_mantissa WHEN (state = Normalize) ELSE
				(OTHERS => '0');

--##E
end Behavioral;
