`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2019 06:15:50 PM
// Design Name: 
// Module Name: hbTest
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
module hbTest #(parameter OUTPUT_WIDTH = 16, parameter INCVAL_MULTIPLIER = 3)(input clk, input clr, input inc, input [7:0] incVal, input dec, input [7:0] decVal, output reg [OUTPUT_WIDTH - 1:0] q);
    always @(posedge clk)
    begin
        if(clr == 1'b1)
        begin
            q <= 0;
        end
        else if(inc == 1'b1)
        begin
            q <= q + {{8{incVal[7]}}, incVal[7:0]} * INCVAL_MULTIPLIER;
        end
        else if(dec == 1'b1)
        begin
            q <= q - {{8{decVal[7]}}, decVal[7:0]};
        end
        else
        begin
            q <= q;
        end
    end
endmodule
