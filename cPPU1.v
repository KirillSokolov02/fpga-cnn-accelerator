(*DONT_TOUCH*)
module cPPU1# (parameter X=0, Y=0, add_bits=8, knl=9, WP=14, WW=32)(
input clk, rst, start,
input [add_bits+WP-1:0] inpixel,
input [WP-1:0] weight,


output [add_bits+WP-1:0] outdata,
output reg [WP-1:0] macout);

reg selectinput;
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
reg [4:0] pixel_counter;
assign multiplicant= selectinput==0? inpixel[WP-1:0]: pixelbuffer[WP-1:0];
reg rstreg;
mac#(.W1(WP), .W2(WP), .W3(WW))U0(.clk(clk), .rst(rstreg), .dataa(multiplicant), .datab(weight), .dataena(mac_enable),  .dataout(mac_op));


always@ (posedge clk) begin
    rstreg<=rst;
end




always@(posedge rstreg) begin    
temp <= mac_op/2;
temp1<=temp[WP-1]==0? temp: (~temp[WP-2:0] + 'b1) ; //14-bit precision
macout<=start==1? temp1: 0;
  if(rstreg==0) begin
    selectinput<=0;pixel_counter<=0;
    mac_enable<=0; 
    data_P<=0;
  end
end  
always@(posedge clk) begin
      selectinput<= (pixel_counter== knl)? 1:0;   
      if(IDx>=(X-1) && IDx<=(X+1) && IDy>=(Y-1) && IDy<=(Y+1) && selectinput==1) begin
          pixelbuffer[WP-1:0] <= inpixel[WP-1:0];
          pixel_counter<= pixel_counter+1;
          pixelbuffer[knl*WP-1 :WP] <=  pixelbuffer[knl*WP-1 -WP:0];
          mac_enable<=(weight==0 ||multiplicant==0) ? 0:1;          
      end else if(selectinput==0) begin
          pixelbuffer[knl*WP-1 -WP:0]<=pixelbuffer[knl*WP-1 :WP];
          pixelbuffer[knl*WP-1 -:WP]<= pixelbuffer[WP-1:0];
          mac_enable<=(weight==0 ||multiplicant==0) ? 0:1;
      end else begin
          mac_enable<=0;
      end
    end
endmodule
