`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2020 11:13:42 AM
// Design Name: 
// Module Name: mybram
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

(*DONT_TOUCH*)
module mybram#(parameter P_bits=24, add_width=8)(
input clk,
input [add_width-1:0] address,
output [P_bits-1:0] data
    );
    
   (* keep = "true" *)  reg [P_bits-1:0]mem[add_width-1:0];
   integer k;
   always @(posedge clk) begin
       for(k=0; k<255; k=k+1) begin
             mem[k] <= k+  add_width;
       end
   end
   assign data = mem[address]; 
endmodule
