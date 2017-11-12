/* ROM 4Kx16 */

`default_nettype none

module rom8kx16
  #(parameter size       = 'h2000,
    parameter addr_width = $clog2(size),
    parameter data_width = 16)
   (input  wire                    clock,
    input  wire [addr_width - 1:0] address,
    output reg  [data_width - 1:0] q,
    input  wire                    cen);

   reg [data_width - 1:0] mem[0:size - 1];

   always @(posedge clock)
     if (cen)
       q <= mem[address];
endmodule

`resetall
