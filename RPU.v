`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2020 10:50:25 AM
// Design Name: 
// Module Name: RPU
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


module RPU#(parameter r_size=256, row=16, col=16, P_BITS=24, add_width=8)(
input clk, rst, start,
//input[P_BITS-1:0] pixel,
input [7:0] edgethreshold,
output RTS, RSS
    );
wire [add_width-1:0] address;
wire[P_BITS-1:0] pixel;
wire [add_width+ 8-1:0] rgb2gray;
wire [8:0] t1,t2;
wire [9:0]t3;
wire [7:0]t4;
wire [r_size-1:0] SS, TS;
assign rgb2gray[add_width+ 8-1 -:add_width] = address;
assign t1 =   pixel[P_BITS-1 -:8] + pixel[P_BITS-1 -8 -:8];
assign t2 =   pixel[7 -:8] + pixel[P_BITS-1 -8 -:8];
assign t3 = t1+t2;
assign rgb2gray[7:0] = t3[9:2];
reg [7:0] edgepoints, motionpoints; 
wire[7:0] count;
counter#(.endcount(255), .bits(8)) C1(.clk(clk), .rst(rst), .count(count));
wire rstreg;

assign  rstreg = rst;


always@ (posedge clk or negedge rstreg) begin
    if(rstreg==0) begin    
        motionpoints<=0;edgepoints<=0; 
    end else begin
       motionpoints<=  (TS[count] == 1) ? motionpoints+1: motionpoints;
       edgepoints  <=  (SS[count] == 1) ? edgepoints+1: edgepoints;        
    end

end
assign RTS = motionpoints>5? 1:0;
assign RSS = edgepoints>5? 1:0; 


address_generator AG(.clk(clk), .rst(rst), .start(start), .address(address));    
mybram ram(.clk(clk), .address(address), .data(pixel));    

genvar i,j;   
generate
    for(j=0; j<col; j=j+1 ) begin: loop1 
        for (i=0; i<row; i=i+1) begin: loop2
            sobel#(.X(i), .Y(j)) S1(.clk(clk), .rst(rstreg), .pixelstream(rgb2gray), .SS(SS[j*(col)+i]), .TS(TS[j*(col)+i]), .threshold(edgethreshold));    
        end
    end
endgenerate    
endmodule
