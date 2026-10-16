`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2020 09:40:49 PM
// Design Name: 
// Module Name: topmodule
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


module topmodule#(parameter WP=14, region=256, row=16, knl=9, col=16, add_bits=8)(
input clk1 ,clk2, clk3, clk4, clk5, load, we, start,
input [4:0] rst,
input [WP+add_bits-1:0]inpixel1, inpixel2, inpixel3, inpixel4, memdata1,memdata2, memdata3, memdata4, 
input [WP-1:0] weightin, 
input [7:0] weightfcl2,
input  [WP-1:0] weightFCL,
output [4*WP-1:0]FCLIN,
output [WP-1:0]finaloutput,
input makeempty,
input [4*WP-1:0] indataFCL,
input [7:0]weightfcl22, genmux,
output [7:0] reqaddress,
output [WP-1:0] softmaxout, dummyout



);
wire [3:0] flag_fcl_full, flag_fcl_empty;
wire  [WP-1:0]fclinput1, fclinput2,fclinput3,fclinput4;
wire [7:0] weightfcl;   
    RIETOP U1 (.clk1(clk1),  .rst(rst[0]), .load(load), .we(we), .start(Start), .flag_fcl_full(flag_fcl_full[0]), .flag_fcl_empty(flag_fcl_empty[0]), .inpixel(inpixel1), .memdata(memdata1), .weightin(weightin), .fclinput(fclinput1) );
    RIETOP U2 (.clk1(clk2),  .rst(rst[1]), .load(load), .we(we), .start(Start), .flag_fcl_full(flag_fcl_full[1]), .flag_fcl_empty(flag_fcl_empty[1]), .inpixel(inpixel2), .memdata(memdata2), .weightin(weightin), .fclinput(fclinput2) );
    RIETOP U3 (.clk1(clk3),  .rst(rst[2]), .load(load), .we(we), .start(Start), .flag_fcl_full(flag_fcl_full[2]), .flag_fcl_empty(flag_fcl_empty[2]), .inpixel(inpixel3), .memdata(memdata3), .weightin(weightin), .fclinput(fclinput3) );
    RIETOP U4 (.clk1(clk4),  .rst(rst[3]), .load(load), .we(we), .start(Start), .flag_fcl_full(flag_fcl_full[3]), .flag_fcl_empty(flag_fcl_empty[3]), .inpixel(inpixel4), .memdata(memdata4), .weightin(weightin), .fclinput(fclinput4) );

    macfcl U5 (.clk(clk5), .rst(rst[4]), .start(start),  .makeempty(makeempty), .indataFCL(indataFCL), .weightfcl2(weightfcl22), .genmux(genmux), .reqaddress(reqaddress), .softmaxout(softmaxout), .dummyout(dummyout));
//wire  [4*WP-1:0] FCLIN,FCLIN1 ;

wire makeemptytag;
reg tag, readwrite; 
wire [9:0]bramaddress;
wire [7:0]dataaddress, dataaddressW, dataaddressR;
always@(posedge clk3) begin
    readwrite<= flag_fcl_full[0] | flag_fcl_full[1] |  flag_fcl_full[2] |  flag_fcl_full[3];
    
end
assign dataaddress = readwrite==1?  dataaddressW: dataaddressR;
assign makeemptytag = flag_fcl_empty[0] * flag_fcl_empty[1]* flag_fcl_empty[2] * flag_fcl_empty[3];
assign FCLIN = {fclinput1, fclinput2, fclinput3,fclinput4};   
    
//    address_generator#(.add_width(10)) A4 (.clk(clk3), .rst(rst), .start(!readwrite), .address(bramaddress) ); //this changes the weights in fully connected layer
 //   address_generator#(.add_width(8), .stride(1)) A5 (.clk(clk3), .rst(rst), .start(!readwrite), .address(dataaddressW) ); //it generates address for for read and write data
    
 //   BRAM_fcl FCL (.clka(clk3), .ena(start), .wea(~start), .addra(bramaddress), .dina(weightfcl2), .douta(WghtFCL)); //this bram stores weights for Fully connected layer
 //   FCLdata Data  (.clka(clk3), .ena(1), .wea(readwrite), .addra(dataaddress), .dina(FCLIN), .douta(FCLIN1));// this bram loads data from conv layer and writes to fcl layer
 //   macfcl Last (.clk(clk3), .rst(rst), .start(readwrite), .makeempty(makeemptytag), .indataFCL(FCLIN1), .wght(WghtFCL), .reqaddress(dataaddressR), .softmaxout(finaloutput));
    
   // fifo F2(.clk(clk3), .srst(rst), .din(fclout), .wr_en(1'b1), .rd_en(1'b1), .dout(F_out), .full(ready)); 
    

    
    
endmodule
