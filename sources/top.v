`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/13/2025 08:46:22 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input wire CLK100MHZ,
    input wire BTN0,
    input wire BTN1,
    output wire LED0,
    output wire LED1
    );
    
    wire btn0 = ~BTN0;
    wire btn1 = ~BTN1;
    wire rst = ~BTN1;
    
    reg [2:0] btn_sync;
    reg start_pulse, prev;
    always @(posedge CLK100MHZ) begin
        btn_sync <= {btn_sync[1:0], btn0};
        start_pulse <= btn_sync[2] & ~prev;
        prev <= btn_sync[2];
    end
    wire out, done;
    perceptron4 #(.BW(8), .ACCW(16), .BIAS(-16'sd50)) dut (
        .clk (CLK100MHZ),
        .rst (rst),
        .start (start_pulse),
        .out (out),
        .done (done)
    );
    reg done_latched;
  always @(posedge CLK100MHZ) begin
    if (rst)
      done_latched <= 1'b0;
    else if (done)
      done_latched <= 1'b1;
    else if (start_pulse)
      done_latched <= 1'b0;
  end

    
    assign LED0 = out;
    assign LED1 = done_latched;
endmodule
