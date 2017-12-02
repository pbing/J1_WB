/* FPGA Toplevel */

//`define ENABLE_DDR2LP
//`define ENABLE_HSMC_XCVR
//`define ENABLE_SMA
//`define ENABLE_REFCLK
`define ENABLE_GPIO

`default_nettype none

module top_c5gx
  (/* ADC (1.2 V) */
   output wire        ADC_CONVST,
   output wire        ADC_SCK,
   output wire        ADC_SDI,
   input  wire        ADC_SDO,

   /* AUD (2.5 V) */
   input  wire        AUD_ADCDAT,
   inout  wire        AUD_ADCLRCK,
   inout  wire        AUD_BCLK,
   output wire        AUD_DACDAT,
   inout  wire        AUD_DACLRCK,
   output wire        AUD_XCK,

   /* CLOCK */
   input  wire        CLOCK_125_p,    // LVDS
   input  wire        CLOCK_50_B5B,   // 3.3-V LVTTL
   input  wire        CLOCK_50_B6A,
   input  wire        CLOCK_50_B7A,   // 2.5 V
   input  wire        CLOCK_50_B8A,

   /* CPU */
   input  wire        CPU_RESET_n,    // 3.3V LVTTL

`ifdef ENABLE_DDR2LP
   /* DDR2LP (1.2-V HSUL) */
   output wire [9:0]  DDR2LP_CA,
   output wire [1:0]  DDR2LP_CKE,
   output wire        DDR2LP_CK_n,    // DIFFERENTIAL 1.2-V HSUL
   output wire        DDR2LP_CK_p,    // DIFFERENTIAL 1.2-V HSUL
   output wire [1:0]  DDR2LP_CS_n,
   output wire [3:0]  DDR2LP_DM,
   inout  wire [31:0] DDR2LP_DQ,
   inout  wire [3:0]  DDR2LP_DQS_n,   // DIFFERENTIAL 1.2-V HSUL
   inout  wire [3:0]  DDR2LP_DQS_p,   // DIFFERENTIAL 1.2-V HSUL
   input  wire        DDR2LP_OCT_RZQ, // 1.2 V
`endif

`ifdef ENABLE_GPIO
   /* GPIO (3.3-V LVTTL) */
   inout  wire [35:0] GPIO,
`else	
   /* HEX2 (1.2 V) */
   output wire [6:0]  HEX2,

   /* HEX3 (1.2 V) */
   output wire [6:0]  HEX3,		


`endif

   /* HDMI */
   output wire        HDMI_TX_CLK,
   output wire [23:0] HDMI_TX_D,
   output wire        HDMI_TX_DE,
   output wire        HDMI_TX_HS,
   input  wire        HDMI_TX_INT,
   output wire        HDMI_TX_VS,

   /* HEX0 */
   output wire [6:0]  HEX0,

   /* HEX1 */
   output wire [6:0]  HEX1,


   /* HSMC (2.5 V) */
   input  wire        HSMC_CLKIN0,
   input  wire [2:1]  HSMC_CLKIN_n,
   input  wire [2:1]  HSMC_CLKIN_p,
   output wire        HSMC_CLKOUT0,
   output wire [2:1]  HSMC_CLKOUT_n,
   output wire [2:1]  HSMC_CLKOUT_p,
   inout  wire [3:0]  HSMC_D,
`ifdef ENABLE_HSMC_XCVR		
   input  wire [3:0]  HSMC_GXB_RX_p,  //  1.5-V PCML
   output wire [3:0]  HSMC_GXB_TX_p,  //  1.5-V PCML
`endif
   inout  wire [16:0] HSMC_RX_n,
   inout  wire [16:0] HSMC_RX_p,
   inout  wire [16:0] HSMC_TX_n,
   inout  wire [16:0] HSMC_TX_p,


   /* I2C (2.5 V) */
   output wire        I2C_SCL,
   inout  wire        I2C_SDA,

   /* KEY (1.2 V) */
   input  wire [3:0]  KEY,

   /* LEDG (2.5 V) */
   output wire [7:0]  LEDG,

   /* LEDR (2.5 V) */
   output wire [9:0]  LEDR,

`ifdef ENABLE_REFCLK
   /* REFCLK (1.5-V PCML) */
   input  wire        REFCLK_p0,
   input  wire        REFCLK_p1,
`endif

   /* SD (3.3-V LVTTL) */
   output wire        SD_CLK,
   inout  wire        SD_CMD,
   inout  wire [3:0]  SD_DAT,

`ifdef ENABLE_SMA
   /* SMA (1.5-V PCML) */
   input  wire        SMA_GXB_RX_p,
   output wire        SMA_GXB_TX_p,
`endif

   /* SRAM (3.3-V LVTTL) */
   output wire [17:0] SRAM_A,
   output wire        SRAM_CE_n,
   inout  wire [15:0] SRAM_D,
   output wire        SRAM_LB_n,
   output wire        SRAM_OE_n,
   output wire        SRAM_UB_n,
   output wire        SRAM_WE_n,

   /* SW (1.2 V) */
   input  wire [9:0]  SW,

   /* UART (2.5 V) */
   input  wire        UART_RX,
   output wire        UART_TX);

   wire reset; // reset
   wire clk;   // clock

   if_wb wbm (.rst(reset), .clk);
   if_wb wbs1(.rst(reset), .clk);
   if_wb wbs2(.rst(reset), .clk);
   if_wb wbs3(.rst(reset), .clk);
   if_wb wbs4(.rst(reset), .clk);
   if_wb wbs5(.rst(reset), .clk);

   j1_wb dut(.wb(wbm), .*);

   wb_rom wb_rom(.wb(wbs1)); // ROM 0000H...3FFFH
   wb_ram wb_ram(.wb(wbs2)); // RAM 4000H...4FFFH

   /* I/O 5000H...5FFFH */
   wb_io  wb_io1
     (.wb     (wbs3),
      .io_out (GPIO[15:0]),
      .io_in  (GPIO[31:16]));

   /* I/O 6000H...6FFFH */
   wb_io  wb_io2
     (.wb     (wbs4),
      .io_out (/*open*/),
      .io_in  ({6'h00, SW}));

   /*  I/O 7000H...7FFFH */
   wb_io  wb_io3
     (.wb     (wbs5),
      .io_out ({LEDR[7:0], LEDG}),
      .io_in  (16'h0000));
   
   wb_intercon wb_intercon (.*);

   assign reset = ~KEY[0];
   assign clk   = CLOCK_125_p;

endmodule

`resetall
