`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2025 07:33:19 PM
// Design Name: 
// Module Name: mvu
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


// multiplier.v
module multiplier #(
    parameter BW = 8                // bit-width of inputs
)(
    input  wire               clk,    // clock
    input  wire               rst,      // synchronous reset, active high
    input  wire               start,    // pulse to start
    input  wire [BW-1:0]      a,        // First number A
    input  wire [BW-1:0]      b,        // Second Number B
    output reg  [2*BW-1:0]    product,  // result (2*BW bits)
    output reg                done      // high when product is valid
);

reg busy;

always @(posedge clk) begin
    if (rst) begin      // On reset, set product = 0, not busy, and lower done
        product <= 0;
        done    <= 1'b0;
        busy    <= 1'b0;
    end else begin
        if (start && !busy) begin
            product <= a * b;   // multiplies both numbers
            busy    <= 1'b1;    // sets busy and done
            done    <= 1'b1;
        end else if (!start) begin
            busy <= 1'b0;  // clear when start released
            done <= 1'b0;
        end
    end
end

endmodule







