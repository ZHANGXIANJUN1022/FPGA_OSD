
module IR_receive
(
    input                  sys_clk   ,  //系统时钟, 50MHz clock
    input                  sys_rst_n ,  //系统复位信号，低电平有效
    
    input                  remote_in ,  //红外接收信号
    output    reg          data_en   ,  //数据有效信号
    output                 out_clk   ,   
    output    reg  [7:0]   data         //红外控制码
);
 
//parameter define
parameter  st_idle           = 6'b000001;  //空闲状态
parameter  st_start_low_3ms  = 6'b000010;  //监测引导码高电平
parameter  st_start_high_3ms = 6'b000100;  //监测引导码低电平(空闲信号)
parameter  st_rec_data       = 6'b001000;  //接收数据
parameter  st_done_code      = 6'b010000;  //同步码
parameter  st_wait           = 6'b100000; //唯一码

//reg define
reg    [5:0]    cur_state      ;
reg    [5:0]    next_state     ;
reg    [11:0]   div_cnt        ;  //分频计数器
reg             div_clk        ;  //分频时钟
reg             remote_in_d0   ;  //对输入的红外信号延时打拍
reg             remote_in_d1   ;
reg    [7:0]    time_cnt       ;  //对红外的各个状态进行计数
reg             time_cnt_clr   ;  //计数器清零信号
reg             time_done      ;  //计时完成信号
reg             error_en       ;  //错误信号

reg    [7 :0]   judge_data     ;
reg             judge_flag     ;  //检测出的同步码
reg    [15:0]   data_temp      ;  //暂存收到的控制码和控制反码
reg    [5:0]    data_cnt       ;  //对接收的数据进行计数       
//wire define
wire            pos_remote_in  ;  //输入红外信号的上升沿
wire            neg_remote_in  ;  //输入红外信号的下降沿

assign  out_clk = div_clk;


reg   [11:0]    delay_cnt;

