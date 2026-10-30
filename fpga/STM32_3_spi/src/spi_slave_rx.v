`timescale 1ns/1ps
// Oversample external Mode-0 SPI with clk (50 MHz); external SCK <= 1 MHz.
// Equal-depth synchronizers keep CS/SCK/MOSI aligned. Never use a GPIO as clk.
module spi_slave_rx(input wire clk, rst,
 input wire spi_sck, spi_mosi, spi_cs_n,
 output reg [7:0] data, output reg valid);
 (* ASYNC_REG="TRUE" *) reg [1:0] sck_sync, mosi_sync, cs_sync;
 reg sck_prev;
 reg [7:0] shift;
 reg [2:0] bits;
 always @(posedge clk) begin
  if(rst) begin
   sck_sync<=0; mosi_sync<=0; cs_sync<=2'b11; sck_prev<=0;
   shift<=0; bits<=0; data<=0; valid<=0;
  end else begin
   sck_sync<={sck_sync[0],spi_sck};
   mosi_sync<={mosi_sync[0],spi_mosi};
   cs_sync<={cs_sync[0],spi_cs_n};
   sck_prev<=sck_sync[1]; valid<=0;
   if(cs_sync[1]) begin bits<=0; shift<=0; end
   else if(sck_sync[1] && !sck_prev) begin
    shift<={shift[6:0],mosi_sync[1]};
    if(bits==7) begin data<={shift[6:0],mosi_sync[1]}; valid<=1; bits<=0; end
    else bits<=bits+1'b1;
   end
  end
 end
endmodule
