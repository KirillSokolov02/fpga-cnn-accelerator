`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2020 06:52:13 PM
// Design Name: 
// Module Name: ram
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


module ram#(parameter WP=14, address_width=8)(
input clk, rst, we, acc,
input[address_width-1:0] address,
input [WP-1:0]data,
output reg [address_width+WP-1:0]ramdata
    );
reg [WP-1:0] mem [address_width-1:0];
integer i;

always @(posedge clk ) begin
    if (rst==1) begin
    
        for(i=0; i< 2**address_width; i=i+1) begin 
            mem[i] <=0;
        end
    
    end else begin
     
        if(we==1 & acc==0)
            mem[address] <= data;
        else if(we==1 & acc==1) begin
            mem[address] <=  mem[address] + data;
        end else 
            ramdata <=  {address,mem[address]};
    end
    end
endmodule