//*****************************************************
//**                    main code
//*****************************************************
assign  pos_remote_in = (~remote_in_d1) & remote_in_d0;
assign  neg_remote_in = remote_in_d1 & (~remote_in_d0);
//时钟分频,50Mhz/(2*(3124+1))=8khz,T=0.125ms
always @(posedge sys_clk or negedge sys_rst_n  ) begin
    if (!sys_rst_n) begin
        div_cnt <= 12'd0;
        div_clk <= 1'b0;
    end    
    else if(div_cnt == 12'd3124) begin
        div_cnt <= 12'd0;
        div_clk <= ~div_clk;
    end    
    else
        div_cnt <= div_cnt + 12'b1;
end
 
//对红外的各个状态进行计数
always @(posedge div_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        time_cnt <= 8'd0;
    else if(time_cnt_clr)
        time_cnt <= 8'd0;
    else 
        time_cnt <= time_cnt + 8'd1;
end 
always @(posedge div_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        delay_cnt <= 12'd0;
    else if(time_cnt_clr)
        delay_cnt <= 12'd0;
    else 
        delay_cnt <= delay_cnt + 12'd1;
end 

//对输入的remote_in信号延时打拍
always @(posedge div_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        remote_in_d0 <= 1'b0;
        remote_in_d1 <= 1'b0;
    end
    else begin
        remote_in_d0 <= remote_in;
        remote_in_d1 <= remote_in_d0;
    end
end
//状态机
always @ (posedge div_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cur_state <= st_idle;
    else
        cur_state <= next_state ;
end
always @(*) begin
    next_state = st_idle;
    case(cur_state)
        st_idle : begin                           //空闲状态
            if(remote_in_d0 == 1'b0)
                next_state = st_start_low_3ms;
            else
                next_state = st_idle;            
        end
        st_start_low_3ms : begin                  //监测同步码高电平
            if(time_done)
                next_state = st_start_high_3ms;
            else if(error_en)
                next_state = st_idle;
            else
                next_state = st_start_low_3ms;
        end
        st_start_high_3ms : begin                    //监测同步码低电平
            if(time_done) begin
                next_state = st_rec_data;
            end
            else if(error_en)
                next_state = st_idle;
            else
                next_state = st_start_high_3ms;
        end
        st_rec_data : begin                       //接收数据
            if(remote_in_d0 && data_cnt == 6'd16) 
                next_state = st_done_code;
            else
                next_state = st_rec_data;                
        end
        st_done_code : begin                    //同步码
            if(time_done)
                next_state = st_wait;
            else if (error_en) 
                next_state = st_idle;
            else
                next_state = st_done_code;  
        end 

        st_wait : begin                    //唯一码
            if(time_done)
                next_state = st_idle;
            else
                next_state = st_wait;  
        end   
        default : next_state = st_idle;
    endcase
end
 
always @(posedge div_clk or negedge sys_rst_n ) begin 
    if (!sys_rst_n) begin  
        time_cnt_clr <= 1'b0;
        time_done <= 1'b0;
        error_en <= 1'b0;
        judge_flag <= 1'b0;
        data_en <= 1'b0;
        data <= 8'd0;
        data_cnt <= 6'd0;
        data_temp <= 32'd0;
    end
    else begin
        time_cnt_clr <= 1'b0;
        time_done <= 1'b0;
        error_en <= 1'b0;
        data_en <= 1'b0;
        case(cur_state)
            st_idle           : begin
                time_cnt_clr <= 1'b1;
                if(remote_in_d0 == 1'b0)
                    time_cnt_clr <= 1'b0;
            end   
            st_start_low_3ms  : begin                             //3ms/0.125ms = 24 检测低电平3ms,进入高电平检测
                if(pos_remote_in) begin  
                    time_cnt_clr <= 1'b1;                  
                    if(time_cnt >= 21 && time_cnt <= 25)
                        time_done <= 1'b1;  
                    else 
                        error_en <= 1'b1;
                end   
            end
            st_start_high_3ms : begin                           //检测高电平3ms,进入数据接收
                if(neg_remote_in) begin   
                    time_cnt_clr <= 1'b1;      
                    //引导码低电平3ms
                    if(time_cnt >= 21 && time_cnt <= 25) begin
                        time_done <= 1'b1;                     
                    end
                    else
                        error_en <= 1'b1;
                end                       
            end
            st_rec_data : begin                                  
                if(pos_remote_in) begin
                    time_cnt_clr <= 1'b1;
                    if(data_cnt == 6'd16) begin
                        data_cnt    <= 6'd0;
                        data_temp   <= 16'd0;
                        judge_data  <= data_temp[7:0];
                    end
                end
                else if(neg_remote_in) begin
                    time_cnt_clr <= 1'b1;
                    data_cnt <= data_cnt + 1'b1;    
                    //解析控制码和数据码   
                    if(data_cnt >= 6'd0 && data_cnt <= 6'd15) begin 
                        if(time_cnt >= 9 && time_cnt <= 13) begin  //1.5/0.125 = 12
                            //data_temp <= {1'b0,data_temp[15:1]};  //逻辑“0”
                            data_temp <= {data_temp[14:0],1'b0};  //逻辑“0”
                        end
                        else if(time_cnt >= 17 && time_cnt <= 21) //2.5/0.125 = 20
                            //data_temp <= {1'b1,data_temp[15:1]};  //逻辑“1”
                            data_temp <= {data_temp[14:0],1'b1};  //逻辑“1”
                    end
                end
            end
            st_done_code : begin                      //检测高电平3.5ms      
                if(neg_remote_in) begin   
                    time_cnt_clr <= 1'b1;      
                    //同步码低电平3.5ms
                    if(time_cnt >= 26 && time_cnt <= 30) begin
                        time_done <= 1'b1;    
                        data_en   <= 1'b1;
                        data      <= judge_data;               
                    end
                    else begin
                        error_en  <= 1'd1;
                    end
                end 
            end
            st_wait :begin
                if (delay_cnt == 12'd2048) begin
                    time_done <= 1'b1;    
                end
            end
            default : ;
        endcase
    end
end

endmodule