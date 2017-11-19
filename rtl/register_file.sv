/* Stack registers */

`default_nettype none

module register_file
  #(parameter size = 32)    // stack size (max. 32)
   (input  wire        clk, // clock
    input  wire        wen, // write enable
    input  wire [4:0]  wa,  // write address
    input  wire [4:0]  ra,  // read address
    input  wire [15:0] d,   // data in
    output wire [15:0] q);  // top of stack

   logic [15:0] mem[size];  //  memory

   always_ff @(posedge clk)
     if (wen)
       mem[wa] <= d;

   assign q = mem[ra];
endmodule

`resetall
