/* Dummy model */

`default_nettype none

module pll
  (input  wire refclk,
   input  wire rst,
   output bit  outclk_0,
   output bit  locked);

   timeunit 1ns;
   timeprecision 1ps;

   always #5ns outclk_0 = ~outclk_0;

   initial #11ns locked = 1'b1;
endmodule

`resetall
