`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2020 11:29:57 AM
// Design Name: 
// Module Name: motion
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


module mux#(WP=14)(
input [WP-1:0] a,b,c,d,e,
input [2:0] select,
output reg [WP-1:0] f);

    always@(a or b or c or d or e or select) begin
        case(select)
            3'b000 : f<= a;
            3'b001 : f<= b;
            3'b010 : f<= c;
            3'b011 : f<= d;
            3'b101 : f<= e;
            default : f<=0;
        endcase
    end

endmodule
