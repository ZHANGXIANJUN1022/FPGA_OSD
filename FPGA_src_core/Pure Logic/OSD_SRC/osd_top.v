module osd_top(
	input 			     clk, //fpga_clk
    input                remote_clk,
    input 				 frame_1st_pxl,
    //infrared
	input	   [7 :0]	 order,
	input   		     order_en,
    
    //input			
	input 	  [2 :0]	i_sync  ,//[vs,hs,de]
	input 	  [29:0]	i_data_0,//max 8pixel input
    input 	  [29:0]	i_data_1,
    input 	  [29:0]	i_data_2,
    input 	  [29:0]	i_data_3,
    input 	  [29:0]	i_data_4,
    input 	  [29:0]	i_data_5,
    input 	  [29:0]	i_data_6,
    input 	  [29:0]	i_data_7,
    
	//output			
	output 	  [2:0]		o_sync,
	output 	  [29:0]	o_data_0,//max 8pixel input
    output 	  [29:0]	o_data_1,
    output 	  [29:0]	o_data_2,
    output 	  [29:0]	o_data_3,
    output 	  [29:0]	o_data_4,
    output 	  [29:0]	o_data_5,
    output 	  [29:0]	o_data_6,
    output 	  [29:0]	o_data_7,

    output reg   [1:0]  LD_mode,//目前有三种  00: 普通(默认) ; 10:对比 ; 01:流水灯 
    output reg   [2:0]  LD_mode_en,//上面三个模式功能的开关,
                                    //普通模式开关:LD_mode_en[0] ,关闭功能停止LD, 开启功能开启LD; 
                                    //对比模式开关:LD_mode_en[1]  ,效果暂定; 
                                    //流水灯模块开关:LD_mode_en[2],关闭功能流水灯暂停,开启功能继续流水
	output reg          gamma_bypass,
	output reg  		SPA_bypass,//空间滤波开关
	//output              TMF_bypass,//时间滤波开关

	output reg  [3:0]   SPA_mode,//空间滤波核选择，目前两个 0000：高斯(默认)   0001：均值
	output reg  [3:0]   Data_mode //背光数据模式选择,目前有4种  0000：灰度1(默认)  0001：灰度2   0010：RGB1   0011：RGB2
);

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
(*KEEP="TRUE"*)wire [19:0]	 osd_code;
codegen codegen_inst
(
	.clk		(remote_clk), //fpga_clk

	.order 		(order 	),
	.order_en 	(order_en),

	.osd_code 	(osd_code)//command[on/off  mode  sel_line  mode1  mode2 ]
                          //          1       2       2        5      9
);                        //          18     17 16  15 14    13 - 9  8 - 0

always @(posedge clk)
begin
    if (osd_code[13:12] == 2'b00) begin
    	LD_mode <= 2'b00;
    end
    else if (osd_code[13:12] == 2'b01) begin
    	LD_mode <= 2'b10;
    end
    else if (osd_code[13:12] == 2'b10) begin
    	LD_mode <= 2'b01;
    end
    else begin
    	LD_mode <= 2'b00;
    end
end
always @(posedge clk)
begin
    LD_mode_en <= ~osd_code[11:9];
end
always @(posedge clk)
begin
    SPA_bypass <= ~osd_code[8];
end
always @(posedge clk)
begin
    SPA_mode   <= osd_code[3 : 0 ];
end
always @(posedge clk)
begin
    Data_mode  <= osd_code[7 : 4 ];
end
always @(posedge clk)
begin
    gamma_bypass  <= ~osd_code[18];
end

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
wire [21:0]  instruct_0;
wire 		 instruct_de;
wire 		 instruct_hs;
wire 		 instruct_vs;
wire [239:0] instruct_data;
instruct_demo instruct_demo_inst(
	.clk        	(clk), //fpga_clk
	.osd_code   (osd_code),//command[on/off  mode  sel_line  mode1  mode2 mode3 ]
                                //      1       2       2        5       2     8
    //.osd_code   	({1'b1,2'd0,2'd2,2'd0,3'd0,2'd0,8'h15}),                                

    .frame_1st_pxl  (frame_1st_pxl 	),
    .H_sta      	(9'd100  		),// min scale: pixel_num
    .V_sta     	 	(9'd200 		),
    .pixel_sum  	(4'd1 			),  // 1 2 4  8
	.i_de       	(i_sync[0] 		),
	.i_hs       	(i_sync[1]		),
	.i_vs       	(i_sync[2]		),
	.i_data_0   	({i_data_0,i_data_1,i_data_2,i_data_3,i_data_4,i_data_5,i_data_6,i_data_7}),//max 8pixel input
	.instruct_0 	(instruct_0     ),//[en(1bit) , address(8bit) , voffset(5bit) , hoffset(5bit), color(2bit) ]

	//output		
	.o_de 			(instruct_de 	),
	.o_hs 			(instruct_hs 	),
	.o_vs 			(instruct_vs 	),
	.o_data 		(instruct_data	)
);

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
pattern_gen_demo pattern_gen_demo_inst
(

	.frame_1st_pxl (frame_1st_pxl),
	.clk		   (clk 		 ),  
	
	//input			
	.i_de 		   (instruct_de),
	.i_hs 		   (instruct_hs),
	.i_vs 		   (instruct_vs),
	.i_data_0      (instruct_data),//max 8pixel input

	//command from codegen
	.instruct_0    (instruct_0   ),//[en(1bit) , address(8bit) , voffset(5bit) , hoffset(5bit), color(2bit) ]
    
    //.instruct_0    ({1'b1,8'd31,4'd0,4'd0,2'd3}   ),
	//output		
	.o_de 		   (o_sync[0]),
	.o_hs 		   (o_sync[1]),
	.o_vs 		   (o_sync[2]),
	.o_data        ({o_data_0,o_data_1,o_data_2,o_data_3,o_data_4,o_data_5,o_data_6,o_data_7})
	
	
);


endmodule