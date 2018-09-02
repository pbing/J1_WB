/* Single port RAM */

`default_nettype none

module spram
  #(parameter size       = 'h10000, // maximum data space for J1
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
     if (cen)
       begin
          if (wren)
            mem[address] <= data;

          q <= mem[address];
       end
endmodule

`resetall
