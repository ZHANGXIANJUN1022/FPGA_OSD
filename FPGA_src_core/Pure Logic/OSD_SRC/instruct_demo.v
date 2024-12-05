
////////////////////////////////////////////////////////////////////////////////
// Company : KonKA
// Engineer: Zhangxianjun
//
// Create Date: 24/10/30                         
// Design Name: OSD     
// Module Name: pattern_gen_demo          
// Target Device: 10AX115N3F40E2SG             
// Tool versions: quartus 21.4              
// Description:   This model is used to generate the UI order                         
//
// Dependencies:                              
// Revision:                                  
// Additional Comments:
//      


////////////////////////////////////////////////////////////////////////////////

module instruct_demo(
	input 			    clk, //fpga_clk
	input 		[19:0]	osd_code,//command[on/off  mode  sel_line  mode1  mode2]
                                    //      1       2       2        5       9

    input 				frame_1st_pxl,
    input		[8:0]	H_sta,// min scale: pixel_num
    input 		[8:0]	V_sta,
    input       [3:0]	pixel_sum, // 1 2 4  8
	input 				i_de,
    input               i_hs,
    input               i_vs,
	input 		[239:0]	i_data_0,//max 8pixel input

	output 		[21:0]	instruct_0,//[en(1bit) , address(8bit) , voffset(5bit) , hoffset(5bit), color(3bit) ]

	//output	
    output      reg         o_hs,
    output      reg         o_vs,
	output	 	reg     	o_de,
	output		reg [239:0]	o_data
);
////////////////////////////////////////////////
////////////////////////////////////////////////
reg i_de_d1;
reg i_de_d2;
reg i_de_d3;
reg i_hs_d1;
reg i_hs_d2;
reg i_hs_d3;
reg i_vs_d1;
reg i_vs_d2;
reg i_vs_d3;
reg [239:0] i_data_0_d1;
reg [239:0] i_data_0_d2;
reg [239:0] i_data_0_d3;
reg V_sta_flag_d1;
reg H_sta_flag_d1;

