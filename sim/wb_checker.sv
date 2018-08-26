/* Classic pipelined Wishbone B4 protocol checker */

module wb_checker (if_wb.monitor wb);

   /************************************************************************
    * Check if every bus signal is valid driven.
    ************************************************************************/
   assert_driven
     #(.bw  (1),
       .msg ("CYC must not be X or Z"))
   chk_unkown_cyc
     (.clk     (wb.clk),
      .reset_n (~wb.rst),
      .exp     (wb.cyc));

   assert_implication
     #(.msg ("STB must not be X or Z"))
   chk_unkown_stb
     (.clk             (wb.clk),
      .reset_n         (~wb.rst),
      .antecedent_expr (wb.cyc),
      .consequent_expr (!$isunknown(wb.stb)));

   assert_implication
     #(.msg ("STALL must not be X or Z"))
   chk_unkown_stall
     (.clk             (wb.clk),
      .reset_n         (~wb.rst),
      .antecedent_expr (wb.cyc),
      .consequent_expr (!$isunknown(wb.stall)));

   assert_implication
     #(.msg ("ACK must not be X or Z"))
   chk_unkown_ack
     (.clk             (wb.clk),
      .reset_n         (~wb.rst),
      .antecedent_expr (wb.cyc),
      .consequent_expr (!$isunknown(wb.ack)));

   assert_implication
     #(.msg ("ADR must not be X or Z"))
   chk_unkown_adr
     (.clk             (wb.clk),
      .reset_n         (~wb.rst),
      .antecedent_expr (wb.cyc && wb.stb),
      .consequent_expr (!$isunknown(wb.adr)));

   assert_implication
     #(.msg ("DAT_O from master must not be X or Z"))
   chk_unkown_dat_m
     (.clk             (wb.clk),
      .reset_n         (~wb.rst),
      .antecedent_expr (wb.cyc && wb.stb),
      .consequent_expr (!$isunknown(wb.dat_m)));

   assert_implication
     #(.msg ("WE must not be X or Z"))
   chk_unkown_we
     (.clk             (wb.clk),
      .reset_n         (~wb.rst),
      .antecedent_expr (wb.cyc && wb.stb),
      .consequent_expr (!$isunknown(wb.we)));

   assert_implication
     #(.msg ("DAT_I to master must not be X or Z"))
   chk_unkown_dat_s
     (.clk             (wb.clk),
      .reset_n         (~wb.rst),
      .antecedent_expr (wb.cyc && wb.ack),
      .consequent_expr (!$isunknown(wb.dat_s)));

   /************************************************************************
    * There must be an ACK for each STB.
    ************************************************************************/
   assert_next
     #(.num_cks (1), // Is this true for classic pipeline mode?
       .msg     ("Transaction is missing ACK after STB"))
   chk_transaction
     (.clk         (wb.clk),
      .reset_n     (~wb.rst),
      .start_event (wb.cyc && wb.stb && !wb.stall),
      .test_expr   (wb.ack));
endmodule
