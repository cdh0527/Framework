//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) 
//Date        : 2021-03-01
//Host        : Duheon
//Design      : MB_tb
//Version     : 0.1
//--------------------------------------------------------------------------------
`timescale 1 ns / 10 ps
module mb_tb#(
	parameter integer ADDR_WIDTH = 40,
	parameter integer DATA_WIDTH = 512,
	parameter integer NUM_DATA_OBJECT = 3
)();
	reg aclk;
	reg aresetn;

	initial begin
		aclk = 1'b0;
		forever
			#1 aclk = ~ aclk;
	end
	
	reg [ADDR_WIDTH-1:0] m_raddr_a, m_raddr_b, m_raddr_c; 
	reg [ADDR_WIDTH-1:0] m_waddr_a, m_waddr_b, m_waddr_c; 
	reg [DATA_WIDTH-1:0] m_wdata_a, m_wdata_b, m_wdata_c; 
	reg m_ren_a, m_ren_b, m_ren_c;
	reg m_wen_a, m_wen_b, m_wen_c;
	wire [DATA_WIDTH-1:0] m_rdata;
	wire m_rdata_valid;
	wire m_rready;
	wire m_wready;
	wire m_rdata_a, m_rdata_b, m_rdata_c;
	wire m_rdata_valid_a, m_rdata_valid_b, m_rdata_valid_c;
	wire m_rready_a, m_rready_b, m_rready_c;
	wire m_wready_a, m_wready_b, m_wready_c;
	
	wire [ADDR_WIDTH+NUM_DATA_OBJECT-1:0] s_raddr;
	wire [ADDR_WIDTH-1:0] s_waddr;
	wire [DATA_WIDTH-1:0] s_wdata;
	wire s_ren;
	wire s_wen;
	reg [DATA_WIDTH+NUM_DATA_OBJECT-1:0] s_rdata;
	reg s_rdata_valid;
	reg s_rready;
	reg s_wready;	
	
	initial begin
		aresetn <= 0;
		#10
		aresetn <= 1;
		#2
		aresetn <= 0;
	end	
	
	initial begin
		#1
		s_rdata_valid<=0;
		s_rdata<=0;
		#100
		//s_addr <= 40'hffe00;
		#50
		m_ren_a<=1;
		m_raddr_a<=40'hffe04; 
		#2
		m_ren_a<=0;
		#1000
		s_rdata <= 512'h2345678901;
		s_rdata_valid <= 1;
		#2
		s_rdata_valid <= 0;
		#50
		m_ren_a<=1;
		m_raddr_a<=40'hffe08;
		#2
		m_ren_a<=0;
		#1000
		s_rdata <= 512'h3456789012;
		s_rdata_valid <= 1;
		#2
		s_rdata_valid <= 0;
		#50
		m_ren_a<=1;
		m_raddr_a<=40'hffe00; 
		#2
		m_ren_a<=0;
		#1000
		s_rdata <= 512'h4567890123;
		s_rdata_valid <= 1;
		#2
		s_rdata_valid <= 0;
		#50
		m_ren_a<=1;
		m_raddr_a<=40'hffe04; 
		#2
		m_ren_a<=0;
		#1000
		s_rdata <= 512'h5678901234;
		s_rdata_valid <= 1;
		#2
		s_rdata_valid <= 0;
		end

mem_bus mb_inst(
	.aclk			(aclk),								
	.aresetn        (aresetn),
	.m_raddr        ({m_raddr_a, m_raddr_b, m_raddr_c}),
	.m_waddr        ({m_waddr_a, m_waddr_b, m_waddr_c}),
	.m_wdata        ({m_wdata_a, m_wdata_b, m_wdata_c}),
	.m_ren          ({m_ren_a, m_ren_b, m_ren_c}),
	.m_wen          ({m_wen_a, m_wen_b, m_wen_c}),
	.m_rdata        ({m_rdata_a, m_rdata_b, m_rdata_c}),
	.m_rdata_valid  ({m_rdata_valid_a, m_rdata_valid_b, m_rdata_valid_c}),
	.m_rready       ({m_rready_a, m_rready_b, m_rready_c}),
	.m_wready       ({m_wready_a, m_wready_b, m_wready_c}),
	.s_raddr        (s_raddr),
	.s_waddr        (s_waddr),
	.s_wdata        (s_wdata),
	.s_ren          (s_ren),
	.s_wen          (s_wen),
	.s_rdata        (s_rdata),
	.s_rdata_valid  (s_rdata_valid),
	.s_rready       (s_rready),
	.s_wready	    (s_wready)
);

endmodule