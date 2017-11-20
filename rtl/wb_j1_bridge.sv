/* Bridge Wishbone to J1 ibus() and dbus() interfaces */

module wb_j1_bridge
  (if_ibus.slave ibus,
   if_dbus.slave dbus,
   if_wb.master  wb);

   /* connect to Wishbone interface with no wait states */
   always_comb
     begin
        wb.adr     = ibus.re ? ibus.adr : dbus.adr;
        wb.stb     = ibus.re | dbus.re | dbus.we;
        wb.cyc     = wb.stb;
        wb.we      = dbus.we;
        wb.dat_m   = dbus.dat_m;
        ibus.dat   = wb.dat_s;
        dbus.dat_s = wb.dat_s;
     end
endmodule
