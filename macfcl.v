`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2020 01:42:27 AM
// Design Name: 
// Module Name: fcl1
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
(* use_dsp48="yes" *)module macfcl#(parameter N1= 200, WP=14 , units=1200)(
input  clk, rst, start, makeempty,
input [4*WP-1:0] indataFCL,
input [7:0]weightfcl2, genmux,
output reg [7:0] reqaddress,
output reg [WP-1:0] softmaxout, dummyout
);

(* keep = "true" *) wire [N1*WP-1:0] L1, L2;
reg [units*WP-1:0] Dout, V1;
reg[WP-1:0] indata; 
wire [WP-1:0] pixel;

reg [14:0] counter;

wire weightaddress, dataaddress;
wire [2047:0] wght;



always@(genmux, L1) begin
    dummyout <= L1[WP*genmux +WP-1 -:WP];
end    


//blk_mem_gen_0 U1 (.clka(clk), .ena(start), .wea(~start), .addra(reqaddress), .dina(weightfcl2), .douta(wght)); //this bram stores weights for Fully connected layer   
   
    reg[2:0] select;
    reg[3:0] unitcounter;
    reg[WP-1:0] Y1, X1, temp;
    always @(posedge clk) begin
        if(rst==0) begin
            counter<=0; unitcounter<=0;reqaddress<=0;
        end else begin        
            if(makeempty ==1) 
                counter <= counter +1;
            else counter <= 0;
            unitcounter<= unitcounter+1;
            V1[unitcounter*WP*N1-1 -:WP*N1] <= L1;
        end
        if(counter/16==0 & counter<160) begin
            select <= select==3?0 : select+1;
            reqaddress<= reqaddress+1;
        end else select <= 3'b101;
        if(counter>200 && counter <4000) begin
            if(counter==201) Dout <= V1;
            Dout[units*WP-1 :WP]<= Dout[units*WP-1 -WP :0];
            Dout[units*WP-1 :WP]<= Dout[units*WP-1 -:WP];
            Y1<=  Dout[units*WP-1 -:WP];
        end
 //       if(counter==4000 & counter <4000+units) begin
 //          X1<= V1[WP*(counter-3999)-1 -:WP] ;
 //          
 //          if(temp < X1)
 //              temp <= X1;
 //          else temp <= temp;
 //       if(counter==4000+units-2) softmaxout<=  temp;
 //      end   
    end
    
    
    genvar node1;
        mux mux(.a(indataFCL[WP-1:0]), .b(indataFCL[2* WP-1 -:WP]), .c(indataFCL[3* WP-1 -:WP]), .d(indataFCL[4* WP-1 -:WP]), .e(Y1), .f(pixel), .select(select)); 
        for(node1=0; node1<N1-1; node1 = node1+1) begin : loop1
                
            (* keep_hierarchy = "yes" *)mac#(.W1(WP), .W2(8), .W3(WP)) mac1( .clk(clk), .rst(rst), .dataena(start), .dataout(L1[node1*WP+WP-1 -:WP]), .dataa(pixel), .datab(wght[node1*8+8*1-1 -:8])); 
            
            
//            (* keep_hierarchy = "yes" *)mac#(.W1(WP), .W2(8), .W3(WP)) mac2( .clk(clk), .rst(rst), .dataena(start), .dataout(L1[node1*WP+WP-1 -:WP]), .dataa(indataFCL[2*WP-1 -:1*WP]), .datab(wght[node1*8+8*2-1 -:8]));
 //           (* keep_hierarchy = "yes" *)mac#(.W1(WP), .W2(8), .W3(WP)) mac3( .clk(clk), .rst(rst), .dataena(start), .dataout(L1[node1*WP+WP-1 -:WP]), .dataa(indataFCL[3*WP-1 -:2*WP]), .datab(wght[node1*8+8*3-1 -:8]));
 //           (* keep_hierarchy = "yes" *)mac#(.W1(WP), .W2(8), .W3(WP)) mac4( .clk(clk), .rst(rst), .dataena(start), .dataout(L1[node1*WP+WP-1 -:WP]), .dataa(indataFCL[4*WP-1 -:3*WP]), .datab(wght[node1*8+8*4-1 -:8]));
    //        (* keep_hierarchy = "yes" *)motion#(.WP(WP)) add1 (.a(L1[node1*WP+WP-1 -:WP]), .b(V1[node1*WP+WP-1 -:WP]), .c(L2[node1*WP+WP-1 -:WP]));         
        end
    
    
    
endmodule