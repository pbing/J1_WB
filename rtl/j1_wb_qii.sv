/* J1 Forth CPU with Wishbone interface
 *
 * based on
 *     http://excamera.com/sphinx/fpga-j1.html
 *     https://github.com/ros-drivers/wge100_driver
 *     jamesb@willowgarage.com
 */

`default_nettype none

module j1_wb
  #(parameter dstack_depth = 32, // data stack depth (max. 32)
    parameter rstack_depth = 32) // return stack depth (max. 32)
   (input wire   clk,            // clock
    input wire   reset,          // reset
    if_wb.master wb);            // Wishbone bus

   import j1_types::*;

   /* instruction fetch */
   logic [15:0]  instr;           // instruction
   logic [12:0] _npc, npc,       // processor counter
                pc;

   /* select instruction types */
   logic is_lit, is_ubranch, is_zbranch, is_call, is_alu;


   /* data stack */
   logic [4:0]  _dsp, dsp;       // data stack pointer
   logic [15:0] _st0, st0;       // top of data stack
   logic [15:0] st1;             // next of data stack
   logic        _dstkW;          // data stack write

   /* return stack */
   logic [4:0]  _rsp, rsp;       // return stack pointer
   logic [15:0] rst0;            // top of return stack
   logic [15:0] _rstkD;          // return stack data
   logic        _rstkW;          // return stack write

   /* memory access control */
   logic        is_ld, is_st;
   wire         instr_bubble;
   wire         mem_addr_sel;
   wire         ld_st0;
   logic        we_l;
   logic [15:0] dat_o_l;

   /* work around missing modport expressions */
   wire  [15:0] wb_dat_i;
   logic [15:0] wb_dat_o;

`ifdef NO_MODPORT_EXPRESSIONS
   assign wb_dat_i = wb.dat_s;
   assign wb.dat_m = wb_dat_o;
`else
   assign wb_dat_i = wb.dat_i;
   assign wb.dat_o = wb_dat_o;
`endif

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
        is_lit     = instr[15];
        is_ubranch = instr[15:13] == TAG_UBRANCH;
        is_zbranch = instr[15:13] == TAG_ZBRANCH;
        is_call    = instr[15:13] == TAG_CALL;
        is_alu     = instr[15:13] == TAG_ALU;
        is_ld      = is_alu && instr[11:8] == OP_AT;
        is_st      = is_alu & instr[5];
     end

   /* calculate next TOS value */
   always_comb
     if (is_lit)
       _st0 = {1'b0, instr[14:0]};
     else if (ld_st0)
       _st0 = wb_dat_i;
     else
       begin
          var op_t op;

          unique case (1'b1)
            is_ubranch:  op = OP_T;
            is_zbranch:  op = OP_N;
            is_call   :  op = OP_T;
            is_alu    :  op = op_t'(instr[11:8]);
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
            OP_N_RSHIFT_T: _st0 = (st0 > 15) ? 16'h0 : st1 >> st0[3:0];
            OP_T_MINUS_1 : _st0 = st0 - 16'd1;
            OP_R         : _st0 = rst0;
            OP_AT        : _st0 = st0; // delayed due to bus sharing
            OP_N_LSHIFT_T: _st0 = (st0 > 15) ? 16'h0 : st1 << st0[3:0];
            OP_DEPTH     : _st0 = {3'b0, rsp, 3'b0, dsp};
            OP_N_ULS_T   : _st0 = {16{(st1 < st0)}};
            default        _st0 = 'x;
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

             dd     = $signed(instr[1:0]); // explicit, because signed info is lost when using j1_wb_qii.sv
             rd     = $signed(instr[3:2]);
             _dsp   = dsp + dd;
             _dstkW = instr[7];
             _rsp   = rsp + rd;
             _rstkW = instr[6];
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
                  _rstkD = npc << 1;
               end
          end
     end

   /* control PC */
   always_comb
     if (is_ubranch || (is_zbranch && (st0 == 16'h0)) || is_call)
       pc = instr[12:0];
     else if (is_alu && instr[12])
       pc = rst0[13:1];
     else
       pc = npc;

   always_comb
     if(mem_addr_sel || wb.stall)
       _npc = pc;
     else
       _npc= pc + 13'd1;

   /* update PC and stacks */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       begin
          npc <= 13'h0;
          dsp <=  5'd0;
          st0 <= 16'h0;
          rsp <=  5'd0;
       end
     else
       if (wb.cyc)
         begin
            npc <= _npc;
            dsp <= _dsp;
            st0 <= _st0;
            rsp <= _rsp;
         end


   always_ff @(posedge clk or posedge reset)
     if (reset)
       we_l <= 1'b0;
     else
       if (is_ld || is_st)
         we_l <= wb.we;

   always_ff @(posedge clk or posedge reset)
     if (reset)
       dat_o_l <= '0;
     else
       if (is_st)
         dat_o_l <= st1;

   always_comb
     if (!wb.ack || instr_bubble)
       instr = 16'h6000; // NOOP
     else
       instr = wb_dat_i;

   /* Wishbone */
   always_ff @(posedge clk or posedge reset)
     if (reset)
       begin
          wb.cyc <= 1'b0;
          wb.stb <= 1'b0;
       end
     else
       begin
          wb.cyc <= 1'b1;
          wb.stb <= 1'b1;
       end

   always_comb
     if (is_st)
       wb_dat_o = st1;
     else
       wb_dat_o = dat_o_l;

   always_comb
     if (mem_addr_sel)
       begin
          wb.adr = {1'b0, st0[15:1]};
          wb.we  = is_st || (we_l && !is_ld);
       end
     else
       begin
          wb.adr = {3'b0, pc};
          wb.we  = 1'b0;
       end

   /* Control FSM */
   enum integer unsigned {START, LD[2], ST[2]} state, next;

   always_ff @(posedge clk or posedge reset)
     if (reset)
       state <= START;
     else
       state <= next;

   always_comb
     begin
        next = state;

        case (state)
          START:
            if (is_ld && wb.stall)
              next = LD0;
            else if (is_ld && !wb.stall)
              next = LD1;
            else if (is_st && wb.stall)
              next = ST0;
            else if (is_st && !wb.stall)
              next = ST1;

          LD0:
            if (!wb.stall)
              next = LD1;

          LD1:
            if (wb.ack)
              next = START;

          ST0:
            if (!wb.stall)
              next = ST1;

          ST1:
            if (wb.ack)
              next = START;

          default
            next = START;
        endcase
     end

   assign instr_bubble = state == LD0 || state == LD1 || state == ST0 || state == ST1;
   assign mem_addr_sel = is_ld || state == LD0 || is_st || state == ST0;
   assign ld_st0       = state == LD1 && wb.ack;
endmodule

`resetall
