`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2020 03:36:34 PM
// Design Name: 
// Module Name: fcl
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


(* dont_touch="true" *)
(* use_dsp48="yes" *)module fcl#(parameter N1= 120, WP=14)(
input clk, rst, start,
input [WP-1:0] indata,
input [WP*8-1:0] wght,
output reg [32-1:0] V1);

    (* keep = "true" *) wire [N1*32-1:0] L1;
    reg [N1*32-1:0] softmax;
    reg [7:0]count;
    reg [31:0] temp;
    always @ (posedge clk or posedge rst)begin
        if(rst) begin
            count<=0; temp <=0; softmax<=0; V1<=0;
        end else begin
            softmax<=L1;
            count<=count+1;
            if(count>120) begin
                temp<= (temp>softmax[N1*32-1 -:32])? temp :softmax[N1*32-1 -:32];
                softmax[N1*32 - 1 :0] <=  {softmax[N1*32 -32 - 1 -:0], 32'b00000000000000000000000000000000};
            end
            
            V1<= count==240?
            
        end
                
    end
    genvar node1;
     
	for(node1=0; node1<N1; node1 = node1+1) begin : loop1 
        (* keep_hierarchy = "yes" *)mac#(.W1(8), .W2(8), .W3(32)) mac( .clk(clk), .rst(rst), .clken(start), .dataout(L1[node1*32+32-1 -:32]), .dataa(indata), .datab(wght[node1*8+8-1 -:8]));          
    end
endmodule
