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