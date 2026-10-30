`timescale 1ns/1ps
module spi_reset(input wire clk,rst_p,output wire rst);
 (* ASYNC_REG="TRUE" *) reg [1:0] sync=2'b11;
 always @(posedge clk or posedge rst_p)
  if(rst_p) sync<=2'b11; else sync<={sync[0],1'b0};
 assign rst=sync[1];
endmodule
// Task 10 and Task 12 receiver.
module spi_rx_top #(parameter integer CLK_HZ=50_000_000, BAUD=9600)(
 input wire clk_50mhz,rst_p,spi_sck,spi_mosi,spi_cs_n,
 output wire uart_txd,output wire [7:0] led);
 wire rst,valid,overflow;
 wire [7:0] data;
 spi_reset u_reset(clk_50mhz,rst_p,rst);
 spi_slave_rx u_rx(clk_50mhz,rst,spi_sck,spi_mosi,spi_cs_n,data,valid);
 spi_uart_report #(.UART_DIV((CLK_HZ+BAUD/2)/BAUD)) u_report
  (clk_50mhz,rst,data,valid,uart_txd,overflow);
 assign led=data;
endmodule
// Task 11 and Task 12 sender. Same source, separate Vivado project.
module spi_tx_top #(
 parameter integer CLK_HZ=50_000_000,
 parameter integer HALF_CYCLES=50,
 parameter integer INTERVAL_CYCLES=CLK_HZ,
 parameter integer CYCLE_PATTERNS=1,
 parameter [7:0] FIXED_BYTE=8'h55
)(input wire clk_50mhz,rst_p,
 output wire spi_sck,spi_mosi,spi_cs_n,output wire [7:0] led);
 wire rst,done;
 spi_reset u_reset(clk_50mhz,rst_p,rst);
 spi_master_tx #(.CLK_HZ(CLK_HZ),.HALF_CYCLES(HALF_CYCLES),
  .INTERVAL_CYCLES(INTERVAL_CYCLES),.CYCLE_PATTERNS(CYCLE_PATTERNS),.FIXED_BYTE(FIXED_BYTE))
  u_tx(clk_50mhz,rst,spi_sck,spi_mosi,spi_cs_n,led,done);
endmodule
