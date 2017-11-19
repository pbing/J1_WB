/* J1 core */

`default_nettype none

module j1_core
  #(parameter dstack_depth = 32, // data stack depth (max. 32)
    parameter rstack_depth = 32) // return stack depth (max. 32)
   (input wire     clk,          // clock
    input wire     reset,        // reset
    if_ibus.master ibus,         // instruction bus
    if_dbus.master dbus);        // data bus

   import types::*;

   /* instruction fetch */
   logic [15:0]      insn, insn_r;         // instruction
   logic [12:0] _pc, pc,              // processor counter
		pc_plus_1;            // processor counter + 1

   /* select instruction types */
   logic is_lit, is_ubranch, is_zbranch, is_call, is_alu,
         is_fetch, is_store;

   /* data stack */
   logic [4:0]  _dsp, dsp;            // data stack pointer
   logic [15:0] _st0, st0;            // top of data stack
   logic [15:0] st1;                  // next of data stack
   logic        _dstkW;               // data stack write

   /* return stack */
   logic [4:0]  _rsp, rsp;            // return stack pointer
   logic [15:0] rst0;                 // top of return stack
   logic [15:0] _rstkD;               // return stack data
   logic        _rstkW;               // return stack write

   /* memory access control */
   logic        stb_re, stb_we;       // strobe
   logic        insn_wait;            // instruction wait
   logic        mem_wait;             // memory wait

   /* data stack */
   register_file
     #(dstack_depth)
   dstack
     (.clk,
      .wen (_dstkW),
      .wa  (_dsp),
      .ra  (dsp),
      .d   (st0),
      .q   (st1));

   /* return stack */
   register_file
     #(rstack_depth)
   rstack
     (.clk,
      .wen (_rstkW),
      .wa  (_rsp),
      .ra  (rsp),
      .d   (_rstkD),
      .q   (rst0));

   /* select instruction types */
   always_comb
     begin
	is_lit     = insn[15];
	is_ubranch = insn[15:13] == TAG_UBRANCH;
	is_zbranch = insn[15:13] == TAG_ZBRANCH;
	is_call    = insn[15:13] == TAG_CALL;
	is_alu     = insn[15:13] == TAG_ALU;
     end

   /* calculate next TOS value */
   always_comb
     if (is_lit)
       _st0 = {1'b0, insn[14:0]};
     else
       begin
	  var op_t op;

	  unique case (1'b1)
	    is_ubranch:  op = OP_T;
	    is_zbranch:  op = OP_N;
	    is_call   :  op = OP_T;
	    is_alu    :  op = op_t'(insn[11:8]);
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
            OP_AT        : _st0 = dbus.dat_i;
            OP_N_LSHIFT_T: _st0 = st1 << st0[3:0];
            OP_DEPTH     : _st0 = {3'b0, rsp, 3'b0, dsp};
            OP_N_ULS_T   : _st0 = {16{(st1 < st0)}};
            default        _st0 = 16'hx;
	  endcase
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

	     dd     = insn[1:0];
	     rd     = insn[3:2];
	     _dsp   = dsp + dd;
	     _dstkW = insn[7];
	     _rsp   = rsp + rd;
	     _rstkW = insn[6];
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
     if (reset || insn_wait)
       _pc = pc;
     else if (is_ubranch || (is_zbranch && (st0 == 16'h0)) || is_call)
       _pc = insn[12:0];
     else if (is_alu && insn[12])
       _pc = rst0 >> 1;
     else
       _pc = pc_plus_1;

   /* update PC and stacks */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       begin
	  pc  <= 13'h0;
	  dsp <=  5'd0;
	  st0 <= 16'h0;
	  rsp <=  5'd0;
       end
     else
       if (!insn_wait)
         begin
	    pc  <= _pc;
	    dsp <= _dsp;
	    st0 <= _st0;
	    rsp <= _rsp;
         end

   always_comb
     begin
        ibus.adr   = {3'b0, _pc};
        ibus.re    = reset | ~insn_wait;
        insn       = !mem_wait ? ibus.dat : insn_r;

	dbus.adr   = {1'b0, st0[15:1]};
        dbus.re    = stb_re;
        dbus.we    = stb_we;
	dbus.dat_o = st1;
     end

   /* memory access control */
   always_comb is_fetch  = is_alu && (insn[11:8] == OP_AT);
   always_comb is_store  = is_alu & insn[5];
   always_comb stb_re    = ~mem_wait & is_fetch;
   always_comb stb_we    = ~mem_wait & is_store;
   always_comb insn_wait = stb_re | stb_we;

   always_ff @(posedge clk or posedge reset)
     if (reset)
       mem_wait <= 1'b0;
     else
       if (!mem_wait)
         mem_wait <= is_fetch | is_store;
       else
         mem_wait <= 1'b0;

   /* keep instruction constant during memory wait state */
   always_ff @(posedge clk)
     if (!mem_wait)
       insn_r <= ibus.dat;
endmodule

`resetall
