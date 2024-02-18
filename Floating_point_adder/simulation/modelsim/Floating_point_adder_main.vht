-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "12/26/2021 02:04:37"
                                                            
-- Vhdl Test Bench template for design  :  Floating_point_adder_main
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY Floating_point_adder_main_vhd_tst IS
END Floating_point_adder_main_vhd_tst;
ARCHITECTURE Floating_point_adder_main_arch OF Floating_point_adder_main_vhd_tst IS
-- constants 
CONSTANT T : TIME := 20 ns;                                                 
-- signals                                                   
SIGNAL a : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
SIGNAL b : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
SIGNAL CLK : STD_LOGIC := '0';
SIGNAL IS_Ready : STD_LOGIC := '0';
SIGNAL IS_SUM : STD_LOGIC := '1';
SIGNAL LOAD_DATA : STD_LOGIC := '0';
SIGNAL Result : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL RST : STD_LOGIC := '0';
COMPONENT Floating_point_adder_main
	PORT (
	a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	b : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	CLK : IN STD_LOGIC;
	IS_Ready : OUT STD_LOGIC;
	IS_SUM : IN STD_LOGIC;
	LOAD_DATA : IN STD_LOGIC;
	Result : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	RST : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : Floating_point_adder_main
	PORT MAP (
-- list connections between master ports and signals
	a => a,
	b => b,
	CLK => CLK,
	IS_Ready => IS_Ready,
	IS_SUM => IS_SUM,
	LOAD_DATA => LOAD_DATA,
	Result => Result,
	RST => RST
	);
init : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
        -- code that executes only once
			RST <= '0';
			WAIT FOR T;
			RST <= '1';
			
			LOAD_DATA <= '1';
			WAIT FOR T;
			
			a <= "00010010";
			b <= "00010110";
			
			WAIT FOR T;
			
			LOAD_DATA <= '0';
WAIT;                                                       
END PROCESS init;                                           
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN                                                         
        -- code executes for every event on sensitivity list 
	 CLK <= not(CLK);
    wait for T/2; 
	 
	if(IS_Ready = '1') then
		wait;
	end if;
		  
--WAIT;                                                        
END PROCESS always;                                      
END Floating_point_adder_main_arch;
