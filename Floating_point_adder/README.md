# Description

This floating-point adder, implemented in the VHDL, was one of the projects I did for my FPGA course at the university.

# How it works

The floating point adder circuit in this project is based on the algorithm and flowchart described in the "Computer Architecture" book by Morris Mano. 

In the process of aligning the mantissas, it is necessary for one of the mantissas, either a or b, to undergo a shift until their representations match. The exact number of shifts required is not specified; therefore, to simplify the control of various states, a Finite State Machine (FSM) has been employed in the project's code.

To perform the addition operation, two separate adders are used as components. The selection of the operator is determined by the value of bit M. Logical shifting operations are performed by invoking the relevant component and assigning the number of shifts to the Shift_in bits, along with determining the shift direction through the Shift_direction bit control.

While calculations are ongoing, the value of the IS_Ready bit is set to zero. Eventually, in the final stage after obtaining the final result, the value of this bit becomes one.