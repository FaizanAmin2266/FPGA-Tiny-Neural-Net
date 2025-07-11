`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/13/2025 06:39:22 PM
// Design Name: 
// Module Name: perceptron4
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


// perceptron4.v
// 4-input perceptron: reads weights+inputs from inferred RAM, computes dot-product via mac4, applies threshold activation
module perceptron4 #(
    parameter BW        = 8,            // bit-width of weights and inputs
    parameter ACCW      = 16,           // accumulator width (>= 4*BW)
    parameter MEM_DEPTH = 8,            // 4 weights + 4 inputs
    parameter signed [ACCW-1:0] BIAS = 16'sd0 // added bias
)(
    input  wire                   clk,
    input  wire                   rst,    // synchronous active-high reset
    input  wire                   start,  // pulse to begin perceptron
    output reg                    out,    // activation output
    output reg                    done    // high when out is valid
);

// Inferred RAM: mem[0..3] = weights, mem[4..7] = inputs
reg signed [BW-1:0] mem [0:MEM_DEPTH-1];
initial $readmemh("perceptron4_init.mem", mem);

// Wire out each weight and input
wire signed [BW-1:0] w0 = mem[0];
wire signed [BW-1:0] w1 = mem[1];
wire signed [BW-1:0] w2 = mem[2];
wire signed [BW-1:0] w3 = mem[3];
wire signed [BW-1:0] x0 = mem[4];
wire signed [BW-1:0] x1 = mem[5];
wire signed [BW-1:0] x2 = mem[6];
wire signed [BW-1:0] x3 = mem[7];

// MAC4 instance
reg                  mac_start;
wire [2*BW+1:0]      sum;
wire                  mac_done;
mac4 #(
    .BW(BW)
) mac_inst (
    .clk   (clk),
    .rst   (rst),
    .start (mac_start),
    .x0    (x0), .x1(x1), .x2(x2), .x3(x3),
    .w0    (w0), .w1(w1), .w2(w2), .w3(w3),
    .sum   (sum),
    .done  (mac_done)
);

// FSM states
localparam IDLE   = 2'd0,
           RUNMAC = 2'd1,
           THRESH = 2'd2,
           DONE_S = 2'd3;
reg [1:0] state;

always @(posedge clk) begin
    if (rst) begin
        state     <= IDLE;
        mac_start <= 1'b0;
        out       <= 1'b0;
        done      <= 1'b0;
    end else begin
        // default deassert start
        mac_start <= 1'b0;
        case (state)
            IDLE: begin
                done <= 1'b0;
                if (start) begin
                    state     <= RUNMAC;
                    mac_start <= 1'b1;
                end
            end

            RUNMAC: begin
                if (mac_done) begin
                    state <= THRESH;
                end
            end

            THRESH: begin
                // activation: 1 if sum+BIAS >= 0, else 0
                out   <= (sum + BIAS >= 0);
                state <= DONE_S;
            end

            DONE_S: begin
                done <= 1'b1;
                if (!start)
                    state <= IDLE;
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule

