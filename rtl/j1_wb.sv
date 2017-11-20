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

   if_ibus ibus();
   if_dbus dbus();

   wb_j1_bridge bridge(.ibus, .dbus, .wb);

   j1_core
     #(.dstack_depth(dstack_depth),
       .rstack_depth(rstack_depth))
   core
     (.clk, .reset, .ibus, .dbus);
endmodule

`resetall
