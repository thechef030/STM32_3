`timescale 1ns/1ps
// 50 MHz / (2*50) = 500 kHz. Start-to-start interval = CLK_HZ cycles.
// CS setup, final falling edge and CS hold each last a half SCK period.
module spi_master_tx #(
 parameter integer CLK_HZ=50_000_000,
 parameter integer HALF_CYCLES=50,
 parameter integer INTERVAL_CYCLES=CLK_HZ,
 parameter integer CYCLE_PATTERNS=1,
 parameter [7:0] FIXED_BYTE=8'h55
)(input wire clk, rst, output reg spi_sck, spi_mosi, spi_cs_n,
 output reg [7:0] last_tx, output reg done);
 localparam IDLE=0, SHIFT=1, HOLD=2;
 reg [1:0] state, pattern;
 reg [31:0] interval_count, half_count;
 reg [2:0] bit_index;
 reg [7:0] tx;
 function [7:0] pattern_byte(input [1:0] p);
  case(p) 0:pattern_byte=8'h55; 1:pattern_byte=8'hA5;
          2:pattern_byte=8'h00; default:pattern_byte=8'hFF; endcase
 endfunction
 wire [7:0] next_tx = CYCLE_PATTERNS ? pattern_byte(pattern) : FIXED_BYTE;
 always @(posedge clk) begin
  if(rst) begin
   state<=IDLE; pattern<=0; interval_count<=0; half_count<=0;
   bit_index<=7; tx<=0; last_tx<=0; done<=0;
   spi_sck<=0; spi_mosi<=0; spi_cs_n<=1;
  end else begin
   done<=0;
   if(interval_count < INTERVAL_CYCLES-1) interval_count<=interval_count+1'b1;
   case(state)
    IDLE: begin
     spi_sck<=0; spi_cs_n<=1;
     if(interval_count==INTERVAL_CYCLES-1) begin
      interval_count<=0; half_count<=0; bit_index<=7;
      tx<=next_tx; last_tx<=next_tx; spi_mosi<=next_tx[7];
      spi_cs_n<=0; state<=SHIFT;
     end
    end
    SHIFT: if(half_count==HALF_CYCLES-1) begin
     half_count<=0;
     if(!spi_sck) spi_sck<=1;
     else begin
      spi_sck<=0;
      if(bit_index==0) state<=HOLD;
      else begin bit_index<=bit_index-1'b1; spi_mosi<=tx[bit_index-1'b1]; end
     end
    end else half_count<=half_count+1'b1;
    HOLD: if(half_count==HALF_CYCLES-1) begin
     half_count<=0; spi_cs_n<=1; spi_mosi<=0;
     done<=1; pattern<=pattern+1'b1; state<=IDLE;
    end else half_count<=half_count+1'b1;
    default: state<=IDLE;
   endcase
  end
 end
endmodule
