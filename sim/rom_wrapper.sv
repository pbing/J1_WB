/* ROM interface wrapper */

module rom_wrapper
  (input wire    clk,
   if_ibus.slave ibus);

   rom
     #(.size('h2000))
   rom
     (.clock   (clk),
      .address (ibus.adr[12:0]),
      .q       (ibus.dat),
      .cen     (ibus.re));
endmodule
