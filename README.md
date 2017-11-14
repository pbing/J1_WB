# Description
J1 Forth CPU core with Wishbone interface adapted from [System Verilog source](https://github.com/pbing/J1).

# Architecture
Havard architecture, one bus for code (ROM), second bus for data (RAM or I/O).

bus  | modules  | address range
-----|----------|------------------
code | ROM      | 0x0000 ... 0x3fff
data | RAM, I/O | 0x0000 ... 0x7fff

# TODO
Implement Wishbone protocol with wait states -- at least for the data bus.

This would also allow to detect RAM or I/O read access when opcode
OP_AT is selected. The power consumption will be lowered at the cost
of a 2-cycle read access.

With defered RAM or I/O read change this code fragment
```systemverilog
	io_rd   = 1'b1;
	io_addr = _st0;
```
to
```systemverilog
	io_rd   = is_alu && (insn.alu.op == OP_AT);
	io_addr = st0;
 ```
