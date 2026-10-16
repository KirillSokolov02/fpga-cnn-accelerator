module cPE# (parameter add_bits=8, W=24, X=3, Y=5, WP=14, WW=32)(
input clk, rst, start,
input [add_bits+W-1:0] inpixel,
input [add_bits+WP-1:0]memdata,
input [W-1:0] weight,
input selectinput,
output reg ready,
output reg [WP-1:0] macout);

reg[W/3-1:0] red, green, blue;
reg mac_enable, mac_enableWP;
reg [WP-1:0] data_P;
wire [add_bits-1:0] IDx, IDy;
assign IDx = inpixel[add_bits+W -1 -:add_bits/2];
assign IDy = inpixel[add_bits+W - add_bits/2 -1 -:add_bits/2];

wire[WW-1:0] mac_opR, mac_opG, mac_opB, mac_op;


mac#(.W1(W/3), .W2(W/3), .W3(WW))U0(.clk(clk), .rst(rst), .dataa(red), .datab(weight[W/3-1 -:W/3]), .dataena(mac_enable), .dataout(mac_opR));
mac#(.W1(W/3), .W2(W/3), .W3(WW))U1(.clk(clk), .rst(rst), .dataa(green), .datab(weight[W*2/3-1 -:W/3]), .dataena(mac_enable),  .dataout(mac_opG));
mac#(.W1(W/3), .W2(W/3), .W3(WW))U2(.clk(clk), .rst(rst), .dataa(blue), .datab(weight[W/1-1 -:W/3]), .dataena(mac_enable),  .dataout(mac_opB));

mac#(.W1(WP), .W2(W/3), .W3(WW))U3(.clk(clk), .rst(rst), .dataa(data_P), .datab(weight[W/3-1 -:W/3]), .dataena(mac_enable),  .dataout(mac_op));
reg [WW-1:0]temp1, temp2, temp3, temp4, temp5;


always@(posedge clk or posedge rst) begin
    temp1 <= mac_opR + mac_opG;
    temp2 <=  mac_opG + mac_opB;
    temp3 <= temp1+temp2;
    temp4 <= temp3/4;
    temp5 <= mac_op/2;
    macout<= (selectinput==0)? temp4[WP-1:0]: temp5[WP-1:0]; //14-bit precision
  if(rst) begin
    red<=0; green<=0; blue<= 0;mac_enable<=0;data_P<=0;
  end else begin
      if(IDx>=(X-1) && IDx<=(X+1) && IDy>=(Y-1) && IDy<=(Y+1)) begin
        if(selectinput==0) begin
          red<= inpixel[W/3-1 -:W/3];
          green<= inpixel[W*2/3-1 -:W/3];
          blue<= inpixel[W/1-1 -:W/3];
          mac_enable<=1;
          mac_enableWP=0;          
        end else begin
          mac_enableWP=1;
          data_P <= memdata;
          mac_enable<=0;          
        end
      end else begin
        red<=0; green<=0; blue<= 0;mac_enable<=0;mac_enableWP=0;data_P<=0;
      end
    end
  end
endmodule
