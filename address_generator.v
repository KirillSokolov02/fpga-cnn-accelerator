`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2020 11:03:19 AM
// Design Name: 
// Module Name: address_generator
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


module address_generator#(parameter add_width=8, stride=1)(
input clk, rst, start,
output [add_width-1:0] address

    );
    
    reg[add_width-1:0] counter;
    assign address= counter;
    always@ (posedge clk or posedge rst) begin
        if(rst) begin
            counter<=0;
        end else begin
            counter <= (start==1)? counter + stride: 0;
        end
              
    end
endmodule