wire [4 :0]OFFSET = (pixel_sum == 4'd1)?5'd31 :(
					(pixel_sum == 4'd2)?5'd15 :(
					(pixel_sum == 4'd4)?5'd7  :(
					(pixel_sum == 4'd8)?5'd3  :5'd0)));

wire [11:0]H_EDGE = (pixel_sum == 4'd1)?12'd1279 :(
					(pixel_sum == 4'd2)?12'd639  :(
					(pixel_sum == 4'd4)?12'd319  :(
					(pixel_sum == 4'd8)?12'd159  :12'd0)));

wire [11:0]OSD_Word_H_de =(pixel_sum == 4'd1)?12'd448 :(
						  (pixel_sum == 4'd2)?12'd224 :(
						  (pixel_sum == 4'd4)?12'd112 :(
						  (pixel_sum == 4'd8)?12'd56  :4'd0)));//14


wire [11:0]OSD_Word_V_hs = 12'd224;//32*7
wire [11:0]OSD_H_edge = OSD_Word_H_de + H_sta;
wire [11:0]OSD_V_edge = OSD_Word_V_hs + V_sta;
////////////////////////////////////////////////
////////////////////////////////////////////////
//
/* mif store address
0:  <  
1:  >  
2:  0 
3:  1 
4:  2 
5:  3 
6:  4 
7:  5 
8:  6 
9:  7 
10:  8 
11:  9
12:  o  
13:  ** 
14:  模 
15:  式 
16:  普 
17:  通  
18:  对 
19:  比 
20:  流 
21:  水 
22:  线 
23:  块 
24:  开 
25:  关 
26:  空 
27:  间 
28:  时  
29:  滤 
30:  波  
31:  设  
32:  置 
33:  灯  
34:  gou
35： 效
36： 果
37: 背
38: 光
39: 数
40: 据
41: 高
42: 斯
43: 均
44: 值
45: 灰
46: 度
47: R
48: G
49: B
50：M
51： A
*/
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
wire 	  SW 		=	 osd_code[19   ];//菜单开关
wire      gamma_sw  =    osd_code[18   ];//gamma开关
wire [1:0]mode  	=    osd_code[17:16];//菜单页面
wire [1:0]sel_line  =    osd_code[15:14];//行数选择
wire [4:0]LD_mod    = 	 osd_code[13: 9];//显示模式,3种,及其各自的功能开关   [4:3] mode select  [2:0]mode_1~mode_2 on/off
wire 	  LD_SW     = 	 osd_code[8    ];//LD 空间滤波开关 (shijian kongjian)  
wire [3:0]LD_blight = 	 osd_code[7 :4 ];//背光模式选择   
wire [3:0]LD_SP     = 	 osd_code[3 :0 ];//空间滤波模式选择   

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
reg en;
reg [7:0]address;
reg [4:0]v_off;
reg [4:0]h_off;
reg color_SEL;
reg [1:0]color_HL;
//reg [1:0]color;
//color[1] = select or not for blank
//color[0] = hight light or not for no blank

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
reg [11:0]Pixel_H;
reg [11:0]Pixel_V;

reg [4 :0]H_lane_cnt;
reg [8 :0]V_lane_cnt;
reg [3 :0]Word_H;// word,  offset
wire[3 :0]Word_V;// word,  offset
//d1
always @(posedge clk) begin
	if (frame_1st_pxl) begin
		Pixel_H <= 12'd0;
	end
	else if (Pixel_H == H_EDGE) begin
		Pixel_H <= 12'd0;
	end
	else if (i_de == 1'd1) begin
		Pixel_H <= Pixel_H + 12'd1;
	end
end
always @(posedge clk) begin
	if (frame_1st_pxl) begin
		Pixel_V <= 12'd0;
	end
	else if (Pixel_H == H_EDGE) begin
		Pixel_V <= Pixel_V + 12'd1 ;
	end
end

//
reg V_sta_flag;
reg H_sta_flag;
always @(posedge clk) begin
	if (Pixel_V >= V_sta && Pixel_V < OSD_V_edge) begin
		V_sta_flag <= 1'b1;
	end
	else begin
		V_sta_flag <= 1'b0;
	end
end

always @(posedge clk) begin
	if (Pixel_H >= H_sta && Pixel_H < OSD_H_edge) begin
		H_sta_flag <= 1'b1;
	end
	else begin
		H_sta_flag <= 1'b0;
	end
end

//wire      V_sta_flag = (Pixel_V > V_sta && Pixel_V <= OSD_V_edge) ? 1'b1 : 1'd0;
//wire      H_sta_flag = (Pixel_H > H_sta && Pixel_H <= OSD_H_edge) ? 1'b1 : 1'd0;

wire      V_cnt_en;
assign V_cnt_en = V_sta_flag_d1 && !V_sta_flag;
wire      H_cnt_en;
assign H_cnt_en = H_sta_flag_d1 && !H_sta_flag;
//d2
always @(posedge clk) begin
	if (frame_1st_pxl) begin
		H_lane_cnt <= 5'd0;
	end
	else if (H_cnt_en && i_de_d1) begin
        H_lane_cnt <= 5'd0;
    end
    else if (H_lane_cnt == OFFSET && i_de_d1) begin
		H_lane_cnt <= 5'd0;
	end
	else if (V_sta_flag && H_sta_flag && i_de_d1)begin
		H_lane_cnt <= H_lane_cnt + 5'd1 ;
	end
end
always @(posedge clk) begin
	if (frame_1st_pxl) begin
		Word_H <= 4'd0;
	end
    else if (H_cnt_en && i_de_d1) begin
        Word_H <= 4'd0;
    end
	else if (i_de_d1 && H_lane_cnt == OFFSET && H_sta_flag && V_sta_flag)begin
		Word_H <= Word_H + 4'd1 ;
	end
end
always @(posedge clk) begin
	if (frame_1st_pxl) begin
		V_lane_cnt <= 5'd0;
	end
	else if (Word_V == 4'd0 && V_lane_cnt[4:0] == 5'd15 && H_cnt_en) begin
		V_lane_cnt[8:5] <= V_lane_cnt[8:5] + 4'd1 ;
		V_lane_cnt[4:0] <= 5'd0;
	end
    else if (Word_V == 4'd2 && V_lane_cnt[4:0] == 5'd15 && H_cnt_en) begin
		V_lane_cnt[8:5] <= V_lane_cnt[8:5] + 4'd1 ;
		V_lane_cnt[4:0] <= 5'd0;
	end
    else if (Word_V == 4'd3 && V_lane_cnt[4:0] == 5'd15 && H_cnt_en) begin
		V_lane_cnt[8:5] <= V_lane_cnt[8:5] + 4'd1 ;
		V_lane_cnt[4:0] <= 5'd0;
	end
	else if (Word_V == 4'd5 && V_lane_cnt[4:0] == 5'd15 && H_cnt_en) begin
		V_lane_cnt[8:5] <= V_lane_cnt[8:5] + 4'd1 ;
		V_lane_cnt[4:0] <= 5'd0;
	end
	else if (Word_V == 4'd7 && V_lane_cnt[4:0] == 5'd15 && H_cnt_en) begin
		V_lane_cnt[8:5] <= V_lane_cnt[8:5] + 4'd1 ;
		V_lane_cnt[4:0] <= 5'd0;
	end
	else if (Word_V == 4'd9 && V_lane_cnt[4:0] == 5'd15 && H_cnt_en) begin
		V_lane_cnt[8:5] <= V_lane_cnt[8:5] + 4'd1 ;
		V_lane_cnt[4:0] <= 5'd0;
	end
	else if (V_lane_cnt[4:0] == 5'd31 && H_cnt_en) begin
		V_lane_cnt[8:5] <= V_lane_cnt[8:5] + 4'd1 ;
		V_lane_cnt[4:0] <= 5'd0;
	end
	else if (H_cnt_en && V_sta_flag && i_de_d1)begin
		V_lane_cnt[4:0] <= V_lane_cnt[4:0] + 5'd1 ;
	end
end
assign  Word_V = V_lane_cnt[8:5];

//always @(posedge clk) begin
//	if (frame_1st_pxl) begin
//		Word_V <= 4'd0;
//	end
//	else if (V_lane_cnt == 5'd31 && H_cnt_en && i_de_d1) begin
//		Word_V <= Word_V + 4'd1;
//	end
//end

//d3
/////////////////////////////////////
/////////////////////////////////////
/////////////////////////////////////
always @(posedge clk) begin
	if (V_sta_flag_d1 && H_sta_flag_d1 && i_de_d2) begin
		en <= SW;
	end
	else begin
		en <= 1'd0;
	end
	
end
/////////////////////////////////////
/////////////////////////////////////
/////////////////////////////////////
always @(posedge clk) begin
	if (Word_V == 4'd0 || Word_V == 4'd2 || Word_V == 4'd3|| Word_V == 4'd5 || Word_V == 4'd7 || Word_V == 4'd9 || Word_H == 4'd0 || Word_H == 4'd13) begin
		address <= 8'd13;
	end
//////////////////////////////////////////////////////////word 1	
	else if (Word_V == 4'd1 && Word_H == 4'd1) begin
		address <= 8'd0;
	end
	else if (Word_V == 4'd1 && Word_H == 4'd12) begin
		address <= 8'd1;
	end
	else if (Word_V == 4'd1 && Word_H == 4'd2) begin
		case(mode)
			2'd0:begin
				address <= 8'd13;//[]
			end
			2'd1:begin
				address <= 8'd35;//效
			end
			//2'd2:begin
			//	address <= 8'd29;//lv
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd1 && Word_H == 4'd5) begin
		case(mode)
			2'd0:begin
				address <= 8'd14;//模
			end
			2'd1:begin
				address <= 8'd36;//果
			end
			//2'd2:begin
			//	address <= 8'd30;//bo
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd1 && Word_H == 4'd8) begin
		case(mode)
			2'd0:begin
				address <= 8'd15;//式
			end
			2'd1:begin
				address <= 8'd31;//设
			end
			//2'd2:begin
			//	address <= 8'd31;//she
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd1 && Word_H == 4'd11) begin
		case(mode)
			2'd0:begin
				address <= 8'd13;//[]
			end
			2'd1:begin
				address <= 8'd32;//置
			end
			//2'd2:begin
			//	address <= 8'd32;//zhi
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
////////////////////////////////////////////////////////////word 4
	else if (Word_V == 4'd4 && Word_H == 4'd1) begin
		case(mode)
			2'd0:begin
				address <= 8'd13;//[]
			end
			2'd1:begin
				address <= 8'd37;//背
			end
			//2'd2:begin
			//	address <= 8'd26;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd4 && Word_H == 4'd2) begin
		case(mode)
			2'd0:begin
				address <= 8'd16;//普
			end
			2'd1:begin
				address <= 8'd38;//光
			end
			//2'd2:begin
			//	address <= 8'd27;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd4 && Word_H == 4'd3) begin
		case(mode)
			2'd0:begin
				address <= 8'd17;//通
			end
			2'd1:begin
				address <= 8'd39;//数
			end
			//2'd2:begin
			//	address <= 8'd13;//[]
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd4 && Word_H == 4'd4) begin
		case(mode)
			2'd0:begin
				address <= 8'd13;//[]
			end
			2'd1:begin
				address <= 8'd40;//据
			end
			//2'd2:begin
			//	address <= 8'd0;//<
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd4 && Word_H == 4'd5) begin
		case(mode)
			2'd0:begin
				address <= 8'd14;//模
			end
			2'd1:begin
				address <= 8'd14;//模
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd4 && Word_H == 4'd6) begin
		case(mode)
			2'd0:begin
				address <= 8'd15;//式
			end
			2'd1:begin
				address <= 8'd15;//式
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd4 && Word_H == 4'd7) begin
		case(mode)
			2'd1:begin
				address <= 8'd0;//<
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd4 && Word_H == 4'd8) begin
		case(mode)
			2'd1:begin
				if (LD_blight == 4'd0 || LD_blight == 4'd1) begin
					address <= 8'd45;//灰
				end
				else if(LD_blight == 4'd2 || LD_blight == 4'd3) begin
					address <= 8'd47;//R
				end
				else begin
					address <= 8'd13;
				end
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd4 && Word_H == 4'd9) begin
		case(mode)
			2'd1:begin
				if (LD_blight == 4'd0 || LD_blight == 4'd1) begin
					address <= 8'd46;//度
				end
				else if(LD_blight == 4'd2 || LD_blight == 4'd3) begin
					address <= 8'd48;//G
				end
				else begin
					address <= 8'd13;
				end
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd4 && Word_H == 4'd10) begin
		case(mode)
			2'd1:begin
				if (LD_blight == 4'd0 || LD_blight == 4'd1) begin
					address <= 8'd13;//[]
				end
				else if(LD_blight == 4'd2 || LD_blight == 4'd3) begin
					address <= 8'd49;//B
				end
				else begin
					address <= 8'd13;
				end
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd4 && Word_H == 4'd11) begin
		case(mode)
			2'd0:begin
				if (LD_mod[4:3] == 2'd0) begin
					address <= 8'd12;//o
				end
				else begin
					address <= 8'd13;
				end
			end
			2'd1:begin
				if (LD_blight == 4'd0 || LD_blight == 4'd1) begin
					address <= LD_blight + 8'd3;//1 2 
				end
				else if(LD_blight == 4'd2 || LD_blight == 4'd3) begin
					address <= LD_blight + 8'd1;//1 2
				end
				else begin
					address <= 8'd13;
				end
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd4 && Word_H == 4'd12) begin
		case(mode)
			2'd1:begin
				address <= 8'd1;//>
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
////////////////////////////////////////////////////////////////////////word 6
	else if (Word_V == 4'd6 && Word_H == 4'd1) begin
		case(mode)
			2'd0:begin
				address <= 8'd13;//[]
			end
			2'd1:begin
				address <= 8'd26;//空
			end
			//2'd2:begin
			//	address <= 8'd26;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd6 && Word_H == 4'd2) begin
		case(mode)
			2'd0:begin
				address <= 8'd18;//对
			end
			2'd1:begin
				address <= 8'd27;//间
			end
			//2'd2:begin
			//	address <= 8'd27;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd6 && Word_H == 4'd3) begin
		case(mode)
			2'd0:begin
				address <= 8'd19;//比
			end
			2'd1:begin
				address <= 8'd29;//滤
			end
			//2'd2:begin
			//	address <= 8'd13;//[]
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd6 && Word_H == 4'd4) begin
		case(mode)
			2'd0:begin
				address <= 8'd13;//[]
			end
			2'd1:begin
				address <= 8'd30;//波
			end
			//2'd2:begin
			//	address <= 8'd0;//<
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd6 && Word_H == 4'd5) begin
		case(mode)
			2'd0:begin
				address <= 8'd14;//模
			end
			2'd1:begin
				address <= 8'd14;//模
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd6 && Word_H == 4'd6) begin
		case(mode)
			2'd0:begin
				address <= 8'd15;//式
			end
			2'd1:begin
				address <= 8'd15;//式
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd6 && Word_H == 4'd7) begin
		case(mode)
			2'd1:begin
				address <= 8'd0;//<
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd6 && Word_H == 4'd8) begin
		case(mode)
			2'd1:begin
				if (LD_SW == 1'b1) begin
					address <= 8'd13;
				end
				else if (LD_SP == 4'd0) begin
					address <= 8'd41;//高
				end
				else if(LD_SP == 4'd1) begin
					address <= 8'd43;//均
				end
				else begin
					address <= 8'd13;
				end
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd6 && Word_H == 4'd9) begin
		case(mode)
			2'd1:begin
				if (LD_SW == 1'b1) begin
					address <= 8'd13;
				end
				else if (LD_SP == 4'd0) begin
					address <= 8'd42;//斯
				end
				else if(LD_SP == 4'd1) begin
					address <= 8'd44;//值
				end
				else begin
					address <= 8'd13;
				end
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd6 && Word_H == 4'd10) begin
		case(mode)
			2'd1:begin
				if (LD_SW == 1'b1) begin
					address <= 8'd25;//关
				end
				else if (LD_SP == 4'd0) begin
					address <= 8'd14;//模
				end
				else if(LD_SP == 4'd1) begin
					address <= 8'd14;//模
				end
				else begin
					address <= 8'd13;
				end
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd6 && Word_H == 4'd11) begin
		case(mode)
			2'd0:begin
				if (LD_mod[4:3] == 2'd1) begin
					address <= 8'd12;//o
				end
				else begin
					address <= 8'd13;
				end
			end
			2'd1:begin
				if (LD_SW == 1'b1) begin
					address <= 8'd13;//[]
				end
				else if (LD_SP == 4'd0) begin
					address <= 8'd15;//式
				end
				else if(LD_SP == 4'd1) begin
					address <= 8'd15;//式
				end
				else begin
					address <= 8'd13;
				end
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd6 && Word_H == 4'd12) begin
		case(mode)
			2'd1:begin
				address <= 8'd1;//>
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
//////////////////////////////////////////////////////////////////////////////word 8
	else if (Word_V == 4'd8 && Word_H == 4'd1) begin
		case(mode)
			2'd1:begin
				address <= 8'd48;//G
			end
			//2'd2:begin
			//	address <= 8'd26;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd8 && Word_H == 4'd2) begin
		case(mode)
			2'd0:begin
				address <= 8'd20;//liu
			end
			2'd1:begin
				address <= 8'd51;//A
			end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd8 && Word_H == 4'd3) begin
		case(mode)
			2'd0:begin
				address <= 8'd21;//shui
			end
			2'd1:begin
				address <= 8'd50;//M
			end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd8 && Word_H == 4'd4) begin
		case(mode)
			2'd0:begin
				address <= 8'd33;//deng
			end
			2'd1:begin
				address <= 8'd50;//M
			end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd8 && Word_H == 4'd5) begin
		case(mode)
			2'd0:begin
				address <= 8'd14;//mo
			end
			2'd1:begin
				address <= 8'd51;//A
			end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd8 && Word_H == 4'd6) begin
		case(mode)
			2'd0:begin
				address <= 8'd15;//shi
			end
			2'd1:begin
				address <= 8'd13;//[]
			end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd8 && Word_H == 4'd7) begin
		case(mode)
			2'd1:begin
				address <= 8'd0;//<
			end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd8 && Word_H == 4'd10) begin
		case(mode)
			2'd1:begin
				if (gamma_sw == 1'b1) begin
					address <= 8'd25;//关
				end
				else begin
					address <= 8'd24;//开
				end
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd8 && Word_H == 4'd11) begin
		case(mode)
			2'd0:begin
				if (LD_mod[4:3] == 2'd2) begin
					address <= 8'd12;//o
				end
				else begin
					address <= 8'd13;
				end
			end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else if (Word_V == 4'd8 && Word_H == 4'd12) begin
		case(mode)
			2'd1:begin
				address <= 8'd1;//>
			end
			//2'd2:begin
			//	address <= LD_SP + 4'd2;
			//end
			default:begin
				address <= 8'd13;
			end
		endcase
	end
	else begin
		address <= 8'd13;
	end
end
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
always @(posedge clk) begin
	if (Word_V == 4'd1) begin
		if(sel_line == 2'd0)
		begin
			color_SEL <= 1'b1;
		end
		else begin
			color_SEL <= 1'b0;
		end
	end
	else if (Word_V == 4'd4) begin
		if(sel_line == 2'd1)
		begin
			color_SEL <= 1'b1;
		end
		else begin
			color_SEL <= 1'b0;
		end
	end
	else if (Word_V == 4'd6) begin
		if(sel_line == 2'd2)
		begin
			color_SEL <= 1'b1;
		end
		else begin
			color_SEL <= 1'b0;
		end
	end
	else if (Word_V == 4'd8) begin
		if(sel_line == 2'd3)
		begin
			color_SEL <= 1'b1;
		end
		else begin
			color_SEL <= 1'b0;
		end
	end
	else begin
		color_SEL <= 1'b0;
	end
end


always @(posedge clk) begin
	if (mode == 2'd0) begin
        if (Word_V == 4'd0 || Word_V == 4'd1 || Word_V == 4'd2) begin
            color_HL <= 2'b10;
        end
		else if (Word_V == 4'd4 && Word_H == 4'd11) begin
			color_HL <= {1'b0,~LD_mod[0]};
		end
		else if (Word_V == 4'd6 && Word_H == 4'd11) begin
			color_HL <= {1'b0,~LD_mod[1]};
		end
		else if (Word_V == 4'd8 && Word_H == 4'd11) begin
			color_HL <= {1'b0,~LD_mod[2]};
		end
		else begin
			color_HL <= 2'b0;
		end
	end
	else if (mode == 2'd1) begin
        if (Word_V == 4'd0 || Word_V == 4'd1  || Word_V == 4'd2) begin
            color_HL <= 2'b10;
        end
		else if ( (Word_V == 4'd4||Word_V == 4'd6||Word_V == 4'd8)  && (Word_H >= 4'd8 && Word_H <= 4'd11) ) begin
			color_HL <= 2'b01;
		end
		else begin
			color_HL <= 2'b00;
		end
	end
	else begin
		color_HL <= 2'b00;
	end
end
/*
	if (Word_V == 4'd3 && Word_H == 4'd6) begin
		if (mode == 2'd0) begin
			color_HL <= LD_mod[0];
		end
		else if (mode == 2'd1) begin
			color_HL <= LD_SW[0];
		end
		else begin
			color_HL <= 1'b0;
		end
	end
	else if (Word_V == 4'd5 && Word_H == 4'd6) begin
		if (mode == 2'd0) begin
			color_HL <= LD_mod[1];
		end
		else if (mode == 2'd1) begin
			color_HL <= LD_SW[1];
		end
		else begin
			color_HL <= 1'b0;
		end
	end
	else if (Word_V == 4'd7 && Word_H == 4'd6) begin
		if (mode == 2'd0) begin
			color_HL <= LD_mod[2];
		end
		else begin
			color_HL <= 1'b0;
		end
	end
    else if (Word_V == 4'd3 && Word_H == 4'd5) begin
		if (mode == 2'd2) begin
			color_HL <= 1'b1;
		end
		else begin
			color_HL <= 1'b0;
		end
	end
	else if (Word_V == 4'd5 && Word_H == 4'd5) begin
		if (mode == 2'd2) begin
			color_HL <= 1'b1;
		end
		else begin
			color_HL <= 1'b0;
		end
	end
	else begin
		color_HL <= 1'b0;
	end
end*/
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
always @(posedge clk) begin
	v_off <= V_lane_cnt[4:0];
end
always @(posedge clk) begin
	if (pixel_sum == 4'd1) begin
		h_off <= H_lane_cnt;	
	end
	else if (pixel_sum == 4'd2) begin
		h_off <= H_lane_cnt<<1;
	end
	else if (pixel_sum == 4'd4) begin
		h_off <= H_lane_cnt<<2;
	end
	else if (pixel_sum == 4'd8) begin
		h_off <= H_lane_cnt<<3;
	end
	else begin
		h_off <= H_lane_cnt;
	end
end
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
assign instruct_0 = {en,address,v_off,h_off,color_SEL,color_HL};

always @(posedge clk) begin
	i_de_d1 <= i_de;//d1
	i_de_d2 <= i_de_d1;//d2
    i_de_d3 <= i_de_d2;
	o_de    <= i_de_d2;//d3
    
    i_vs_d1 <= i_vs;//d1
	i_vs_d2 <= i_vs_d1;//d2
    i_vs_d3 <= i_vs_d2;//d2
	o_vs    <= i_vs_d2;//d3
    
    i_hs_d1 <= i_hs;//d1
	i_hs_d2 <= i_hs_d1;//d2
    i_hs_d3 <= i_hs_d2;//d2
	o_hs    <= i_hs_d2;//d3

	i_data_0_d1 <= i_data_0;
	i_data_0_d2 <= i_data_0_d1;
    i_data_0_d3 <= i_data_0_d2;
	o_data      <= i_data_0_d2;

    V_sta_flag_d1 <= V_sta_flag;//d2
    H_sta_flag_d1 <= H_sta_flag;//d2
end
endmodule