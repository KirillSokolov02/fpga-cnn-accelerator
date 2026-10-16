`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/28/2020 09:26:47 PM
// Design Name:
// Module Name: mac
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
module mac#(parameter W1=8, W2=8, W3=32)(dataout, dataa, datab, clk, rst, dataena); //main module
input [W1-1:0] dataa;
input [W2-1:0] datab;
input clk, rst, dataena;
output reg [W3-1:0] dataout;


reg [W1-1:0] dataa_reg;
reg [W2-1:0] datab_reg;
reg [31:0] multa_reg;
wire [31:0] multa;
wire [31:0] adder_out;
assign multa = dataa_reg * datab_reg;
assign adder_out = multa_reg + dataout;
//assign data_out = dataout;

always @ (posedge clk or posedge rst)begin
    if (rst==1)begin
        dataa_reg <= 0;
        datab_reg <= 0;
        multa_reg <= 0;
        dataout <=   0;
    end else begin
        if(dataena) begin
            dataa_reg <= dataa;
            datab_reg <= datab;
        end else begin
            dataa_reg <= 0;
            datab_reg <= 0;
        end
        multa_reg <= multa;
        dataout <= adder_out;
    end
end
endmodule
