`timescale 1ns/1ps
// 8N1, LSB first. ready/valid handshake, one full stop bit.
module uart_byte_tx #(parameter integer DIV=5208)(
 input wire clk,rst,valid,input wire [7:0] data,
 output wire ready,output wire tx);
 reg busy;
 reg [9:0] frame;
 reg [3:0] bit_index;
 reg [31:0] ticks;
 assign ready=!busy;
 assign tx=busy ? frame[bit_index] : 1'b1;
 always @(posedge clk) begin
  if(rst) begin busy<=0; frame<=10'h3ff; bit_index<=0; ticks<=0; end
  else if(!busy) begin
   if(valid) begin busy<=1; frame<={1'b1,data,1'b0};bit_index<=0;ticks<=0;end
  end else if(ticks==DIV-1) begin
   ticks<=0;
   if(bit_index==9) busy<=0;
   else bit_index<=bit_index+1'b1;
  end else ticks<=ticks+1'b1;
 end
endmodule
