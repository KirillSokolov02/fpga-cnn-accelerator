(*DONT_TOUCH*)
module cPPU0# (parameter X=0, Y=0, add_bits=8, knl=9, WP=14, WW=32)(
input clk, rst, start,
input [add_bits+WP-1:0] inpixel,
input [WP-1:0] weight,
input selectinput,
output reg ready,
output [add_bits+WP-1:0] outdata,
output reg [WP-1:0] macout);


reg mac_enable, mac_enableWP;
reg [WP-1:0] data_P;
reg signed [WP-1:0] temp, temp1;
reg [knl*WP-1:0] pixelbuffer;

wire [add_bits-1:0] IDx, IDy;
assign IDx = inpixel[add_bits+WP -1 -:add_bits/2];
assign IDy = inpixel[add_bits+WP - add_bits/2 -1 -:add_bits/2];
assign outdata =  inpixel;
wire signed [WW-1:0] mac_op;
wire [WP-1:0] multiplicant;
assign multiplicant= selectinput==0? inpixel[WP-1:0]: pixelbuffer[WP-1:0];

mac#(.W1(WP), .W2(WP), .W3(WW))U0(.clk(clk), .rst(rst), .dataa(multiplicant), .datab(weight), .dataena(mac_enable),  .dataout(mac_op));

wire donesignal;
assign donesignal = clk*mac_enable;
reg[3:0] count;
always@(posedge donesignal or posedge rst) begin
if(rst)
    count<=0;
else count<=count+1;

end


always@(posedge clk or posedge rst) begin
    ready<= (count>=knl)? 1:0;
    temp <= mac_op/2;
    temp1<=temp[WP-1]==0? temp: (~temp[WP-2:0] + 'b1) ; //14-bit precision
    macout<=start==1? temp1: 0;
  if(rst) begin
    mac_enable<=0;data_P<=0;
  end else begin
      if(IDx>=(X-1) && IDx<=(X+1) && IDy>=(Y-1) && IDy<=(Y+1) && selectinput==0) begin
          pixelbuffer[WP-1:0] <= inpixel[WP-1:0];
          pixelbuffer[knl*WP-1 :WP] <=  pixelbuffer[knl*WP-1 -WP:0];
          mac_enable<=(weight==0 ||multiplicant==0) ? 0:1;          
      end else if(selectinput==1) begin
          pixelbuffer[knl*WP-1 -WP:0]<=pixelbuffer[knl*WP-1 :WP];
          pixelbuffer[knl*WP-1 -:WP]<= pixelbuffer[WP-1:0];
          mac_enable<=(weight==0 ||multiplicant==0) ? 0:1;
      end else begin
          mac_enable<=0;
      end
    end
  end
endmodule
