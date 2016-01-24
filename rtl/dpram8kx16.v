/* dual Port RAM 8Kx16 */

module dpram8kx16
  (input  wire        clock,
   input  wire [12:0] address_a,
   input  wire [15:0] data_a,
   input  wire        wren_a,
   output reg  [15:0] q_a,
   input  wire [12:0] address_b,
   input  wire [15:0] data_b,
   input  wire        wren_b,
   output reg  [15:0] q_b);

   reg [15:0] mem[0:'h2000 - 1];

   always @(posedge clock)
     if (wren_a)
       mem[address_a] <= data_a;

   always @(posedge clock)
     q_a <= mem[address_a];

   always @(posedge clock)
     if (wren_b)
       mem[address_b] <= data_b;

   always @(posedge clock)
     q_b <= mem[address_b];
endmodule
