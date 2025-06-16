`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/13/2025 03:20:46 PM
// Design Name: 
// Module Name: mac4
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

// This module takes in two 4-element vectors and produces the dot product
module mac4 #(
    parameter BW = 8  // bit width of vector elements
)(
    input wire clk,    // clock
    input wire rst,     // reset
    input wire start,    // start pulse
    input wire [BW-1:0] x0,x1,x2,x3,    // the four vals of first vector
    input wire [BW-1:0] w0,w1,w2,w3,    // four vals of second vector
    output reg [2*BW+1:0] sum,          // final result
    output reg done                     // done signal
    );
    
    
localparam IDLE = 3'd0,
           S0   = 3'd1,
           S1   = 3'd2,
           S2   = 3'd3,
           S3   = 3'd4,
           S4   = 3'd5,
           DONE = 3'd6;
reg [2:0] state;

reg mult_start;
reg [BW-1:0] mult_a, mult_b;
wire [2*BW-1:0] prod;   // product from multiplier module
wire mul_done;           // done from multiplier module

reg [2*BW+1:0] acc_reg;   // running sum
            

multiplier #(
    .BW(BW)
) mul_inst (
    .clk    (clk),
    .rst    (rst),
    .start  (mult_start),
    .a      (mult_a),
    .b      (mult_b),
    .product(prod),
    .done   (mul_done)
);

// FSM to sequence through x0*w0 + ... + x3*w3
always @(posedge clk) begin
    if (rst) begin             // On reset, clear everything
        state       <= IDLE;
        acc_reg     <= 0;
        sum         <= 0;
        done        <= 1'b0;
        mult_start  <= 1'b0;
        mult_a      <= 0;
        mult_b      <= 0;
    end else begin
        mult_start <= 1'b0;
        case (state)
            IDLE: begin   // Idle state
                done <= 1'b0;
                if (start) begin    // if start signal recieved
                    acc_reg <= 0;      // reset acc
                    state   <= S0;     // set state to S0 to start multiplication
                end
            end

            S0: begin        // mulitply x0 and w0
                mult_a     <= x0;     // load x0 into mult module
                mult_b     <= w0;      // load w0 into mult module
                mult_start <= 1'b1;     // start multiplication
                state      <= S1;       // increase state
            end

            S1: begin
                if (mul_done) begin  // when s0 finishes
                    acc_reg   <= prod;      // add it to running sum
                    mult_a     <= x1;
                    mult_b     <= w1;
                    mult_start <= 1'b1;     // multiply x1 and w1
                    state      <= S2;
                end
            end

            S2: begin
                if (mul_done) begin     // when s1 finishes
                    acc_reg   <= acc_reg + prod;       // add it to running sum
                    // next multiply x2*w2
                    mult_a     <= x2;
                    mult_b     <= w2;
                    mult_start <= 1'b1;      // multiply x2 and w2
                    state      <= S3; 
                end
            end

            S3: begin
                if (mul_done) begin
                    acc_reg   <= acc_reg + prod;
                    mult_a     <= x3;
                    mult_b     <= w3;
                    mult_start <= 1'b1;
                    state      <= S4;
                end
            end

            S4: begin
                if (mul_done) begin
                    acc_reg <= acc_reg + prod;
                    state   <= DONE;      // all nums multiplied, move to done
                end
            end

            DONE: begin
                sum  <= acc_reg;   // put final val in sum 
                done <= 1'b1;       // raise done 
                if (!start) begin
                    state <= IDLE;
                end
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule
