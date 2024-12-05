////////////////////////////////////////////////////////////////////////////////
// Company : KonKA
// Engineer: Zhangxianjun
//
// Create Date: 24/10/30                         
// Design Name: OSD     
// Module Name: pattern_gen_demo          
// Target Device: 10AX115N3F40E2SG             
// Tool versions: quartus 21.4              
// Description:   This model is used to generate the UI according to the ram                             
//
// Dependencies:                              
// Revision:                                  
// Additional Comments: back color : gray   
////////////////////////////////////////////////////////////////////////////////

module pattern_gen_demo 
(

	input 					frame_1st_pxl,//global_resetn
	input 					clk, 
	
	//input			
	input 					i_de,
	input 					i_hs,
	input 					i_vs,
	input 			[239:0]	i_data_0,//max 8pixel input

	//command from codegen
	input 			[21:0]	instruct_0,//[en(1bit) , address(8bit) , voffset(5bit) , hoffset(5bit), color(3bit) ]

	//output		
	output	reg				o_de,
	output	reg				o_hs,
	output	reg				o_vs,
	output	reg		[239:0]	o_data
	
	
);
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//back color  dec = 800;
localparam BACK_R = 10'h100;
localparam BACK_G = 10'h100;
localparam BACK_B = 10'h100;
localparam BACK_R_H = 10'h00F;
localparam BACK_G_H = 10'h00F;
localparam BACK_B_H = 10'h00F;
localparam SELE_R = 10'h000;
localparam SELE_G = 10'h000;
localparam SELE_B = 10'h300;
localparam FRONT_R = 10'h3FF;
localparam FRONT_G = 10'h3FF;
localparam FRONT_B = 10'h3FF;
localparam HLIGHT_R = 10'h3ff;
localparam HLIGHT_G = 10'h000;
localparam HLIGHT_B = 10'h000;
//color[1] = select or not for blank
//color[0] = hight light or not for no blank


//data input
wire [9:0]i_data_0r = i_data_0[239:230];
wire [9:0]i_data_0g = i_data_0[229:220];
wire [9:0]i_data_0b = i_data_0[219:210];
wire [9:0]i_data_1r = i_data_0[209:200];
wire [9:0]i_data_1g = i_data_0[199:190];
wire [9:0]i_data_1b = i_data_0[189:180];
wire [9:0]i_data_2r = i_data_0[179:170];
wire [9:0]i_data_2g = i_data_0[169:160];
wire [9:0]i_data_2b = i_data_0[159:150];
wire [9:0]i_data_3r = i_data_0[149:140];
wire [9:0]i_data_3g = i_data_0[139:130];
wire [9:0]i_data_3b = i_data_0[129:120];
wire [9:0]i_data_4r = i_data_0[119:110];
wire [9:0]i_data_4g = i_data_0[109:100];
wire [9:0]i_data_4b = i_data_0[99 :90 ];
wire [9:0]i_data_5r = i_data_0[89 :80 ];
wire [9:0]i_data_5g = i_data_0[79 :70 ];
wire [9:0]i_data_5b = i_data_0[69 :60 ];
wire [9:0]i_data_6r = i_data_0[59 :50 ];
wire [9:0]i_data_6g = i_data_0[49 :40 ];
wire [9:0]i_data_6b = i_data_0[39 :30 ];
wire [9:0]i_data_7r = i_data_0[29 :20 ];
wire [9:0]i_data_7g = i_data_0[19 :10 ];
wire [9:0]i_data_7b = i_data_0[9  :0  ];

