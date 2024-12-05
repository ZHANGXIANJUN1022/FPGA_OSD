
module keydown(

	input clk, //fpga_clk
	input rst_n,//global_resetn

	input sw,
	output reg mode

	);

	reg [18:0]cnt;

	//all the state in pressing the button 
	localparam
		IDIE = 3'd0,
		UP   = 3'd1,
		DOWN = 3'd2,
		TEST = 3'd3,
		FINE = 3'd4;

	reg [2:0]current;
	reg [2:0]next;
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			current <= IDIE;
		end
		else begin
			current <= next;
		end
	end

	//detect the time pressed
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			cnt <= 19'd0;
		end
		else if (current == DOWN) begin
			cnt <= cnt + 19'd1;
		end
		else begin
			cnt <= 19'd0;
		end
	end
	
	//state machine
	always @(*) begin
			case(current)
				IDIE:begin
					if(sw)begin
						next = UP;
					end
					else begin
						next = IDIE;
					end
				end
				
				UP:begin
					if(~sw)begin
						next = DOWN;
					end
					else begin
						next = UP;
					end
				end
				
				DOWN:begin//delay
					if(cnt == 19'd299_999)begin
						next = TEST;
					end
					else begin
						next = DOWN;
					end
				end

				TEST:begin
					if(~sw) begin
						next = FINE;
					end
					else begin
						next = IDIE;
					end
				end

				FINE:begin
					next = IDIE;
				end

				default:begin
					next = IDIE;
				end
			endcase
	end

	//pressed flag
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			mode <= 1'd0;		
		end
		else if (current == FINE) begin
			mode <= 1'd1;
		end
		else begin
			mode <= 1'd0;
		end
	end
endmodule