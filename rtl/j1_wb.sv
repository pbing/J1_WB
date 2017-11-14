/* J1 Forth CPU with Havard architecture and Wishbone interfaces
 *
 * based on
 *     http://excamera.com/sphinx/fpga-j1.html
 *     https://github.com/ros-drivers/wge100_driver
 *     jamesb@willowgarage.com
 */

`default_nettype none

module j1_wb
  (input wire   sys_clk_i, // clock
   input wire   sys_rst_i, // reset
   if_wb.master wbc,       // code bus
   if_wb.master wbd);      // data bus

   import types::*;

   /* instruction fetch */
   instr_t      insn;              // instruction
   logic [12:0] _pc, pc,           // processor counter
		pc_plus_1;         // processor counter + 1

   /* select instruction types */
   logic is_lit, is_ubranch, is_zbranch, is_call, is_alu;

   /* data stack */
   logic        [15:0] dstack[32]; // data stack memory
   logic        [4:0]  _dsp, dsp;  // data stack pointer
   logic        [15:0] _st0, st0;  // top of data stack
   logic        [15:0] st1;        // next of data stack
   logic               _dstkW;     // data stack write

   /* return stack */
   logic        [15:0] rstack[32]; // return stack memory
   logic        [4:0]  _rsp, rsp;  // return stack pointer
   logic        [15:0]  rst0;      // top of return stack
   logic        [15:0] _rstkD;     // return stack data
   logic               _rstkW;     // return stack write

   /* data access */
   wire         [15:0] io_din;     // io data in
   logic               io_rd;      // io read
   logic               io_wr;      // io write
   logic        [15:0] io_addr;    // io address
   logic        [15:0] io_dout;    // io data out

   /* misc. */
   logic wbd_stb_r;

    /* Wishbone code bus */
   assign wbc.adr   = {3'b0, _pc};
   assign wbc.cyc   = 1'b1;
   assign wbc.stb   = 1'b1;
   assign wbc.we    = 1'b0;
   assign insn      = wbc.dat_i;
   assign wbc.dat_o = 16'b0;

   /* Wishbone data bus */
   assign wbd.adr   = {1'b0, io_addr[15:1]};
   assign wbd.cyc   = wbd.stb | wbd_stb_r;
   assign wbd.stb   = io_rd | io_wr;
   assign wbd.we    = io_wr;
   assign io_din    = wbd.dat_i;
   assign wbd.dat_o = io_dout;

   /* extend STB by one cycle */
   always_ff @(posedge sys_clk_i)
     if (sys_rst_i)
       wbd_stb_r <= 1'b0;
     else
       wbd_stb_r <= wbd.stb;

   /* data and return stack */
   always_ff @(posedge sys_clk_i)
     begin
	if (_dstkW)
	  dstack[_dsp] <= st0;

	if (_rstkW)
	  rstack[_rsp] <= _rstkD;
     end

   always_comb
     begin
	st1  = dstack[dsp];
	rst0 = rstack[rsp];
     end

   /* select instruction types */
   always_comb
     begin
	is_lit     = insn.lit.tag;
	is_ubranch = insn.bra.tag == TAG_UBRANCH;
	is_zbranch = insn.bra.tag == TAG_ZBRANCH;
	is_call    = insn.bra.tag == TAG_CALL;
	is_alu     = insn.bra.tag == TAG_ALU;
     end

   /* calculate next TOS value */
   always_comb
     if (is_lit)
       _st0 = {1'b0, insn.lit.immediate};
     else
       begin
	  var op_t op;

	  unique case (1'b1)
	    is_ubranch:  op = OP_T;
	    is_zbranch:  op = OP_N;
	    is_call   :  op = OP_T;
	    is_alu    :  op = insn.alu.op;
	    default      op = op_t'('x);
	  endcase

	  case (op)
            OP_T         : _st0 = st0;
            OP_N         : _st0 = st1;
            OP_T_PLUS_N  : _st0 = st0 + st1;
            OP_T_AND_N   : _st0 = st0 & st1;
            OP_T_IOR_N   : _st0 = st0 | st1;
            OP_T_XOR_N   : _st0 = st0 ^ st1;
            OP_INV_T     : _st0 = ~st0;
            OP_N_EQ_T    : _st0 = {16{(st1 == st0)}};
            OP_N_LS_T    : _st0 = {16{($signed(st1) < $signed(st0))}};
            OP_N_RSHIFT_T: _st0 = st1 >> st0[3:0];
            OP_T_MINUS_1 : _st0 = st0 - 16'd1;
            OP_R         : _st0 = rst0;
            OP_AT        : _st0 = io_din;
            OP_N_LSHIFT_T: _st0 = st1 << st0[3:0];
            OP_DEPTH     : _st0 = {3'b0, rsp, 3'b0, dsp};
            OP_N_ULS_T   : _st0 = {16{(st1 < st0)}};
            default        _st0 = 16'hx;
	  endcase
       end

   /* I/O and RAM control */
   always_comb
     begin
	io_wr   = is_alu & insn.alu.n_to_mem;
	//io_rd   = is_alu && (insn.alu.op == OP_AT);
	//io_addr = st0;
	io_rd   = 1'b1;
	io_addr = _st0;
	io_dout = st1;
     end

   /* data and return stack control */
   always_comb
     begin
	_dsp   = dsp;
	_dstkW = 1'b0;
	_rsp   = rsp;
	_rstkW = 1'b0;
	_rstkD = 16'hx;

	/* literals */
	if (is_lit)
	  begin
	     _dsp   = dsp + 5'd1;
	     _dstkW = 1'b1;
	  end
	/* ALU operations */
	else if (is_alu)
	  begin
	     logic signed [4:0] dd, rd; // stack delta

	     dd     = insn.alu.dstack;
	     rd     = insn.alu.rstack;
	     _dsp   = dsp + dd;
	     _dstkW = insn.alu.t_to_n;
	     _rsp   = rsp + rd;
	     _rstkW = insn.alu.t_to_r;
	     _rstkD = st0;
	  end
	else
	  /* branch/call */
	  begin
	     if (is_zbranch)
	       /* predicated jump is like DROP */
               _dsp = dsp - 5'd1;

	     if (is_call)
	       begin
		  _rsp   = rsp + 5'd1;
		  _rstkW = 1'b1;
		  _rstkD = pc_plus_1 << 1;
	       end
	  end
     end

   /* control PC */
   always_comb pc_plus_1 = pc + 13'd1;

   always_comb
     if (sys_rst_i)
       _pc = pc;
     else
       if (is_ubranch || (is_zbranch && (st0 == 16'h0)) || is_call)
         _pc = insn.bra.address;
       else if (is_alu && insn.alu.r_to_pc)
         _pc = rst0 >> 1;
       else
         _pc = pc_plus_1;

   /* update PC and stacks */
   always_ff @(posedge sys_clk_i)
     if (sys_rst_i)
       begin
	  pc  <= 13'h0;
	  dsp <=  5'd0;
	  st0 <= 16'h0;
	  rsp <=  5'd0;
       end
     else
       begin
	  pc  <= _pc;
	  dsp <= _dsp;
	  st0 <= _st0;
	  rsp <= _rsp;
       end
endmodule

`resetall
