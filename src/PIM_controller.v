//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) 
//Date        : 2021-02-02
//Host        : Duheon
//Design      : PIM_controller
//Version     : 0.1
//--------------------------------------------------------------------------------
//Generate log
//Data        : 
//--------------------------------------------------------------------------------

module PIM_controller# (
	parameter integer MMR_AXI_DATA_WIDTH = 64,
	parameter integer MMR_AXI_ADDR_WIDTH = 40,
	parameter integer NDP_AXI_DATA_WIDTH = 512,
	parameter integer NDP_AXI_ADDR_WIDTH = 40,
	parameter integer PAGETABLE_SIZE = 1024 * 1024 * 8,
	parameter integer MMR_SIZE = 1024,	
	parameter integer STATE_BIT = 5
  )(
	input wire clk,
	input wire resetn,
	input wire [31:0] PIM_cmd,
	output wire finish,
	output wire PE_start,
	output wire cl_flush
  );
	localparam START_BIT = 0;
	localparam [STATE_BIT-1:0]
		STATE_READY = 0,
		STATE_RUN = 1,
		STATE_CLFLUSH = 2,
		STATE_FINISH = 4,
		STATE_ERROR = 8;
	localparam [3-1:0]
		STATE_READY_BIT = 0,
		STATE_RUN_BIT = 1,
		STATE_CLFLUSH_BIT = 2,
		STATE_FINISH_BIT = 3,
		STATE_ERROR_BIT = 4;		
	reg [STATE_BIT-1:0] PIM_CS_fsm;
	reg [STATE_BIT-1:0] PIM_NS_fsm;
	wire finish;
	
	always@(*) begin
		case(PIM_CS_fsm)
			STATE_READY:begin
				if(PIM_cmd[START_BIT]==1) begin
					PIM_NS_fsm = STATE_RUN;
				end
				else begin
					PIM_NS_fsm = STATE_READY;
				end
			end
			STATE_RUN:begin
				if(PE_done==1) begin
					PIM_NS_fsm = STATE_CLFLUSH;
				end
				else begin
					PIM_NS_fsm = STATE_RUN;
				end				
			end		
			STATE_CLFLUSH:begin
				if(wb_empty&cache_empty) begin
					PIM_NS_fsm = STATE_FINISH;
				end
				else begin
					PIM_NS_fsm = STATE_CLFLUSH;
				end
			end			
			STATE_FINISH:begin
				PIM_NS_fsm = STATE_READY;
			end
			STATE_ERROR:begin
				STATE_ERROR = STATE_FINISH;
			end
		end
	end
	
	always @ (posedge aclk) begin
		if(~reset) begin
			PIM_CS_fsm <= STATE_READY;
		end
		else begin
			PIM_CS_fsm <= PIM_NS_fsm;
		end
	end
	
	assign finish = (PIM_CS_fsm[STATE_FINISH_BIT] == 1);
	assign PE_start = (PIM_CS_fsm[STATE_RUN_BIT] == 1);
	assign cl_flush = (PIM_CS_fsm[STATE_CLFLUSH_BIT] == 1);
endmodule