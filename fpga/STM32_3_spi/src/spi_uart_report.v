`timescale 1ns/1ps
// Queue received SPI bytes; each prints seven ASCII characters: RX=55\r\n.
// A 16-byte FIFO absorbs bursts; sustained SPI > UART rate can overflow.
module spi_uart_report #(parameter integer UART_DIV=5208)(
 input wire clk,rst,input wire [7:0] data,input wire valid,
 output wire uart_tx, output reg overflow);
 reg [7:0] fifo[0:15];
 reg [3:0] wr,rd;
 reg [4:0] count;
 reg active;
 reg [2:0] pos;
 reg [7:0] current;
 wire pop=!active && count!=0;
 wire push=valid && (count<16 || pop);
 wire ready;
 reg [7:0] character;
 function [7:0] hex_ascii(input [3:0] nibble);
  hex_ascii = nibble<10 ? 8'h30+nibble : 8'h41+(nibble-10);
 endfunction
 always @* begin
  case(pos)
   0:character="R";1:character="X";2:character="=";
   3:character=hex_ascii(current[7:4]);4:character=hex_ascii(current[3:0]);
   5:character=8'h0d;default:character=8'h0a;
  endcase
 end
 uart_byte_tx #(.DIV(UART_DIV)) u_uart(clk,rst,active,character,ready,uart_tx);
 always @(posedge clk) begin
  if(rst) begin wr<=0;rd<=0;count<=0;active<=0;pos<=0;current<=0;overflow<=0;end
  else begin
   if(valid && !push) overflow<=1;
   if(push) begin fifo[wr]<=data;wr<=wr+1'b1;end
   if(pop) begin current<=fifo[rd];rd<=rd+1'b1;active<=1;pos<=0;end
   else if(active && ready) begin
    if(pos==6) begin active<=0;pos<=0;end
    else pos<=pos+1'b1;
   end
   case({push,pop}) 2'b10:count<=count+1'b1;2'b01:count<=count-1'b1;default:;endcase
  end
 end
endmodule
