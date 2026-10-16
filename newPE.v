`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2020 03:15:18 PM
// Design Name: 
// Module Name: newPE
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
module newPE# (parameter address=8, X=3, Y=5, W1 =8, W2 = 8, W3 = 32, conv = 9)(
input clk, rst, start,
input [address+ W1-1:0] inpixel, 
input [W2-1:0] weights,
output reg [W3-1:0] macout);
    reg[W1-1:0] pixel;
    reg signed [W1-1:0] mycntr;
    wire[W3-1:0] mac_op;
    reg[W3*4-1:0] R1;
    wire clken, dataen;
    reg regclken, dataenR;
    assign clken= regclken | rst;
    assign dataen= dataenR;
    integer i;
   // (* keep = "true" *)reg [W1*conv-1:0] PP;
    reg [W1-1:0] PP[48:0];
    wire [address/2-1:0] IDx, IDy;
    assign IDx = X[address/2-1:0];
    assign IDy = Y[address/2-1:0];
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            dataenR<=0;
        end else begin
           if(inpixel[address+ W1-1:address] == {IDx-1,IDy-1}) 
                dataenR <=  1;
           else if(inpixel[address+ W1-1:address] == {IDx-1,IDy}) 
                dataenR <=  1;         
           else if(inpixel[address+ W1-1:address] == {IDx-1,IDy+1}) 
                dataenR <=  1;
           else if(inpixel[address+ W1-1:address] == {IDx,IDy-1}) 
                dataenR <=  1;       
           else if(inpixel[address+ W1-1:address] == {IDx,IDy}) 
                dataenR <=  1;        
           else if(inpixel[address+ W1-1:address] == {IDx,IDy+1}) 
                dataenR <=  1;
           else if(inpixel[address+ W1-1:address] == {IDx+1,IDy-1}) 
                dataenR <=  1;
           else if(inpixel[address+ W1-1:address] == {IDx+1,IDy}) 
                dataenR <=  1;    
           else if(inpixel[address+ W1-1:address] == {IDx+1,IDy+1}) 
                dataenR <=  1;



           else if(inpixel[address+ W1-1:address] == {IDx-1,IDy-2} & conv>9) 
                dataenR <=  1;         
           else if(inpixel[address+ W1-1:address] == {IDx-1,IDy+2}& conv>9) 
                dataenR <=  1;
           else if(inpixel[address+ W1-1:address] == {IDx-2,IDy-2}& conv>9) 
                dataenR <=  1;       
           else if(inpixel[address+ W1-1:address] == {IDx-2,IDy-1}& conv>9) 
                dataenR <=  1;        
           else if(inpixel[address+ W1-1:address] == {IDx-2,IDy}& conv>9) 
                dataenR <=  1;
           else if(inpixel[address+ W1-1:address] == {IDx-2,IDy+1}& conv>9) 
                dataenR <=  1;
           else if(inpixel[address+ W1-1:address] == {IDx-2,IDy+2}& conv>9) 
                dataenR <=  1;
                
                    
           else if(inpixel[address+ W1-1:address] == {IDx,IDy-2}& conv>9) 
                dataenR <=  1;
           else if(inpixel[address+ W1-1:address] == {IDx,IDy+2}& conv>9) 
                dataenR <=  1;         
           else if(inpixel[address+ W1-1:address] == {IDx+1,IDy-2}& conv>9) 
                dataenR <=  1;
           else if(inpixel[address+ W1-1:address] == {IDx+1,IDy+2}& conv>9) 
                dataenR <=  1;       
           else if(inpixel[address+ W1-1:address] == {IDx+2,IDy-2}& conv>9) 
                dataenR <=  1;        
           else if(inpixel[address+ W1-1:address] == {IDx+2,IDy-1}& conv>9) 
                dataenR <=  1;
           else if(inpixel[address+ W1-1:address] == {IDx+2,IDy}& conv>9) 
                dataenR <=  1;
           else if(inpixel[address+ W1-1:address] == {IDx+2,IDy+1}& conv>9) 
                dataenR <=  1;    
           else if(inpixel[address+ W1-1:address] == {IDx+2,IDy+2}& conv>9) 
                dataenR <=  1;                                         
           else 
                dataenR <=  0;             
        end    
    
    
    end
    
    
    
    mac#(.W1(W1), .W2(W2), .W3(W3))U0(.clk(clk), .rst(clken), .dataa(inpixel[W1-1:0]), .datab(weight), .clken(dataen), .dataout(mac_op));
    
    reg [W2*conv-1:0]weight_buffer;
    reg [W2-1:0] macweight;
    wire clk_weight;
    assign clk_weight = clk*dataenR;
    wire [W2-1:0] weight;
    assign weight = macweight;
    
    always@(posedge clk_weight) begin
        macweight <=weight_buffer[W2-1:0];
    end
    
    always@(posedge clk or posedge rst) begin
        
        if(rst) begin
            mycntr<=1;        
            weight_buffer<=0;
        end else begin
            weight_buffer[W2-1:0]<=weights;
            weight_buffer[W2*conv-1: W2]<= weight_buffer[(W2-1)*conv-1: 0];
            mycntr <= mycntr==conv-1+4? 0: mycntr+1;
            if(mycntr==(conv-1+4)) begin
                regclken<=1;
                R1[W3*4-1 :W3] <= R1[W3*3-1 :0];
                R1[W3-1 :0]<= mac_op;
                macout<= mac_op;
            end else regclken<=0;
        end   
    end
endmodule
