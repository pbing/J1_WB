# Description
J1 Forth CPU core with Wishbone interface adapted from [System Verilog source](https://github.com/pbing/J1).

Almost all instructions are performed in one clock cycle. Memory access needs two clock cycles.

## Memory Map
modules  | address range
---------|------------------
ROM      | 0x0000 ... 0x3fff
RAM, I/O | 0x4000 ... 0x7fff

## TODO
This design assumes no wait cycles from the memories or
I/O. Add wait cycles in order to conform the Wishbone standard.

## Synthesis results TSMC 90 nm Logic low-power

fclk = 400 MHz

Area dependend on stack depth:
dc_shell> get_lib_attribute tcbn90lphpwc_ccs/ND2D1 area
2.822400

 dstack_depth | rstack-depth |  area | gates 
--------------|--------------|-------|-------
            8 |            8 | 10841 |  3841 
           12 |           12 | 13572 |  4808 
           16 |           16 | 16348 |  5792 
           20 |           20 | 19463 |  6896 
           24 |           24 | 21732 |  7700 
           28 |           28 | 24460 |  8666 
           32 |           32 | 27071 |  9591 
