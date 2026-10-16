`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2020 01:19:03 PM
// Design Name: 
// Module Name: counter
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


module counter#(parameter endcount= 256, bits=8)(

input clk, rst, 
output reg [bits-1:0] count

    );
    always@(posedge clk or posedge rst) begin
        if(rst) count <=0;
        else 
        count <= (count>=endcount)? 0: count+1;       
    end
    
endmodule
