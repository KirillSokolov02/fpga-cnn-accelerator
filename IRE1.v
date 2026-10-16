`timescale 1ns / 1ps
(*DONT_TOUCH*)
module IRE1#(parameter WP=14, row=16, region=256, col=16, add_bits=8)(
input clk, rst, load,  //switchingwire determines when PPU array does computation from the input of from the pixelbuffer
input [WP+add_bits-1:0]inpixel, memdata,
input [3:0] select, 
input [WP-1:0] weight,//select input determines when input data or data from memory
output reg tag_cnt0,
output reg [WP-1:0]convout
    );
reg selectinput;    
wire [WP+add_bits-1:0] data;
assign data = selectinput==0? inpixel: memdata;
genvar i0,i1,j1,ii;
wire [col*(WP+add_bits)-1:0] t0;
wire [col*row*(WP+add_bits)-1:0] t1;
wire [col*row*WP-1:0] s1;
wire [col*WP-1:0] mt0;
wire start[col-1:0];
//reg [add_bits-1:0] adress_generate;
reg tag;
reg[10:0] cnt0;

    always@(posedge clk) begin
        if(load==1)
            cnt0<= (cnt0<region)? cnt0+1:0;
        tag_cnt0<=cnt0==region ? 1:0;     
        selectinput <= ((load==1)&& cnt0<region)? 1:0;
    end
//always@(posedge tag or posedge rst) begin
//    if (rst)
//        adress_generate <=0;
//    else adress_generate <=adress_generate+1;
//end


always @(s1 or select) begin
        tag <= (select==4'b1111)? 1:0;
    case (select)
        4'b0000 :convout <= s1[col*WP* 1-1 -:WP]; 
        4'b0001 :convout <= s1[col*WP* 2-1 -:WP]; 
        4'b0010 :convout <= s1[col*WP* 3-1 -:WP];
        4'b0011 :convout <= s1[col*WP* 4-1 -:WP];
        4'b0100 :convout <= s1[col*WP* 5-1 -:WP];
        4'b0101 :convout <= s1[col*WP* 6-1 -:WP];
        4'b0110 :convout <= s1[col*WP* 7-1 -:WP];
        4'b0111 :convout <= s1[col*WP* 8-1 -:WP];
        4'b1000 :convout <= s1[col*WP* 9-1 -:WP];
        4'b1001 :convout <= s1[col*WP*10-1 -:WP];
        4'b1010 :convout <= s1[col*WP*11-1 -:WP];
        4'b1011 :convout <= s1[col*WP*12-1 -:WP];
        4'b1100 :convout <= s1[col*WP*13-1 -:WP];
        4'b1101 :convout <= s1[col*WP*14-1 -:WP];
        4'b1110 :convout <= s1[col*WP*15-1 -:WP];
        4'b1111 :convout <= s1[col*WP*16-1 -:WP];    
    endcase
end

//    ram#(.WP(14), .address_width(8)) R1(.clk(clk), .rst(rst), .we(ready), .data(convout));
//    weightbuffer#(.WP(14), .length(10)) W1(.clk(clk), .start(1'b1), .data(weight));
generate
    for(ii=1; ii<=col; ii=ii+1) begin: loop
        assign t1[(WP+add_bits)+(row*(WP+add_bits)*(ii-1))-1-:WP+add_bits]=t0[(WP+add_bits)*ii-1-:(WP+add_bits)];
        assign s1[WP*row*(ii-1) + WP -1 -:WP] = mt0[ii*WP-1 -:WP];
    end

//    cPPU0# (.X(0), .Y(0)) U0(.clk(clk), .rst(rst), .start(start[0]), .selectinput(switchingwire), .ready(ready), .inpixel(data), .weight(weight),
//               .outdata(t0[(0+1)*(WP+add_bits)-1 -:WP+add_bits]), .macout(mt0[(0+1)*WP-1 -:WP])); 

    for(i0=0; i0<col; i0=i0+1) begin :L0
        cPPU1# (.X(0), .Y(i0)) U0(.clk(clk), .rst(rst), .start(start[i0]),  .inpixel(data), .weight(weight),
               .outdata(t0[(i0+1)*(WP+add_bits)-1 -:WP+add_bits]), .macout(mt0[(i0+1)*WP-1 -:WP])); 
    end
    for(j1=0; j1<col; j1=j1+1) begin :L2
        for(i1=1; i1<row; i1=i1+1) begin :L1        
            cPPU# (.X(i1), .Y(j1)) U1 (.clk(clk), .rst(rst), .start(start[j1]),   .weight(weight), 
            .inpixel(t1[j1*(row+0)*(WP+add_bits)+ i1*(WP+add_bits)-1 -:WP+add_bits]), .outdata(t1[j1*(row+0)*(WP+add_bits)+(i1+1)*(WP+add_bits)-1 -:WP+add_bits]),
            .rcvmacout(s1[j1*(row+0)*WP + i1*WP -1 -:WP]), .macout(s1[j1*(row+0)*WP + (i1+1)*WP-1 -:WP]));        
        end
    end
    

endgenerate
endmodule
