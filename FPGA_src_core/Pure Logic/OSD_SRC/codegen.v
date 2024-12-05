

module codegen(
	input 			     clk, //fpga_clk

	input	   [7 :0]	 order,
	input   		     order_en,

    //data from the eeprom
    //input      [7 :0]    ep_rvmax,//rough delay adjustment
    //input      [7 :0]    ep_rvmin,//fine delay adjustment
    //input      [7 :0]    ep_rmode,//display mode

	output reg [19:0]	 osd_code//command[on/off  mode  sel_line  mode1  mode2]
                                    //      1       2       2        5      9
);

//////////////////////////////////////////
/****************************************/
//0x50-setting  0x2B-up 0x2D-left 0x2E-right 0x2c-down 
//0x2f-confirm  0x30-back
//0x01-0x09 --- 0-9
reg [3 :0]current_state;
reg  [3 :0]next_state;

//order
localparam
    SET         = 8'h0B,
    OK          = 8'h2F,

    LEFT        = 8'h2D,
    RIGHT       = 8'h2E,
    DOWN        = 8'h2C,
    UP          = 8'h2B,

    BACK        = 8'h30,

    ONE         = 8'h01,
    TWO         = 8'h02,
    THREE       = 8'h03,
    FOUR        = 8'h04,
    FIVE        = 8'h05,
    SIX         = 8'h06,
    SEVEN       = 8'h07,
    EIGHT       = 8'h08,
    NINE        = 8'h09,
    ZERO        = 8'h00;
//state
localparam
    OFF         = 4'd0,
    MOD_0       = 4'b1000,//LD 流水灯模式特殊处理，按OK按键退出
    MOD_1       = 4'b1001,
    MOD_2       = 4'b1011;//SP

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
reg      sw;

reg [1:0]mode;
reg [1:0]sel_line;

reg [4:0]mode1;
reg      mode2_0;
reg [3:0]mode2_1;
reg [3:0]mode2_2;
//state machine --- change display interface step by step
always @(posedge clk) begin
    current_state <= next_state;
