`timescale 1ns / 1ps
(*DONT_TOUCH*)
module sobel #(parameter X=0, Y=0, add_bits=8)(
input clk, rst, 
input [add_bits+7:0] pixelstream,
input [7:0] threshold, 
output reg TS, SS);
reg signed [9:0] t1,t2,t3,t4,t5,t6,t7,t8,t9, t10, Gx, Gy;
reg [8:0] modGx, modGy;
wire[add_bits/2-1:0] IDx, IDy;
assign IDx =  pixelstream[add_bits+7-:4];
assign IDy =  pixelstream[add_bits+7 -4-:4];

reg [7:0] p1,p2,p3,p4,p5,p6,p7,p8,p9;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            p1<=0;p2<=0;p3<=0;p4<=0;p5<=0;p6<=0;p7<=0;p8<=0;p9<=0;
        end else begin
            if(IDx==(X-1) && IDy==(Y-1))   
                p1<= pixelstream[7:0];
            if(IDx==(X) && IDy==(Y-1))   
                p2<= pixelstream[7:0];                       
            if(IDx==(X+1) && IDy==(Y-1))   
                p3<= pixelstream[7:0];                            
            if(IDx==(X-1) && IDy==(Y))   
                p4<= pixelstream[7:0];      
            if(IDx==(X) && IDy==(Y))   
                p5<= pixelstream[7:0];
            if(IDx==(X+1) && IDy==(Y))   
                p6<= pixelstream[7:0];                       
            if(IDx==(X-1) && IDy==(Y+1))   
                p7<= pixelstream[7:0];                            
            if(IDx==(X) && IDy==(Y+1))   
                p8<= pixelstream[7:0];             
            if(IDx==(X+1) && IDy==(Y+1))   
                p9<= pixelstream[7:0];
        end        
    end
    
    reg[7:0] mytemp;
    always @(posedge clk) begin
        if(mytemp == p5) 
            TS <= 1;
        else begin
            TS <=0;
            mytemp <= p5;
        end
        
        SS<= (modGx+modGy> threshold)? 0:1;                               
    end
    
    
    

    always @(posedge clk or posedge rst) begin
        if(rst) begin

            t1<=0;t2<=0;t3<=0;t4<=0;t5<=0;t6<=0;t7<=0;t8<=0;t9<=0;t10<=0;
        end else begin
            t1 <= p1 - p3;
            t2 <= p4 - p6;
            t3 <= p7 - p9;
            t4 <= t1 + t2;
            t5 <= t2 + t3;
            Gx <= t4 + t5;
            t6 <= p1 - p7;
            t7 <= p2 - p8;
            t8 <= p3 - p9;
            t9 <= t6 + t7;
            t10<= t7 + t8;
            Gy <= t9 + t10;
            modGx <= Gx[9]==1?(~Gx+1) :Gx;
            modGy <= Gy[9]==1?(~Gy+1) :Gy;                       
        end    
    end
endmodule