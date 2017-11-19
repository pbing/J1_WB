/* Type definitions */
package types;

   typedef enum logic [2:0] 
                {TAG_UBRANCH, TAG_ZBRANCH, TAG_CALL, TAG_ALU} tag_t;

   typedef enum logic [3:0] 
                {OP_T, OP_N, OP_T_PLUS_N, OP_T_AND_N,
	         OP_T_IOR_N, OP_T_XOR_N, OP_INV_T, OP_N_EQ_T,
	         OP_N_LS_T, OP_N_RSHIFT_T, OP_T_MINUS_1, OP_R,
	         OP_AT, OP_N_LSHIFT_T, OP_DEPTH, OP_N_ULS_T} op_t;

`ifndef NO_UNION_SUPPORT
   typedef union packed {
      struct packed {
         logic        tag;
         logic [14:0] immediate;
      } lit;

      struct packed {
         tag_t        tag;
         logic [12:0] address;
      } bra;

      struct packed {
         tag_t              tag;
         logic              r_to_pc;
         op_t               op;
         logic              t_to_n;
         logic              t_to_r;
         logic              n_to_mem;
         logic              reserved;
         logic signed [1:0] rstack;
         logic signed [1:0] dstack;
      } alu;
   } instr_t;
`endif
endpackage