end
always @(*) begin
    if (order_en == 1'd1 && mode1 == 5'b10011)begin
        next_state = current_state;
    end
    else if (current_state == OFF && order_en == 1'd1) begin
        case(order)
            SET:begin
                next_state = {2'b10,mode};
            end

            default:begin
                next_state = OFF;
            end
        endcase
    end
    else if (current_state != OFF && order_en == 1'd1) begin
        case(order)
            SET:begin
                next_state = OFF;
            end

            default:begin
                next_state = {2'b10,mode};
            end
        endcase
    end
    else begin
        next_state = current_state;
    end
end

//parameter on/off
always @(posedge clk) begin
    if (current_state == OFF) begin
        sw <= 1'd0;
    end
    else begin
        sw <= 1'd1;
    end
end

//parameter sel_line
always @(posedge clk) begin
    if (order_en && mode1 == 5'b10011)begin
        sel_line <= sel_line;
    end
    else if (mode == 2'b00 && order_en ) begin
        case(order)
            DOWN:begin
                if (sel_line == 2'd3) begin
                    sel_line <= 2'd0;
                end
                else begin
                    sel_line <= sel_line + 1'd1;
                end    
            end

            UP:begin
                if (sel_line == 2'd0) begin
                    sel_line <= 2'd3;
                end
                else begin
                    sel_line <= sel_line - 1'd1;
                end    
            end

            default:begin
                sel_line <= sel_line;
            end
        endcase
    end
    else if (mode == 2'b01 && order_en) begin
        case(order)
            DOWN:begin
                if (sel_line == 2'd3) begin
                    sel_line <= 2'd0;
                end
                else begin
                    sel_line <= sel_line + 1'd1;
                end    
            end

            UP:begin
                if (sel_line == 2'd0) begin
                    sel_line <= 2'd3;
                end
                else begin
                    sel_line <= sel_line - 1'd1;
                end    
            end

            default:begin
                sel_line <= sel_line;
            end
        endcase
    end
//    else if (current_state == MOD_2 && order_en) begin
//        case(order)
//            DOWN:begin
//                if (sel_line == 2'd2) begin
//                    sel_line <= 2'd0;
//                end
//                else begin
//                    sel_line <= sel_line + 1'd1;
//                end    
//            end

//            UP:begin
//                if (sel_line == 2'd0) begin
//                    sel_line <= 2'd2;
//                end
//                else begin
//                    sel_line <= sel_line - 1'd1;
//                end    
//            end

//            default:begin
//                sel_line <= sel_line;
//            end
//        endcase
//    end
    else begin
        sel_line <= sel_line;
    end
end

//parameter mode
always @(posedge clk) begin
    if (current_state != OFF && order_en && sel_line == 2'd0) begin
        case(order)
            RIGHT:begin
                if (mode == 2'd1) begin
                    mode <= 2'd0;
                end
                else begin
                    mode <= mode + 2'd1;
                end    
            end

            LEFT:begin
                if (mode == 2'd0) begin
                    mode <= 2'd1;
                end
                else begin
                    mode <= mode - 1'd1;
                end    
            end

            default:begin
                mode <= mode;
            end
        endcase
    end
end

//parameter mode1
always @(posedge clk) begin
    if (current_state == MOD_0 && order_en) begin
        case(sel_line)
            2'd1:begin
                if (order == OK) begin
                    mode1[4:3]  <= 2'd0;
                    mode1[0]    <= !mode1[0];
                    mode1[2]    <= 1'b1;
                    mode1[1]    <= 1'b1;
                end
            end

            2'd2:begin
                if (order == OK) begin
                    mode1[4:3] <= 2'd1;
                    mode1[1]   <= !mode1[1];
                    mode1[0]    <= 1'b1;
                    mode1[2]    <= 1'b1;
                end
            end

            2'd3:begin
                if (order == OK) begin
                    mode1[4:3] <= 2'd2;
                    mode1[2]   <= !mode1[2];
                    mode1[0]    <= 1'b1;
                    mode1[1]    <= 1'b1;
                end
            end
            default:begin
                mode1 <= mode1;
            end
        endcase
    end
    else begin
        mode1[4:3] <= mode1[4:3];
        if (mode1[0]  == 1'b0) begin
            mode1[2] <= 1'b1;
            mode1[1] <= 1'b1;
            mode1[0] <= 1'b0;
        end
        else if (mode1[1]  == 1'b0) begin
            mode1[0] <= 1'b1;
            mode1[2] <= 1'b1;
            mode1[1] <= 1'b0;
        end
        else if (mode1[2]  == 1'b0) begin
            mode1[0] <= 1'b1;
            mode1[1] <= 1'b1;
            mode1[2] <= 1'b0;
        end
        else begin
            mode1[2:0] <= mode1[2:0];
        end
    end
end

//parameter mode2_sp_on/off
always @(posedge clk) begin
    if (current_state == MOD_1 && order_en) begin
        case(sel_line)
            2'd2:begin//空间滤波
                if (order == OK) begin
                    mode2_0     <= !mode2_0;
                end
            end

            //2'd2:begin//时间滤波
            //    if (order == OK) begin
            //        mode2[1]   <= !mode2[1];
            //    end
            //end

            default:begin
                mode2_0 <= mode2_0;
            end
        endcase
    end
    else begin
        mode2_0 <= mode2_0;
    end
end

//parameter mode2
always @(posedge clk) begin
    if (current_state == MOD_1 && order_en) begin
        case(sel_line)
            2'd1:begin//背光数据模式 0 1 2 3
                if (order == RIGHT) begin
                    if (mode2_1 == 4'd3) begin
                        mode2_1   <= 4'd0;           
                    end
                    else begin
                        mode2_1   <= mode2_1 +4'd1;
                    end 
                end
                else if (order == LEFT) begin
                    if (mode2_1 == 4'd0) begin
                        mode2_1   <= 4'd3;           
                    end
                    else begin
                        mode2_1   <= mode2_1 - 4'd1;
                    end 
                end
            end

            2'd2:begin//空间滤波模式 0 1 
                if (order == RIGHT) begin
                    if (mode2_2 == 4'd1) begin
                        mode2_2   <= 4'd0;           
                    end
                    else begin
                        mode2_2   <= mode2_2 +4'd1;
                    end
                end
                else if (order == LEFT) begin
                    if (mode2_2 == 4'd0) begin
                        mode2_2   <= 4'd1;           
                    end
                    else begin
                        mode2_2   <= mode2_2 - 4'd1;
                    end
                end
            end

            default:begin
                mode2_1 <= mode2_1;
                mode2_2 <= mode2_2;
            end
        endcase
    end
    else begin
        mode2_1 <= mode2_1;
        mode2_2 <= mode2_2;
    end
end


//拓展gamma
reg sw_gamma;
always @(posedge clk) begin
    if (current_state == MOD_1 && order_en && sel_line == 2'd3) begin
        if(order == OK )begin
            sw_gamma <= ~sw_gamma;
        end
        else begin
            sw_gamma <= sw_gamma;
        end
    end
end
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//generate the command
always @(posedge clk) begin
    osd_code <= {sw,sw_gamma,mode,sel_line,mode1,mode2_0,mode2_1,mode2_2};
end
//sw on/off
//拓展位
//mode  0 1 2(pic)
//sel_line 0 1 2 3(four lines)
//mode1 0 1 2 : o o o (默认0 开启)
//mode1 0 1 :o o(默认0 普通) 1 对比 2 流水
//mode2_0 : 0 (默认0 开)
//mode2_1 : 0 1 2 3 (4)(默认 0 灰度1)
//mode2_2 : 0 1     (4)(默认 0 高斯) 

endmodule

