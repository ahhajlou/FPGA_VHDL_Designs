# Description

This floating-point multiplier, implemented in the VHDL, was one of the projects I did for my FPGA course at the university.

# How it works

In this design, the exponent is assumed to be biased (with a bias of 3 for an 8-bit multiplier). Therefore, to multiply two numbers, the exponents are added and then the bias is subtracted.

In the multiplication step, an extra bit is added to the beginning of both mantissas, and the value 1 is set in the MSB of the mantissas.

Finally, to transfer the result of the multiplication, which has a width of (2N+2), to the register that stores the mantissa result, the first two bits of the product are discarded.

In the rounding step, the width of the mantissa bits is separated from the left side of the number obtained in the previous step, and if the most significant bit of the separated number is 1, the final value of the mantissa is incremented by 1.

The sign bit is obtained by XORing the signs of the two numbers.