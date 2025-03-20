/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
//`include "top_cpu.v" 
module tt_um_sameerhegde_cpu (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
  wire rst;
  // All output pins must be assigned. If not used, assign to 0.
  //assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  wire [31:0]aluresult;
  assign uio_out = 0;
  assign uio_oe  = 8'b0000_0000;
  assign rst = ~rst_n;
  assign uo_out = aluresult[7:0];
  top_cpu #(.DATAWIDTH(32),.ADDWIDTH(7),.REGADD(5),.IMM_DATA_WIDTH(20)
	) top (.clk(clk),.rst(rst),.pmWrEn(uio_in[7]),.instructionIn(ui_in),.pmAddr(uio_in[6:0]),.aluresult(aluresult));
	
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n,aluresult[31:8], 1'b0};

endmodule
