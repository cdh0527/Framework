//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) 
//Date        : 2021-03-01
//Host        : Duheon
//Design      : OC_tb
//Version     : 0.1
//--------------------------------------------------------------------------------
`timescale 1 ns / 10 ps

module oc_tb(
);
	reg aclk;
	reg aresetn;
	parameter integer WORD_SIZE_BYTE = 4;
	parameter integer LINE_SIZE_BYTE = 64;
	parameter integer ADDR_WIDTH = 40;
	parameter integer NUM_ENTRY_BIT = 1;
	parameter integer WORD_SIZE = WORD_SIZE_BYTE*8;
	parameter integer LINE_SIZE = LINE_SIZE_BYTE*8;
	parameter integer OBJECT_ID = 1;
	parameter integer OBJECT_ID_WIDTH_BIT = 2;
	

	
	//slave port
	reg [40-1:0] s_addr;
	wire [32-1:0] s_wdata;
	reg s_ren;
	reg s_wen;
	wire [32-1:0] s_rdata;
	wire s_data_valid;
	
	wire [LINE_SIZE-1:0] m_rdata;
	reg m_rdata_valid;
	reg m_rready;
	reg m_wready;
	wire [ADDR_WIDTH-1:0] m_waddr, m_raddr;
	wire [LINE_SIZE-1:0] m_wdata;
	wire m_ren;
	wire m_wen;
	
	initial begin
		aclk = 1'b0;
		forever
			#1 aclk = ~ aclk;
	end
	
	initial begin
		aresetn <= 0;
		#10
		aresetn <= 1;
		#2
		aresetn <= 0;
	end
	//read hit
	
	initial begin
		s_ren <= 0;
		s_wen <= 0;
		#100
		s_ren <= 1;
		s_addr <= 40'd0;
		#2
		s_ren <= 0;
		#100
		s_ren <= 1;
		s_addr <= 40'd4;
		#2
		s_ren <= 0;
		#100
		s_ren <= 1;
		s_addr <= 40'd8;
		#2
		s_ren <= 0;
		#100
		s_ren <= 1;
		s_addr <= 40'd4;
		#2
		s_ren <= 0;
	end
	//read miss
	/*
	initial begin
		s_ren <= 0;
		s_wen <= 0;	
		#100
		s_ren <= 1;
		s_addr <= 40'd0;
		#2
		s_ren <= 0;
		#100
		s_ren <= 1;
		s_addr <= 40'd128;
		#2
		s_ren <= 0;
		#100
		s_ren <= 1;
		s_addr <= 40'd256;
		#2
		s_ren <= 0;
		#100
		s_ren <= 1;
		s_addr <= 40'd128;
		#2
		s_ren <= 0;
		#100
	end*/
	//write hit
	/*
	initial begin
		#100
		s_wen <= 1;
		s_addr <= 40'd0;
		#2
		s_wen <= 0;
		#100
		s_wen <= 1;
		s_addr <= 40'd4;
		#2
		s_wen <= 0;
		#100
		s_wen <= 1;
		s_addr <= 40'd8;
		#2
		s_wen <= 0;
		#100
		s_wen <= 1;
		s_addr <= 40'd4;
		#2
		s_wen <= 0;
		#100
	end*/
	
	//write miss
	/*
	initial begin
		#100
		s_wen <= 1;
		s_addr <= 40'd0;
		#2
		s_wen <= 0;
		#100
		s_wen <= 1;
		s_addr <= 40'd128;
		#2
		s_wen <= 0;
		#100
		s_wen <= 1;
		s_addr <= 40'd256;
		#2
		s_wen <= 0;
		#100
		s_wen <= 1;
		s_addr <= 40'd128;
		#2
		s_wen <= 0;
		#100
	end*/
	
	assign m_rdata = m_raddr;
	assign s_wdata = s_addr;
	
	objectCache oc(
	.aclk			(aclk),
	.aresetn        (aresetn),
	.s_addr         (s_addr),
	.s_wdata        (s_wdata),
	.s_ren          (s_ren),
	.s_wen          (s_wen),
	.s_rdata        (s_rdata),
	.s_data_valid   (s_data_valid),
	.m_raddr        (m_raddr),
	.m_waddr		(m_waddr),	
	.m_wdata        (m_wdata),
	.m_ren          (m_ren),
	.m_wen          (m_wen),
	.m_rdata        (m_rdata),
	.m_rdata_valid  (1),
	.m_rready       (1),
	.m_wready	    (1)
	);
endmodule
	