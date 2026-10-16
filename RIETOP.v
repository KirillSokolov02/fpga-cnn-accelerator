`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2020 12:10:17 AM
// Design Name: 
// Module Name: RIETOP
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


module RIETOP#(parameter WP=14, region=256, row=16, knl=9, col=16, add_bits=8)(
input clk1, rst, load, we, start,
input [WP+add_bits-1:0]inpixel, memdata,
input [WP-1:0] weightin, 

output flag_fcl_full, flag_fcl_empty,
output  [WP-1:0]fclinput
    );
    
    wire RTS, RSS,tag_cnt0; 
    wire [WP-1:0]convout;
    wire [WP-1:0] weight1, weight2, partialdata1;
    wire [add_bits+ WP-1:0]partialdata2,memdata1;
    reg[10:0] cnt0,cnt1,cnt2,cnt3;
    (* keep="true" *)reg selectinput,  rd,tag;
    (* keep="true" *)wire clear1, clear;
    assign fclinput= convout;
    reg[3:0] select, tagcntr;
    reg[add_bits-1:0] address;
    wire acc;
    reg ramWE;
    assign partialdata2= {address,partialdata1};
    assign    clear = RTS | RSS | rst | tag_cnt0;
    assign clear1 = RTS | RSS | rst | tag_cnt0;
    always@(posedge clk1) begin

        
        cnt2<= clear==1? 0: cnt2+1;
        if(tag_cnt0==1) begin
            cnt1<=0;tag<=0;
        end else begin
            cnt1<=cnt1+1;
            tag<=(cnt0==row)? 1 : 0;
        end
        ramWE <= (cnt2> region+row*2+1+7 & cnt2> 2*region+row*2+1+7)? 1:0;
        if(cnt2>region+row*2+1+7) begin
            address<=(address<region)? address+1:0;
        end else address<=0;
        
    end
    always@ (posedge tag) begin
        if (rst==0)select<=0;
        else begin
            select <= select+1;
            
        end
    end
    wire [11:0] wghtadd1, wghtadd2;
    wire [add_bits+1:0] addressF;
    wire [add_bits+ WP-1:0]F_in, F_out;
    
    assign F_in= {addressF,convout};
    RPU RPU1(.clk(clk1), .rst(rst), .start(start), .edgethreshold(8'b00001111), .RTS(RTS), .RSS(RSS));
    
 //   weightbuffer W1(.clk(clk1),  .rd(rd), .we(we), .indata(weightin1), .data(weight1));
 //   weightbuffer W2(.clk(clk1),  .rd(rd), .we(we), .indata(weightin1), .data(weight1));
    
    address_generator#(.add_width(12)) A1 (.clk(clk1), .rst(rst), .start(1'b1),  .address(wghtadd1));
//    BRAM_W WW1 (.clka(clk1), .ena(start), .wea(~start), .addra(wghtadd1), .dina(weightin), .douta(weight1));
   
    address_generator#(.add_width(12)) A2 (.clk(clk1), .rst(rst), .start(1'b1),  .address(wghtadd2));
//    BRAM_W WW2 (.clka(clk1), .ena(start), .wea(~start), .addra(wghtadd2), .dina(weightin), .douta(weight2));
    
//    ram R1(.clk(clk1), .rst(clear),  .address(address), .we(ramWE), .acc(1'b1), .data(convout), .ramdata(memdata1)); 
    
    
    
    
    IRE1 E1 (.clk(clk1), .rst(clear), .load(load), .tag_cnt0(tag_cnt0), .inpixel(inpixel), .memdata(memdata), .select(select), .weight(weight1), .convout(partialdata1));
    IRE2 E2 (.clk(clk1), .rst(1'b1), .load(load), .memdata(partialdata2), .select(select), .weight(weight2), .convout(convout));
    
  //  address_generator#(.add_width(12)) A3 (.clk(clk1), .rst(rst), .start(1'b1),  .address(wghtadd3));
  //  fifo F1(.clk(clk1), .srst(clear1), .din(F_in), .wr_en(1'b1), .rd_en(1'b1), .dout(F_out[WP-1:0]), .full(flag_fcl_full), .empty(flag_fcl_empty));
    

endmodule
