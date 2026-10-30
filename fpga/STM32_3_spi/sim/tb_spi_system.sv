`timescale 1ns/1ps
module tb_spi_system;
 reg clk=0;
 always #10 clk=~clk;
 reg rst=1;
 reg sck=0,mosi=0,cs=1;
 wire [7:0] data;
 wire valid;
 spi_slave_rx dut(clk,rst,sck,mosi,cs,data,valid);
 integer rx_count=0;
 reg [7:0] observed[0:1023];
 always @(posedge clk) if(valid) begin observed[rx_count]=data;rx_count=rx_count+1;end
 task send_bits(input [7:0] value,input integer n);
  integer j;
  begin
   for(j=7;j>=8-n;j=j-1) begin
    mosi=value[j]; #503; sck=1; #503; sck=0;
   end
  end
 endtask
 task frame(input [7:0] value);
  begin cs=0; #137; send_bits(value,8); #137; cs=1; #200; end
 endtask
 reg core_done=0,master_done=0,uart_done=0;
 integer i,before_count;
 initial begin
  repeat(6) @(negedge clk);rst=0;#17;
  // All byte values at an asynchronous phase (~994 kHz SCK).
  for(i=0;i<256;i=i+1) begin
   frame(i[7:0]);
   if(rx_count!=i+1 || observed[i]!==i[7:0]) $fatal(1,"RX mismatch %0d",i);
  end
  before_count=rx_count;
  cs=0;#137;send_bits(8'hE0,3);#137;cs=1;#200;
  if(rx_count!=before_count) $fatal(1,"Aborted partial frame emitted a byte");
  frame(8'hA5);
  if(observed[before_count]!==8'hA5) $fatal(1,"No recovery after CS abort");
  // Two complete bytes under one CS assertion.
  cs=0;#137;send_bits(8'h55,8);send_bits(8'hF0,8);#137;cs=1;#200;
  if(rx_count!=before_count+3 || observed[before_count+1]!==8'h55 || observed[before_count+2]!==8'hF0)
   $fatal(1,"Continuous byte receive failed");
  cs=0;#137;send_bits(8'hFF,4);rst=1;#120;cs=1;sck=0;rst=0;#200;
  frame(8'h3C);
  if(observed[before_count+3]!==8'h3C) $fatal(1,"Reset recovery failed");
  core_done=1;
  $display("PASS slave: all 256 bytes, CS abort, continuous bytes, reset recovery");
 end

 // Real 500 kHz divider; only the 1-second inter-frame interval is shortened.
 reg mrst=1;
 wire msck,mmosi,mcs,mdone;
 wire [7:0] mlast;
 spi_master_tx #(.INTERVAL_CYCLES(2000)) master(clk,mrst,msck,mmosi,mcs,mlast,mdone);
 function [7:0] pattern(input integer p);
  case(p%4) 0:pattern=8'h55;1:pattern=8'hA5;2:pattern=0;3:pattern=8'hFF;endcase
 endfunction
 integer k,j;
 reg [7:0] decoded;
 time previous_start,previous_rise,started,last_edge;
 initial begin
  repeat(7) @(negedge clk);mrst=0;
  previous_start=0;
  for(k=0;k<8;k=k+1) begin
   @(negedge mcs);started=$time;
   if(msck!==0) $fatal(1,"SCK not idle LOW at CS assertion");
   if(k>0 && started-previous_start!=40000) $fatal(1,"Incorrect frame interval");
   previous_start=started;decoded=0;
   for(j=0;j<8;j=j+1) begin
    @(posedge msck);
    if(mcs!==0) $fatal(1,"Clock while CS inactive");
    if(j==0 && $time-started!=1000) $fatal(1,"Wrong CS setup time");
    if(j>0 && $time-previous_rise!=2000) $fatal(1,"SCK is not 500 kHz");
    previous_rise=$time;decoded={decoded[6:0],mmosi};
    #500;
    if(mmosi!==decoded[0]) $fatal(1,"MOSI changed during SCK HIGH");
    @(negedge msck);
    if($time-previous_rise!=1000) $fatal(1,"SCK high width");
   end
   last_edge=$time;
   @(posedge mcs);
   if($time-last_edge!=1000) $fatal(1,"CS hold time");
   if(decoded!==pattern(k)) $fatal(1,"Master MSB-first byte incorrect");
  end
  // Reset during a transfer must return pins to idle.
  @(negedge mcs);@(posedge msck);#100;mrst=1;#40;
  if(mcs!==1 || msck!==0) $fatal(1,"Master reset did not release bus");
  master_done=1;
  $display("PASS master: 8 frames, 500kHz, 8 rising edges, MSB first, setup/hold, reset");
 end

 // Full top with real 9600-baud UART; independent serial decoder.
 reg trst=1,tsck=0,tmosi=0,tcs=1;
 wire tx;
 wire [7:0] leds;
 spi_rx_top top(clk,trst,tsck,tmosi,tcs,tx,leds);
 localparam BIT_NS=5208*20;
 integer serial_count=0;
 reg [7:0] serial[0:127];
 reg [7:0] uart_byte;
 integer bit_n;
 initial forever begin
  @(negedge tx);
  #(BIT_NS/2);
  if(tx!==0) $fatal(1,"UART start bit");
  for(bit_n=0;bit_n<8;bit_n=bit_n+1) begin #(BIT_NS);uart_byte[bit_n]=tx;end
  #(BIT_NS);
  if(tx!==1) $fatal(1,"UART stop bit");
  serial[serial_count]=uart_byte;serial_count=serial_count+1;
 end
 function [7:0] hexchar(input [3:0] n);
  hexchar=n<10 ? "0"+n : "A"+n-10;
 endfunction
 task top_send(input [7:0] v);
  integer b;
  begin
   tcs=0;#193;
   for(b=7;b>=0;b=b-1) begin tmosi=v[b];#1000;tsck=1;#1000;tsck=0;end
   #193;tcs=1;#200;
  end
 endtask
 integer q,offset;
 reg [7:0] expected;
 initial begin
  #200;trst=0;#200;
  // Send four frames faster than UART to exercise FIFO retention/order.
  for(q=0;q<4;q=q+1) top_send(pattern(q));
  wait(serial_count==28);
  for(q=0;q<4;q=q+1) begin
   offset=q*7;expected=pattern(q);
   if(serial[offset]!=="R" || serial[offset+1]!=="X" || serial[offset+2]!=="=" ||
      serial[offset+3]!==hexchar(expected[7:4]) || serial[offset+4]!==hexchar(expected[3:0]) ||
      serial[offset+5]!==8'h0D || serial[offset+6]!==8'h0A)
    $fatal(1,"UART ASCII report mismatch at frame %0d",q);
  end
  if(leds!==8'hFF || top.overflow!==0) $fatal(1,"LED or FIFO status mismatch");
  uart_done=1;
  $display("PASS receiver top: 4 queued SPI bytes -> RX=55/A5/00/FF CRLF at 9600 baud");
 end
 initial begin
  wait(core_done && master_done && uart_done);
  $display("ALL SPI TESTS PASS");$finish;
 end
 initial begin #200_000_000;$fatal(1,"Test watchdog expired");end
endmodule
