`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/05 16:05:06
// Design Name: 
// Module Name: PE_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PE_tb(

    );
	
	reg aclk;
	reg aresetn;
    localparam PE_ADDR_WIDTH = 32;
	initial begin
		aclk = 1'b0;
		forever
			#1 aclk = ~ aclk;
	end
	
	initial begin
		aresetn <= 1;
		#10
		aresetn <= 0;
		#2
		aresetn <= 1;
	end
	//for PE
	reg ap_start;
	wire ap_done;
	wire ap_idle;
	wire ap_ready;
	reg [31:0] m;
	reg [31:0] n;
	reg [31:0] alpha;
	reg [31:0] beta;
	wire ap_return;
	wire mem_stall;
	// Object cache - PE
	wire [31:0] OP_a_address0;
	wire OP_a_ce0;
	reg [31:0] OP_a_q0;
	wire [31:0] OP_x_address0;
	wire OP_x_ce0;
	reg [31:0] OP_x_q0;
	wire [31:0] OP_y_address0;
	wire OP_y_ce0;
	wire OP_y_we0;
	wire [31:0] OP_y_d0;
	reg [31:0] OP_y_q0;
	wire OP_a_valid0;
	wire OP_x_valid0;
	wire OP_y_valid0;
	//alpha test
	//for trace
	reg [31:0] cnt_a, cnt_x, cnt_y;
	reg overflow_a,overflow_x,overflow_y;
	reg [PE_ADDR_WIDTH-1:0] addr_a [0:1023];
	reg [PE_ADDR_WIDTH-1:0] addr_x [0:1023];
	reg [PE_ADDR_WIDTH-1:0] addr_y [0:1023];
	always @ (posedge aclk) begin
		if(~aresetn) begin
			cnt_a<='b0;
			cnt_x<='b0;
			cnt_y<='b0;
			overflow_a<='b0;
			overflow_x<='b0;
			overflow_y<='b0;
		end
		else if(!(overflow_a|overflow_x|overflow_y)) begin
			if(OP_a_ce0) begin
				addr_a[cnt_a] <= OP_a_address0;
				cnt_a <= cnt_a+1;
				if(cnt_a == 1023) begin
					overflow_a <= 1;
				end
			end
			if(OP_x_ce0) begin
				addr_x[cnt_x] <= OP_x_address0;
				cnt_x <= cnt_x+1;
				$display("display here %d", OP_x_address0);
				if(cnt_x == 1023) begin
					overflow_x <= 1;
				end
			end
			if(OP_y_ce0) begin
				addr_y[cnt_y] <= OP_y_address0;
				cnt_y <= cnt_y+1;
				if(cnt_y == 1023) begin
					overflow_y <= 1;
				end
			end	
		end	
	end
	always @(posedge aclk)
	begin
		if(ap_done) begin
			$writememh("a_addr_v2.mem", addr_a, 0,1023);
			$writememh("b_addr_v2.mem", addr_x, 0,1023);
			$writememh("c_addr_v2.mem", addr_y, 0,1023);
			$finish;
		end
	end
	
	initial begin
		ap_start <= 0;
		#1000
		ap_start <= 1;
		m <= 16;
		n <= 16;
		alpha <= 32'h1;
		beta <= 32'h1;
		OP_a_q0  <= 32'h1;
		OP_x_q0  <= 32'h1;
		OP_y_q0  <= 32'h1;		
		#20
		ap_start <= 0;

	end

	mv PE_inst (
        .ap_clk      (aclk      ),
        .ap_rst      (!aresetn     ),
        .ap_start    (ap_start    ),
        .ap_done     (ap_done     ),
        .ap_idle     (ap_idle     ),
        .ap_ready    (ap_ready    ),
        .m           (m           ),
        .n           (n           ),
        .alpha       (alpha       ),
        .a_address0  (OP_a_address0  ),
        .a_ce0       (OP_a_ce0       ),
        .a_q0        (OP_a_q0        ),
        .x_address0  (OP_x_address0  ),
        .x_ce0       (OP_x_ce0       ),
        .x_q0        (OP_x_q0        ),
        .beta        (beta        ),
        .y_address0  (OP_y_address0  ),
        .y_ce0       (OP_y_ce0       ),
        .y_we0       (OP_y_we0       ),
        .y_d0        (OP_y_d0        ),
        .y_q0        (OP_y_q0        ),
        .ap_return   (ap_return   ),
        .a_valid0    (1    ),
        .x_valid0    (1    ),
        .y_valid0    (1    ),
        .memory_stall	 (mem_stall	)
);
endmodule