//command input
wire osd_en = instruct_0[21];
wire [12:0]osd_add = {instruct_0[20:13],5'b00000};
wire [4 :0]osd_v_offset = instruct_0[12:8];
wire [4 :0]osd_h_offset = instruct_0[7 :3];
wire [2:0]	   osd_color    = instruct_0[2:0];

//delay
reg [9:0]i_data_0r_d1;  reg [9:0]i_data_0r_d2;  reg [9:0]i_data_0r_d3;  reg [9:0]i_data_0r_d4;  reg [9:0]i_data_0r_d5;  reg [9:0]i_data_0r_d6;  
reg [9:0]i_data_0g_d1;  reg [9:0]i_data_0g_d2;  reg [9:0]i_data_0g_d3;  reg [9:0]i_data_0g_d4;  reg [9:0]i_data_0g_d5;  reg [9:0]i_data_0g_d6;
reg [9:0]i_data_0b_d1;  reg [9:0]i_data_0b_d2;  reg [9:0]i_data_0b_d3;  reg [9:0]i_data_0b_d4;  reg [9:0]i_data_0b_d5;  reg [9:0]i_data_0b_d6;
reg [9:0]i_data_1r_d1;  reg [9:0]i_data_1r_d2;  reg [9:0]i_data_1r_d3;  reg [9:0]i_data_1r_d4;  reg [9:0]i_data_1r_d5;  reg [9:0]i_data_1r_d6;
reg [9:0]i_data_1g_d1;  reg [9:0]i_data_1g_d2;  reg [9:0]i_data_1g_d3;  reg [9:0]i_data_1g_d4;  reg [9:0]i_data_1g_d5;  reg [9:0]i_data_1g_d6;
reg [9:0]i_data_1b_d1;  reg [9:0]i_data_1b_d2;  reg [9:0]i_data_1b_d3;  reg [9:0]i_data_1b_d4;  reg [9:0]i_data_1b_d5;  reg [9:0]i_data_1b_d6;
reg [9:0]i_data_2r_d1;  reg [9:0]i_data_2r_d2;  reg [9:0]i_data_2r_d3;  reg [9:0]i_data_2r_d4;  reg [9:0]i_data_2r_d5;  reg [9:0]i_data_2r_d6;
reg [9:0]i_data_2g_d1;  reg [9:0]i_data_2g_d2;  reg [9:0]i_data_2g_d3;  reg [9:0]i_data_2g_d4;  reg [9:0]i_data_2g_d5;  reg [9:0]i_data_2g_d6;
reg [9:0]i_data_2b_d1;  reg [9:0]i_data_2b_d2;  reg [9:0]i_data_2b_d3;  reg [9:0]i_data_2b_d4;  reg [9:0]i_data_2b_d5;  reg [9:0]i_data_2b_d6;
reg [9:0]i_data_3r_d1;  reg [9:0]i_data_3r_d2;  reg [9:0]i_data_3r_d3;  reg [9:0]i_data_3r_d4;  reg [9:0]i_data_3r_d5;  reg [9:0]i_data_3r_d6;
reg [9:0]i_data_3g_d1;  reg [9:0]i_data_3g_d2;  reg [9:0]i_data_3g_d3;  reg [9:0]i_data_3g_d4;  reg [9:0]i_data_3g_d5;  reg [9:0]i_data_3g_d6;
reg [9:0]i_data_3b_d1;  reg [9:0]i_data_3b_d2;  reg [9:0]i_data_3b_d3;  reg [9:0]i_data_3b_d4;  reg [9:0]i_data_3b_d5;  reg [9:0]i_data_3b_d6;
reg [9:0]i_data_4r_d1;  reg [9:0]i_data_4r_d2;  reg [9:0]i_data_4r_d3;  reg [9:0]i_data_4r_d4;  reg [9:0]i_data_4r_d5;  reg [9:0]i_data_4r_d6;
reg [9:0]i_data_4g_d1;  reg [9:0]i_data_4g_d2;  reg [9:0]i_data_4g_d3;  reg [9:0]i_data_4g_d4;  reg [9:0]i_data_4g_d5;  reg [9:0]i_data_4g_d6;
reg [9:0]i_data_4b_d1;  reg [9:0]i_data_4b_d2;  reg [9:0]i_data_4b_d3;  reg [9:0]i_data_4b_d4;  reg [9:0]i_data_4b_d5;  reg [9:0]i_data_4b_d6;
reg [9:0]i_data_5r_d1;  reg [9:0]i_data_5r_d2;  reg [9:0]i_data_5r_d3;  reg [9:0]i_data_5r_d4;  reg [9:0]i_data_5r_d5;  reg [9:0]i_data_5r_d6;
reg [9:0]i_data_5g_d1;  reg [9:0]i_data_5g_d2;  reg [9:0]i_data_5g_d3;  reg [9:0]i_data_5g_d4;  reg [9:0]i_data_5g_d5;  reg [9:0]i_data_5g_d6;
reg [9:0]i_data_5b_d1;  reg [9:0]i_data_5b_d2;  reg [9:0]i_data_5b_d3;  reg [9:0]i_data_5b_d4;  reg [9:0]i_data_5b_d5;  reg [9:0]i_data_5b_d6;
reg [9:0]i_data_6r_d1;  reg [9:0]i_data_6r_d2;  reg [9:0]i_data_6r_d3;  reg [9:0]i_data_6r_d4;  reg [9:0]i_data_6r_d5;  reg [9:0]i_data_6r_d6;
reg [9:0]i_data_6g_d1;  reg [9:0]i_data_6g_d2;  reg [9:0]i_data_6g_d3;  reg [9:0]i_data_6g_d4;  reg [9:0]i_data_6g_d5;  reg [9:0]i_data_6g_d6;
reg [9:0]i_data_6b_d1;  reg [9:0]i_data_6b_d2;  reg [9:0]i_data_6b_d3;  reg [9:0]i_data_6b_d4;  reg [9:0]i_data_6b_d5;  reg [9:0]i_data_6b_d6;
reg [9:0]i_data_7r_d1;  reg [9:0]i_data_7r_d2;  reg [9:0]i_data_7r_d3;  reg [9:0]i_data_7r_d4;  reg [9:0]i_data_7r_d5;  reg [9:0]i_data_7r_d6;
reg [9:0]i_data_7g_d1;  reg [9:0]i_data_7g_d2;  reg [9:0]i_data_7g_d3;  reg [9:0]i_data_7g_d4;  reg [9:0]i_data_7g_d5;  reg [9:0]i_data_7g_d6;
reg [9:0]i_data_7b_d1;  reg [9:0]i_data_7b_d2;  reg [9:0]i_data_7b_d3;  reg [9:0]i_data_7b_d4;  reg [9:0]i_data_7b_d5;  reg [9:0]i_data_7b_d6;

reg de_d1; reg de_d2; reg de_d3; reg de_d4; reg de_d5; reg de_d6;
reg hs_d1; reg hs_d2; reg hs_d3; reg hs_d4; reg hs_d5; reg hs_d6;
reg vs_d1; reg vs_d2; reg vs_d3; reg vs_d4; reg vs_d5; reg vs_d6;
reg osd_en_d1; reg osd_en_d2; reg osd_en_d3; reg osd_en_d4; reg osd_en_d5; reg osd_en_d6;
reg [2:0]osd_color_d1; reg [2:0]osd_color_d2; reg [2:0]osd_color_d3; reg [2:0]osd_color_d4; reg [2:0]osd_color_d5;
reg [4:0]osd_h_offset_d1; reg [4:0]osd_h_offset_d2; reg [4:0]osd_h_offset_d3;

///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////DELYA 3
//get the unicode data delay three clock
reg [12:0]unicode_addr;//max 256 unicode characters store
wire[31:0]unicode_data;

unicode_rom unicode_rom_i(

    .clk        (clk),
    .oce        (1'b1),
    .ce         (1'b1),
    .reset      (1'b0),
    .ad         (unicode_addr[10:0]),
    .dout       (unicode_data)
);

//address
always @(posedge clk) begin
	unicode_addr = osd_add + osd_v_offset;
end
//////////////////////////////////////////////////////////////////////delay 1
reg [7:0] usr_data;
reg  [31:0]usr_data_tmp;

always @(posedge clk)
begin
	usr_data_tmp <= unicode_data << osd_h_offset_d3;
	usr_data 	 <= usr_data_tmp[31:24];
end

//////////////////////////////////////////////////////////////////////delay 1
//data0
reg [9:0]o_data_0r_1;
reg [9:0]o_data_0r_2;
reg [9:0]o_data_0r_3;
reg [9:0]o_data_0r_4;
reg [9:0]o_data_0r_5;
reg [9:0]o_data_0g_1;
reg [9:0]o_data_0g_2;
reg [9:0]o_data_0g_3;
reg [9:0]o_data_0g_4;
reg [9:0]o_data_0g_5;
reg [9:0]o_data_0b_1;
reg [9:0]o_data_0b_2;
reg [9:0]o_data_0b_3;
reg [9:0]o_data_0b_4;
reg [9:0]o_data_0b_5;

always@(posedge clk)
begin

	o_data_0r_1 <= {10{osd_color_d4[0]}} & HLIGHT_R;
	o_data_0r_2 <= {10{!osd_color_d4[0]}} & FRONT_R;

    o_data_0g_1 <= {10{osd_color_d4[0]}} & HLIGHT_G;
	o_data_0g_2 <= {10{!osd_color_d4[0]}} & FRONT_G;
    
    o_data_0b_1 <= {10{osd_color_d4[0]}} & HLIGHT_B;
	o_data_0b_2 <= {10{!osd_color_d4[0]}} & FRONT_B;

    if(osd_color_d4[2])begin
        o_data_0r_3 <= 10'd0;
        o_data_0r_4 <= 10'd0;
        o_data_0r_5 <= SELE_R;
    
        
        o_data_0g_3 <= 10'd0;
        o_data_0g_4 <= 10'd0;
        o_data_0g_5 <= SELE_G;

        o_data_0b_3 <= 10'd0;
        o_data_0b_4 <= 10'd0;
        o_data_0b_5 <= SELE_B;     
    end
    else begin
        o_data_0r_3 <= {10{!osd_color_d4[1]}} & (i_data_0r_d4>>2);
        o_data_0r_4 <= {10{!osd_color_d4[1]}} & BACK_R + {10{osd_color_d4[1]}} & BACK_R_H;
        o_data_0r_5 <= 10'd0;
    
        
        o_data_0g_3 <= {10{!osd_color_d4[1]}} & (i_data_0g_d4>>2);
        o_data_0g_4 <= {10{!osd_color_d4[1]}} & BACK_G + {10{osd_color_d4[1]}} & BACK_G_H;;
        o_data_0g_5 <= 10'd0;

        o_data_0b_3 <= {10{!osd_color_d4[1]}} & (i_data_0b_d4>>2);
        o_data_0b_4 <= {10{!osd_color_d4[1]}} & BACK_B + {10{osd_color_d4[1]}} & BACK_B_H;;
        o_data_0b_5 <= 10'd0;
    end
    //o_data_0r <= (i_data_0r_d4>>2); 
	//o_data_0g <= (i_data_0g_d4>>2); 
	//o_data_0b <= (i_data_0b_d4>>2); 
end
//////////////////////////////////////////////////////////////////////delay 1
//data0
reg [9:0]o_data_0r;
reg [9:0]o_data_0g;
reg [9:0]o_data_0b;
always@(posedge clk)
begin
	if (usr_data[7]) begin
		o_data_0r <= o_data_0r_1 + o_data_0r_2;
		o_data_0g <= o_data_0g_1 + o_data_0g_2;
		o_data_0b <= o_data_0b_1 + o_data_0b_2;
	end
	else begin
		o_data_0r <= o_data_0r_3 + o_data_0r_4  + o_data_0r_5; 
		o_data_0g <= o_data_0g_3 + o_data_0g_4  + o_data_0g_5; 
		o_data_0b <= o_data_0b_3 + o_data_0b_4  + o_data_0b_5; 
	end
    //o_data_0r <= (i_data_0r_d4>>2); 
	//o_data_0g <= (i_data_0g_d4>>2); 
	//o_data_0b <= (i_data_0b_d4>>2); 
end
//////////////////////////////////////////////////////////////////////delay 1
always@(posedge clk)
begin
	if (osd_en_d6) begin
    //if (1'b1) begin
		o_data <= {o_data_0r,o_data_0g,o_data_0b,
				   30'd0,
				   30'd0,
				   30'd0,
				   30'd0,
				   30'd0,
				   30'd0,
				   30'd0
				  };
	end
	else begin
		o_data <= {i_data_0r_d6,i_data_0g_d6,i_data_0b_d6,
				   i_data_1r_d6,i_data_1g_d6,i_data_1b_d6,
				   i_data_2r_d6,i_data_2g_d6,i_data_2b_d6,
				   i_data_3r_d6,i_data_3g_d6,i_data_3b_d6,
				   i_data_4r_d6,i_data_4g_d6,i_data_4b_d6,
				   i_data_5r_d6,i_data_5g_d6,i_data_5b_d6,
				   i_data_6r_d6,i_data_6g_d6,i_data_6b_d6,
				   i_data_7r_d6,i_data_7g_d6,i_data_7b_d6
				  };
	end
end

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////// 
//delay 
always @(posedge clk) begin
	de_d1 <= i_de;
	de_d2 <= de_d1;
	de_d3 <= de_d2;//get the unicode data
	de_d4 <= de_d3;//prepare
	de_d5 <= de_d4;//generate
	de_d6 <= de_d5;
	o_de  <= de_d6;//output


	hs_d1 <= i_hs;
	hs_d2 <= hs_d1;
	hs_d3 <= hs_d2;//get the unicode data
	hs_d4 <= hs_d3;//prepare
	hs_d5 <= hs_d4;//generate
	hs_d6 <= hs_d5;
	o_hs  <= hs_d6;//output


	vs_d1 <= i_vs;
	vs_d2 <= vs_d1;
	vs_d3 <= vs_d2;//get the unicode data
	vs_d4 <= vs_d3;//prepare
	vs_d5 <= vs_d4;//generate
	vs_d6 <= vs_d5;
	o_vs  <= vs_d6;//output


	osd_en_d1 <= osd_en;
	osd_en_d2 <= osd_en_d1;
	osd_en_d3 <= osd_en_d2;
	osd_en_d4 <= osd_en_d3;
	osd_en_d5 <= osd_en_d4;
	osd_en_d6 <= osd_en_d5;

	//
	osd_h_offset_d1 <= osd_h_offset;
	osd_h_offset_d2 <= osd_h_offset_d1;
	osd_h_offset_d3 <= osd_h_offset_d2;
	//
	osd_color_d1 <= osd_color;
	osd_color_d2 <= osd_color_d1;
	osd_color_d3 <= osd_color_d2;
	osd_color_d4 <= osd_color_d3;
	osd_color_d5 <= osd_color_d4;

	//d1
	i_data_0r_d1 <= i_data_0r;
	i_data_0g_d1 <= i_data_0g;
	i_data_0b_d1 <= i_data_0b;
	i_data_1r_d1 <= i_data_1r;
	i_data_1g_d1 <= i_data_1g;
	i_data_1b_d1 <= i_data_1b;
	i_data_2r_d1 <= i_data_2r;
	i_data_2g_d1 <= i_data_2g;
	i_data_2b_d1 <= i_data_2b;
	i_data_3r_d1 <= i_data_3r;
	i_data_3g_d1 <= i_data_3g;
	i_data_3b_d1 <= i_data_3b;
	i_data_4r_d1 <= i_data_4r;
	i_data_4g_d1 <= i_data_4g;
	i_data_4b_d1 <= i_data_4b;
	i_data_5r_d1 <= i_data_5r;
	i_data_5g_d1 <= i_data_5g;
	i_data_5b_d1 <= i_data_5b;
	i_data_6r_d1 <= i_data_6r;
	i_data_6g_d1 <= i_data_6g;
	i_data_6b_d1 <= i_data_6b;
	i_data_7r_d1 <= i_data_7r;
	i_data_7g_d1 <= i_data_7g;
	i_data_7b_d1 <= i_data_7b;
	//d2
	i_data_0r_d2 <= i_data_0r_d1;
	i_data_0g_d2 <= i_data_0g_d1;
	i_data_0b_d2 <= i_data_0b_d1;
	i_data_1r_d2 <= i_data_1r_d1;
	i_data_1g_d2 <= i_data_1g_d1;
	i_data_1b_d2 <= i_data_1b_d1;
	i_data_2r_d2 <= i_data_2r_d1;
	i_data_2g_d2 <= i_data_2g_d1;
	i_data_2b_d2 <= i_data_2b_d1;
	i_data_3r_d2 <= i_data_3r_d1;
	i_data_3g_d2 <= i_data_3g_d1;
	i_data_3b_d2 <= i_data_3b_d1;
	i_data_4r_d2 <= i_data_4r_d1;
	i_data_4g_d2 <= i_data_4g_d1;
	i_data_4b_d2 <= i_data_4b_d1;
	i_data_5r_d2 <= i_data_5r_d1;
	i_data_5g_d2 <= i_data_5g_d1;
	i_data_5b_d2 <= i_data_5b_d1;
	i_data_6r_d2 <= i_data_6r_d1;
	i_data_6g_d2 <= i_data_6g_d1;
	i_data_6b_d2 <= i_data_6b_d1;
	i_data_7r_d2 <= i_data_7r_d1;
	i_data_7g_d2 <= i_data_7g_d1;
	i_data_7b_d2 <= i_data_7b_d1;
	//d3
	i_data_0r_d3 <= i_data_0r_d2;
	i_data_0g_d3 <= i_data_0g_d2;
	i_data_0b_d3 <= i_data_0b_d2;
	i_data_1r_d3 <= i_data_1r_d2;
	i_data_1g_d3 <= i_data_1g_d2;
	i_data_1b_d3 <= i_data_1b_d2;
	i_data_2r_d3 <= i_data_2r_d2;
	i_data_2g_d3 <= i_data_2g_d2;
	i_data_2b_d3 <= i_data_2b_d2;
	i_data_3r_d3 <= i_data_3r_d2;
	i_data_3g_d3 <= i_data_3g_d2;
	i_data_3b_d3 <= i_data_3b_d2;
	i_data_4r_d3 <= i_data_4r_d2;
	i_data_4g_d3 <= i_data_4g_d2;
	i_data_4b_d3 <= i_data_4b_d2;
	i_data_5r_d3 <= i_data_5r_d2;
	i_data_5g_d3 <= i_data_5g_d2;
	i_data_5b_d3 <= i_data_5b_d2;
	i_data_6r_d3 <= i_data_6r_d2;
	i_data_6g_d3 <= i_data_6g_d2;
	i_data_6b_d3 <= i_data_6b_d2;
	i_data_7r_d3 <= i_data_7r_d2;
	i_data_7g_d3 <= i_data_7g_d2;
	i_data_7b_d3 <= i_data_7b_d2;
	//d4
	i_data_0r_d4 <= i_data_0r_d3;
	i_data_0g_d4 <= i_data_0g_d3;
	i_data_0b_d4 <= i_data_0b_d3;
	i_data_1r_d4 <= i_data_1r_d3;
	i_data_1g_d4 <= i_data_1g_d3;
	i_data_1b_d4 <= i_data_1b_d3;
	i_data_2r_d4 <= i_data_2r_d3;
	i_data_2g_d4 <= i_data_2g_d3;
	i_data_2b_d4 <= i_data_2b_d3;
	i_data_3r_d4 <= i_data_3r_d3;
	i_data_3g_d4 <= i_data_3g_d3;
	i_data_3b_d4 <= i_data_3b_d3;
	i_data_4r_d4 <= i_data_4r_d3;
	i_data_4g_d4 <= i_data_4g_d3;
	i_data_4b_d4 <= i_data_4b_d3;
	i_data_5r_d4 <= i_data_5r_d3;
	i_data_5g_d4 <= i_data_5g_d3;
	i_data_5b_d4 <= i_data_5b_d3;
	i_data_6r_d4 <= i_data_6r_d3;
	i_data_6g_d4 <= i_data_6g_d3;
	i_data_6b_d4 <= i_data_6b_d3;
	i_data_7r_d4 <= i_data_7r_d3;
	i_data_7g_d4 <= i_data_7g_d3;
	i_data_7b_d4 <= i_data_7b_d3;
	//d5
	i_data_0r_d5 <= i_data_0r_d4;
	i_data_0g_d5 <= i_data_0g_d4;
	i_data_0b_d5 <= i_data_0b_d4;
	i_data_1r_d5 <= i_data_1r_d4;
	i_data_1g_d5 <= i_data_1g_d4;
	i_data_1b_d5 <= i_data_1b_d4;
	i_data_2r_d5 <= i_data_2r_d4;
	i_data_2g_d5 <= i_data_2g_d4;
	i_data_2b_d5 <= i_data_2b_d4;
	i_data_3r_d5 <= i_data_3r_d4;
	i_data_3g_d5 <= i_data_3g_d4;
	i_data_3b_d5 <= i_data_3b_d4;
	i_data_4r_d5 <= i_data_4r_d4;
	i_data_4g_d5 <= i_data_4g_d4;
	i_data_4b_d5 <= i_data_4b_d4;
	i_data_5r_d5 <= i_data_5r_d4;
	i_data_5g_d5 <= i_data_5g_d4;
	i_data_5b_d5 <= i_data_5b_d4;
	i_data_6r_d5 <= i_data_6r_d4;
	i_data_6g_d5 <= i_data_6g_d4;
	i_data_6b_d5 <= i_data_6b_d4;
	i_data_7r_d5 <= i_data_7r_d4;
	i_data_7g_d5 <= i_data_7g_d4;
	i_data_7b_d5 <= i_data_7b_d4;
	//d6
	i_data_0r_d6 <= i_data_0r_d5;
	i_data_0g_d6 <= i_data_0g_d5;
	i_data_0b_d6 <= i_data_0b_d5;
	i_data_1r_d6 <= i_data_1r_d5;
	i_data_1g_d6 <= i_data_1g_d5;
	i_data_1b_d6 <= i_data_1b_d5;
	i_data_2r_d6 <= i_data_2r_d5;
	i_data_2g_d6 <= i_data_2g_d5;
	i_data_2b_d6 <= i_data_2b_d5;
	i_data_3r_d6 <= i_data_3r_d5;
	i_data_3g_d6 <= i_data_3g_d5;
	i_data_3b_d6 <= i_data_3b_d5;
	i_data_4r_d6 <= i_data_4r_d5;
	i_data_4g_d6 <= i_data_4g_d5;
	i_data_4b_d6 <= i_data_4b_d5;
	i_data_5r_d6 <= i_data_5r_d5;
	i_data_5g_d6 <= i_data_5g_d5;
	i_data_5b_d6 <= i_data_5b_d5;
	i_data_6r_d6 <= i_data_6r_d5;
	i_data_6g_d6 <= i_data_6g_d5;
	i_data_6b_d6 <= i_data_6b_d5;
	i_data_7r_d6 <= i_data_7r_d5;
	i_data_7g_d6 <= i_data_7g_d5;
	i_data_7b_d6 <= i_data_7b_d5;
end

endmodule
