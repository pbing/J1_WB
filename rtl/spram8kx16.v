/* Single port RAM 4Kx16 */

`default_nettype none

module spram8kx16
  #(parameter size       = 'h2000,
    parameter addr_width = $clog2(size),
    parameter data_width = 16)
   (input  wire                    clock,
    input  wire [addr_width - 1:0] address,
    input  wire [data_width - 1:0] data,
    output reg  [data_width - 1:0] q,
    input  wire                    wren,
    input  wire                    cen);

   reg [data_width - 1:0] mem[0:size - 1];

   always @(posedge clock)
     if (cen && wren)
       mem[address] <= data;

   always @(posedge clock)
     if (cen)
       q <= mem[address];
endmodule

`resetall
