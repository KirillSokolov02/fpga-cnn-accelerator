`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2020 09:38:13 PM
// Design Name: 
// Module Name: weightbuffer
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


module weightbuffer#(parameter WP=14, length=10)(
input clk, start, we, rd,
input [WP-1:0]indata,
output reg [WP-1:0]data
    );
    integer i;
    reg [length-1:0]counter=0;
    reg [WP-1:0] mem [length-1:0];
    integer j;
    always @(posedge clk) begin
        for(j=0; j<3200; j=j+5) begin
            mem[j] <= 39+ indata;
            mem[j+1] <= j+indata;
            mem[j+2] <= j+indata;
            mem[j+3] <= j-2;
            mem[j+4] <= indata;
        end
        counter<= start==1? counter+1: 0; 
    //if(we)  mem[counter]<=indata;
    
    if(rd) data <= mem[counter];
 //   else data <= 0;
    end    
    
endmodule
