# Description
[J1: a small Forth CPU Core for FPGAs](http://excamera.com/sphinx/fpga-j1.html)

Rewritten in SystemVerilog from [Verilog Source](https://github.com/ros-drivers/wge100_driver/tree/hydro-devel/wge100_camera_firmware/src/hardware/verilog/j1.v).

Almost all instructions are performed in one clock cycle. Memory access needs two clock cycles. Program size can be as large as 16 kB (8192 instructions).

## Memory Map
| modules  | type       | address range     |
|----------|------------|-------------------|
| ROM, RAM | code, data | 0x0000 ... 0x3fff |
| RAM, I/O | data       | 0x4000 ... 0xffff |

## FPGA synthesis
[Cyclone V GX Starter Kit](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=167&No=830&PartNo=1)

fclk = 100 MHz

## ASIC synthesis
TSMC 90 nm Logic low-power (SVT/LVT/HVT)

fclk = 120 MHz

Area of module `j1_wb` dependent on stack depth:
```
dc_shell> get_lib_attribute tcbn90lphpwc_ccs/ND2D1 area
2.822400
```

| dstack_depth | rstack_depth | area  [µm²] | gates |
|--------------|--------------|-------------|-------|
|            8 |            8 |       11377 |  4031 |
|           12 |           12 |       14464 |  5125 |
|           16 |           16 |       17020 |  6030 |
|           20 |           20 |       19626 |  6957 |
|           24 |           24 |       23127 |  8194 |
|           28 |           28 |       24968 |  8846 |
|           32 |           32 |       27932 |  9897 |

gates = 2154 + 243 * depth
