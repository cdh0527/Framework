//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) 
//Date        : 2021-03-01
//Host        : Duheon
//Design      : MB_tb
//Version     : 0.1
//--------------------------------------------------------------------------------
`timescale 1 ns / 10 ps
module processing_tb#(
	parameter integer ADDR_WIDTH = 40,
	parameter integer PE_ADDR_WIDTH = 32,
	parameter integer DATA_WIDTH = 512,
	parameter integer NUM_DATA_OBJECT = 3,
	parameter integer PAGETABLE_SIZE = 1024 * 1024 * 8,
	parameter integer PAGE_SIZE = 1024 * 4,
	parameter integer PAGE_BIT=$clog2(PAGE_SIZE),	
	parameter integer PAGETABLE_LINE_WIDTH = 64,
	parameter integer PAGETABLE_INDEX = PAGETABLE_SIZE/PAGETABLE_LINE_WIDTH,
	parameter integer PAGETABLE_INDEX_BIT = 31,
	parameter integer LINE_SIZE = 512	
)();
	reg aclk;
	reg aresetn;

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

//alpha test
initial begin
	ap_start <= 0;
	m <= 16;
	n <= 16;
	alpha <= 32'h1;
	beta <= 32'h1;
	#1000
	ap_start <= 1;
	#20
	ap_start <= 0;
end

//  PE - Object cache -
wire [PE_ADDR_WIDTH-1:0] PO_a_address0;
wire PO_a_ce0;
wire [31:0] PO_a_q0;
wire [PE_ADDR_WIDTH-1:0] PO_x_address0;
wire PO_x_ce0;
wire [31:0] PO_x_q0;
wire [PE_ADDR_WIDTH-1:0] PO_y_address0;
wire PO_y_ce0;
wire PO_y_we0;
wire [31:0] PO_y_d0;
wire [31:0] PO_y_q0;
wire PO_a_valid0;
wire PO_x_valid0;
wire PO_y_valid0;

// Object cache - Mem bus
wire [PE_ADDR_WIDTH-1:0] OM_raddr_a,          OM_raddr_b,      OM_raddr_c;
wire [PE_ADDR_WIDTH-1:0] OM_waddr_a,          OM_waddr_b,      OM_waddr_c;
wire [511:0] OM_wdata_a,          OM_wdata_b,      OM_wdata_c;
wire OM_ren_a,            OM_ren_b,        OM_ren_c;
wire OM_wen_a,            OM_wen_b,        OM_wen_c;
wire [511:0] OM_rdata_a,          OM_rdata_b,      OM_rdata_c;
wire OM_rdata_valid_a,    OM_rdata_valid_b,OM_rdata_valid_c;
wire OM_rready_a,         OM_rready_b,     OM_rready_c;
wire OM_wready_a,         OM_wready_b,     OM_wready_c;

//Mem bus - Data manager
wire [NUM_DATA_OBJECT+PE_ADDR_WIDTH-1:0] MD_raddr;
wire [NUM_DATA_OBJECT+PE_ADDR_WIDTH-1:0] MD_waddr;
wire [511:0] MD_wdata;
wire MD_ren;
wire MD_wen;
wire [514:0] MD_rdata;
wire MD_rdata_valid;
wire MD_rready;
wire MD_wready;

//Mem bus - Host interface
wire [PAGETABLE_INDEX_BIT-1:0]rp_pt_raddr;
wire rp_pt_ren;
wire [PAGETABLE_LINE_WIDTH-1:0] rp_pt_rdata;
wire [PAGETABLE_INDEX_BIT-1:0] wp_pt_raddr;
wire wp_pt_ren;
wire [PAGETABLE_LINE_WIDTH-1:0] wp_pt_rdata;	

//Data manager - axi master
wire [ADDR_WIDTH-1:0] DA_raddr;
wire [ADDR_WIDTH-1:0] DA_waddr;
wire [LINE_SIZE-1:0] DA_wdata;
wire DA_ren;
wire DA_wen;
wire [LINE_SIZE-1:0] DA_rdata;
wire DA_rdata_valid;
wire DA_rready;
wire DA_wready;

wire [2:0] c_flush_complete;
reg finish_flag;
always @ (posedge aclk) begin
	if(ap_done) begin
		finish_flag <= 1;
	end
	else if(!c_flush_complete==0) begin
		finish_flag <= 0;
	end
	else begin
	   finish_flag <= finish_flag;
	end	
end
AXI_model AM_inst(
   .ACLK         (aclk),
   .ARESETN      (aresetn),
   .APB_WADDR    (DA_waddr),
   .APB_WDATA    (DA_wdata),
   .APB_WENABLE  (DA_wen),
   .APB_WREADY   (DA_wready),
   .APB_RADDR    (DA_raddr),
   .APB_RDATA    (DA_rdata),
   .APB_RENABLE  (DA_ren),
   .APB_RREADY   (DA_rready),
   .APB_RVALID	 (DA_rdata_valid),
   .finish      (ap_done)
);

Memory_interface #(
	.PE_ADDR_WIDTH(PE_ADDR_WIDTH)
)  MI_inst(
	.aclk            (aclk),
	.aresetn         (aresetn),
	.rp_pt_raddr     (rp_pt_raddr),
	.rp_pt_ren       (rp_pt_ren),
	.rp_pt_rdata     ({rp_pt_raddr,20'b0}),
	.wp_pt_raddr     (wp_pt_raddr),
	.wp_pt_ren       (wp_pt_ren),
	.wp_pt_rdata	 ({wp_pt_raddr,20'b0}),
	.p_raddr         (MD_raddr),
	.p_waddr         (MD_waddr),
	.p_wdata         (MD_wdata),
	.p_ren           (MD_ren),
	.p_wen           (MD_wen),
	.p_rdata         (MD_rdata),
	.p_rdata_valid   (MD_rdata_valid),
	.p_rready        (MD_rready),
	.p_wready        (MD_wready),
	.m_raddr         (DA_raddr),
	.m_waddr         (DA_waddr),
	.m_wdata         (DA_wdata),
	.m_ren           (DA_ren),
	.m_wen           (DA_wen),
	.m_rdata         (DA_rdata),
	.m_rdata_valid   (DA_rdata_valid),
	.m_rready        (DA_rready),
	.m_wready		 (DA_wready)
);

mem_bus #(
	.PE_ADDR_WIDTH(PE_ADDR_WIDTH)
) mb_inst(
	.aclk			(aclk),								
	.aresetn        (aresetn),
	.p_raddr        ({OM_raddr_a, OM_raddr_b, OM_raddr_c}),
	.p_waddr        ({OM_waddr_a, OM_waddr_b, OM_waddr_c}),
	.p_wdata        ({OM_wdata_a, OM_wdata_b, OM_wdata_c}),
	.p_ren          ({OM_ren_a, OM_ren_b, OM_ren_c}),
	.p_wen          ({OM_wen_a, OM_wen_b, OM_wen_c}),
	.p_rdata        ({OM_rdata_a, OM_rdata_b, OM_rdata_c}),
	.p_rdata_valid  ({OM_rdata_valid_a, OM_rdata_valid_b, OM_rdata_valid_c}),
	.p_rready       ({OM_rready_a, OM_rready_b, OM_rready_c}),
	.p_wready       ({OM_wready_a, OM_wready_b, OM_wready_c}),
	.m_raddr        (MD_raddr),
	.m_waddr        (MD_waddr),
	.m_wdata        (MD_wdata),
	.m_ren          (MD_ren),
	.m_wen          (MD_wen),
	.m_rdata        (MD_rdata),
	.m_rdata_valid  (MD_rdata_valid),
	.m_rready       (MD_rready),
	.m_wready	    (MD_wready)
);

objectCache_v3 #(
	.PE_ADDR_WIDTH(PE_ADDR_WIDTH)
) oc_a(
	.aclk			(aclk),
	.aresetn        (aresetn),
	.p_addr         (PO_a_address0),
	.p_wdata        (0),
	.p_ren          (PO_a_ce0),
	.p_wen          (0),
	.p_rdata        (PO_a_q0),
	.p_data_valid   (PO_a_valid0),
	.m_raddr        (OM_raddr_a),
	.m_waddr		(OM_waddr_a),	
	.m_wdata        (OM_wdata_a),
	.m_ren          (OM_ren_a),
	.m_wen          (OM_wen_a),
	.m_rdata        (OM_rdata_a),
	.m_rdata_valid  (OM_rdata_valid_a),
	.m_rready       (OM_rready_a),
	.m_wready	    (OM_wready_a),
	.c_finish_complete(c_flush_complete[2]),
	.c_finish(finish_flag)
);

objectCache_v3 #(
	.PE_ADDR_WIDTH(PE_ADDR_WIDTH)
) oc_b(
	.aclk			(aclk),
	.aresetn        (aresetn),
	.p_addr         (PO_x_address0),
	.p_wdata        (0),
	.p_ren          (PO_x_ce0),
	.p_wen          (0),
	.p_rdata        (PO_x_q0),
	.p_data_valid   (PO_x_valid0),
	.m_raddr        (OM_raddr_b),
	.m_waddr		(OM_waddr_b),	
	.m_wdata        (OM_wdata_b),
	.m_ren          (OM_ren_b),
	.m_wen          (OM_wen_b),
	.m_rdata        (OM_rdata_b),
	.m_rdata_valid  (OM_rdata_valid_b),
	.m_rready       (OM_rready_b),
	.m_wready	    (OM_wready_b),
	.c_finish_complete (c_flush_complete[1]),
	.c_finish(finish_flag)
);

objectCache_v3 #(
	.PE_ADDR_WIDTH(PE_ADDR_WIDTH)
) oc_c(
	.aclk			(aclk),
	.aresetn        (aresetn),
	.p_addr         (PO_y_address0),
	.p_wdata        (PO_y_d0),
	.p_ren          (PO_y_ce0),
	.p_wen          (PO_y_we0),
	.p_rdata        (PO_y_q0),
	.p_data_valid   (PO_y_valid0),
	.m_raddr        (OM_raddr_c),
	.m_waddr		(OM_waddr_c),	
	.m_wdata        (OM_wdata_c),
	.m_ren          (OM_ren_c),
	.m_wen          (OM_wen_c),
	.m_rdata        (OM_rdata_c),
	.m_rdata_valid  (OM_rdata_valid_c),
	.m_rready       (OM_rready_c),
	.m_wready	    (OM_wready_c),
	.c_finish_complete(c_flush_complete[0]),
	.c_finish(finish_flag)
);

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
        .a_address0  (PO_a_address0  ),
        .a_ce0       (PO_a_ce0       ),
        .a_q0        (PO_a_q0        ),
        .x_address0  (PO_x_address0  ),
        .x_ce0       (PO_x_ce0       ),
        .x_q0        (PO_x_q0        ),
        .beta        (beta        ),
        .y_address0  (PO_y_address0  ),
        .y_ce0       (PO_y_ce0       ),
        .y_we0       (PO_y_we0       ),
        .y_d0        (PO_y_d0        ),
        .y_q0        (PO_y_q0        ),
        .ap_return   (ap_return   ),
        .a_valid0    (PO_a_valid0    ),
        .x_valid0    (PO_x_valid0    ),
        .y_valid0    (PO_y_valid0    ),
        .memory_stall	 (mem_stall	)
);

endmodule