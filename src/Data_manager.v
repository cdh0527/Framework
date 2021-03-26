//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) 
//Date        : 2021-03-14
//Host        : Duheon
//Design      : Data_manager
//Version     : 0.1
//--------------------------------------------------------------------------------
`timescale 1 ns / 10 ps
module Memory_interface #(
	parameter integer PAGETABLE_SIZE = 1024 * 1024 * 8,
	parameter integer PAGE_SIZE = 1024 * 4,
	parameter integer PAGE_BIT=$clog2(PAGE_SIZE),	
	parameter integer PAGETABLE_LINE_WIDTH = 64,
	parameter integer PAGETABLE_INDEX = PAGETABLE_SIZE/PAGETABLE_LINE_WIDTH,
	parameter integer PAGETABLE_INDEX_BIT = $clog2(PAGETABLE_INDEX),
	parameter integer ADDR_WIDTH = 40,
	parameter integer LINE_SIZE = 512,	
	parameter integer NUM_DATA_OBJECT = 3
)(
	input wire aclk,
	input wire aresetn,
	output wire [PAGETABLE_INDEX_BIT-1:0] rp_pt_raddr,
	output wire rp_pt_ren,
	input wire [PAGETABLE_LINE_WIDTH-1:0] rp_pt_rdata,
	output wire [PAGETABLE_INDEX_BIT-1:0] wp_pt_raddr,
	output wire wp_pt_ren,
	input wire [PAGETABLE_LINE_WIDTH-1:0] wp_pt_rdata,	
	//slave
	input wire [ADDR_WIDTH+NUM_DATA_OBJECT-1:0] s_raddr,
	input wire [ADDR_WIDTH+NUM_DATA_OBJECT-1:0] s_waddr,
	input wire [LINE_SIZE-1:0] s_wdata,
	input wire s_ren,
	input wire s_wen,
	output wire [LINE_SIZE+NUM_DATA_OBJECT-1:0] s_rdata,
	output wire s_rdata_valid,
	output wire s_rready,
	output wire s_wready,

	//master
	output wire [ADDR_WIDTH-1:0] m_raddr,
									
						  
				  
					 
 
	output wire [ADDR_WIDTH-1:0] m_waddr,
	output wire [LINE_SIZE-1:0] m_wdata,
	output wire m_ren,
	output wire m_wen,
	input wire [LINE_SIZE-1:0] m_rdata,
	input wire m_rdata_valid,
	input wire m_rready,
	input wire m_wready	
);
	read_controller #(
		.PAGETABLE_SIZE			(PAGETABLE_SIZE),
		.PAGE_SIZE              (PAGE_SIZE),
		.PAGETABLE_LINE_WIDTH   (PAGETABLE_LINE_WIDTH),
		.NUM_DATA_OBJECT        (NUM_DATA_OBJECT)	
	) rc_inst (
		.aclk           (aclk),
		.aresetn        (aresetn),
		.pt_raddr       (rp_pt_raddr),
		.pt_ren         (rp_pt_ren),
		.pt_rdata       (rp_pt_rdata),
		.s_raddr        (s_raddr),
		.s_ren          (s_ren),
		.s_rdata        (s_rdata),
		.s_rdata_valid  (s_rdata_valid),
		.s_rready       (s_rready),
		.m_raddr		(m_raddr),
		.m_ren			(m_ren),
		.m_rdata		(m_rdata),
		.m_rdata_valid	(m_rdata_valid),
		.m_rready		(m_rready)
	);
	//write port
	write_controller #(
		.PAGETABLE_SIZE			(PAGETABLE_SIZE),
		.PAGE_SIZE              (PAGE_SIZE),
		.PAGETABLE_LINE_WIDTH   (PAGETABLE_LINE_WIDTH),
		.NUM_DATA_OBJECT        (NUM_DATA_OBJECT)	
	) wc_inst (
		.aclk       (aclk    ),
		.aresetn    (aresetn ),
		.pt_raddr   (wp_pt_raddr),
		.pt_ren     (wp_pt_ren  ),
		.pt_rdata   (wp_pt_rdata),
		.s_waddr    (s_waddr ),
		.s_wdata    (s_wdata ),
		.s_wen      (s_wen   ),
		.s_wready   (s_wready),
		.m_waddr    (m_waddr ),
		.m_wdata    (m_wdata ),
		.m_wen      (m_wen   ),
		.m_wready	(m_wready) 	
	);
	
	

endmodule

module read_controller #(
	parameter integer PAGETABLE_SIZE = 1024 * 1024 * 8,
	parameter integer PAGE_SIZE = 1024 * 4,
	parameter integer PAGETABLE_LINE_WIDTH = 64,
	parameter integer PAGETABLE_INDEX = PAGETABLE_SIZE/PAGETABLE_LINE_WIDTH,
	parameter integer PAGETABLE_INDEX_BIT = $clog2(PAGETABLE_INDEX),
	parameter integer PAGE_BIT=$clog2(PAGE_SIZE),	
	parameter integer ADDR_WIDTH = 40,
	parameter integer LINE_SIZE = 512,	
	parameter integer NUM_DATA_OBJECT = 3	
) (
	input wire aclk,
	input wire aresetn,
	output reg [PAGETABLE_INDEX_BIT-1:0] pt_raddr,
	output reg pt_ren,
	input wire [PAGETABLE_LINE_WIDTH-1:0] pt_rdata,
	//slave
	input wire [ADDR_WIDTH+NUM_DATA_OBJECT-1:0] s_raddr,
	input wire s_ren,
	output reg [LINE_SIZE+NUM_DATA_OBJECT-1:0] s_rdata,
	output reg s_rdata_valid,
	output wire s_rready,

	//master
	output reg [ADDR_WIDTH-1:0] m_raddr,
	output reg  m_ren,
	input wire [LINE_SIZE-1:0] m_rdata,
	input wire m_rdata_valid,
	input wire m_rready
);
	//read address port
	wire [ADDR_WIDTH+NUM_DATA_OBJECT-1:0] queue_out;
	wire [NUM_DATA_OBJECT-1:0] id_queue_in, id_queue_out;
	assign id_queue_in = queue_out[ADDR_WIDTH+NUM_DATA_OBJECT-1:ADDR_WIDTH];
	wire error_read_wait_queue, error_read_wait_queue_1, error_read_wait_queue_2;
	assign error_read_wait_queue = (error_read_wait_queue_1&&m_rdata_valid)|(error_read_wait_queue_2&&m_ren);
	wire read_queue_empty;
	localparam readSTATE_BIT = 3;
	localparam [readSTATE_BIT-1:0]
		DM_R_IDLE = 0,
		DM_R_PTREAD = 1,
		DM_R_AXIREAD = 2;
	reg [readSTATE_BIT-1:0] DM_read_state;
	wire queue_FULL;
	assign s_rready = ~queue_FULL;
				
	queue #(
		.WIDTH(NUM_DATA_OBJECT),
		.DEPTH(NUM_DATA_OBJECT+1)
	) read_wait_queue (
		.aclk       (aclk),
		.aresetn    (aresetn),
		.dataIn     (id_queue_in),
		.RD         (m_rdata_valid),
		.WR         (m_ren),
		.EN         ('b1),
		.dataOut    (id_queue_out),
		.EMPTY      (error_read_wait_queue_1),
		.FULL 		(error_read_wait_queue_2)
	);	
	queue #(
		.WIDTH(ADDR_WIDTH+NUM_DATA_OBJECT),
		.DEPTH(NUM_DATA_OBJECT+1)
	) read_queue (
		.aclk       (aclk),
		.aresetn    (aresetn),
		.dataIn     (s_raddr),
		.RD         (!read_queue_empty&&m_rready&&(DM_read_state==DM_R_IDLE)),
		.WR         (s_ren),
		.EN         ('b1),
		.dataOut    (queue_out),
		.EMPTY      (read_queue_empty),
		.FULL 		(queue_FULL)
	);

	always @(posedge aclk or negedge aresetn) begin
		if(~aresetn) begin
			m_ren <= 'b0;
			pt_ren <= 1'b0;
			m_raddr <= 'b0;
			DM_read_state <= 'b0;
			pt_raddr <= 'b0;
		end
		else begin
			case(DM_read_state) //need to optimization
				DM_R_IDLE: begin
					if(!read_queue_empty&&m_rready) begin
						DM_read_state <= DM_R_AXIREAD;
						m_ren <= 1'b0;
						pt_ren <= 1'b1;
						pt_raddr <= queue_out[ADDR_WIDTH-1:PAGE_BIT]+PAGETABLE_SIZE/id_queue_in;						
					end					
					else begin	
						DM_read_state <= DM_R_IDLE;
						m_ren <= 1'b0;
						pt_ren <= 1'b0;
						pt_raddr <= pt_raddr;
					end
				end/*
				DM_R_PTREAD: begin
					DM_read_state <= DM_R_AXIREAD;
					pt_ren<= 1'b0;
				end*/
				DM_R_AXIREAD: begin
					if(m_rready) begin
						m_ren <= 1'b1;
						pt_ren<= 1'b0;
						m_raddr <= pt_rdata|queue_out[PAGE_BIT-1:0];
						DM_read_state <= DM_R_IDLE;
					end
				end
			endcase
		end
	end
	//read data port
	reg [LINE_SIZE-1:0] s_rdata_buf;
	always @(posedge aclk or negedge aresetn) begin
		if(~aresetn) begin
			s_rdata_valid <= 'b0;
			s_rdata_buf <= 'b0;
		end
		else begin
			if(m_rdata_valid) begin
				s_rdata_valid <= 1'b1;
				s_rdata <= {id_queue_out,m_rdata};
			end
			else if(s_rdata_valid==1'b1) begin
				s_rdata_valid <= 1'b0;
				s_rdata <= s_rdata;
			end
			else begin
				s_rdata_valid <= s_rdata_valid;
				s_rdata <= s_rdata;
			end
		end
	end	
endmodule

module write_controller #(
	parameter integer PAGETABLE_SIZE = 1024 * 1024 * 8,
	parameter integer PAGE_SIZE = 1024 * 4,
	parameter integer PAGETABLE_LINE_WIDTH = 64,
	parameter integer PAGETABLE_INDEX = PAGETABLE_SIZE/PAGETABLE_LINE_WIDTH,
	parameter integer PAGETABLE_INDEX_BIT = $clog2(PAGETABLE_INDEX),
	parameter integer PAGE_BIT=$clog2(PAGE_SIZE),	
	parameter integer ADDR_WIDTH = 40,
	parameter integer LINE_SIZE = 512,	
	parameter integer NUM_DATA_OBJECT = 3	
) (
	input wire aclk,
	input wire aresetn,
	output reg [PAGETABLE_INDEX_BIT-1:0] pt_raddr,
	output reg pt_ren,
	input wire [PAGETABLE_LINE_WIDTH-1:0] pt_rdata,
	//slave
	input wire [ADDR_WIDTH+NUM_DATA_OBJECT-1:0] s_waddr,
	input wire [LINE_SIZE-1:0] s_wdata,
	input wire s_wen,
	output wire s_wready,

	//master
	output reg [ADDR_WIDTH-1:0] m_waddr,
	output reg [LINE_SIZE-1:0] m_wdata,
	output reg m_wen,
	input wire m_wready	
);
	//write address&data port
	wire [ADDR_WIDTH+LINE_SIZE+NUM_DATA_OBJECT-1:0] queue_out;
	localparam LINEoffset_bit = $clog2(LINE_SIZE/8);
	localparam writeSTATE_BIT = 3;
	localparam [writeSTATE_BIT-1:0]
		DM_W_IDLE = 0,
		DM_W_PTREAD = 1,
		DM_W_AXIREAD = 2;
	reg [writeSTATE_BIT-1:0] DM_write_state;	
	wire write_queue_empty;
	wire [NUM_DATA_OBJECT-1:0] object_id;
	reg [ADDR_WIDTH+LINE_SIZE+NUM_DATA_OBJECT-1:0] queue_out_buf;
	assign object_id = queue_out_buf[ADDR_WIDTH+NUM_DATA_OBJECT+LINE_SIZE-1:ADDR_WIDTH+LINE_SIZE];
	wire queue_FULL;
	assign s_wready = ~queue_FULL;
	
	queue #(
		.WIDTH(ADDR_WIDTH+LINE_SIZE+NUM_DATA_OBJECT),
		.DEPTH(NUM_DATA_OBJECT+1)
	) write_queue (
		.aclk       (aclk),
		.aresetn    (aresetn),
		.dataIn     ({s_waddr, s_wdata}),
		.RD         (!write_queue_empty&&m_wready&&(DM_write_state==DM_W_IDLE)),
		.WR         (s_wen),
		.EN         ('b1),
		.dataOut    (queue_out),
		.EMPTY      (write_queue_empty),
		.FULL 		(queue_FULL)
	);	
	
	always @(posedge aclk or negedge aresetn) begin
		if(~aresetn) begin
			m_wen <= 'b0;
			m_waddr <= 'b0;
			m_wdata <= 'b0;
			pt_ren <= 1'b0;
			DM_write_state <= 'b0;
			pt_raddr <= 'b0;
			queue_out_buf <= 'b0;
		end
		else begin
			case(DM_write_state) //need to optimization
				DM_W_IDLE: begin
					if(!write_queue_empty&&m_wready) begin
						DM_write_state <= DM_W_AXIREAD;
						pt_ren <= 1'b1;
						pt_raddr <= queue_out[ADDR_WIDTH-1+LINE_SIZE:PAGE_BIT+LINE_SIZE];//+PAGETABLE_SIZE/object_id;
						queue_out_buf <= queue_out;
						
					end					
					else begin	
						DM_write_state <= DM_W_IDLE;
						pt_ren <= 1'b0;
						pt_raddr <= 'b0;
						queue_out_buf <= queue_out_buf;
					end
					m_wen <= 1'b0;
					m_waddr <= 'b0;
					m_wdata <= 'b0;
				end/*
				DM_R_PTREAD: begin
					DM_read_state <= DM_R_AXIREAD;
					pt_ren<= 1'b0;
				end*/
				DM_W_AXIREAD: begin
					if(m_wready) begin
						pt_ren <= 1'b0;
						m_wen <= 1'b1;
						m_waddr <= pt_rdata|{queue_out_buf[PAGE_BIT+LINE_SIZE-1:LINEoffset_bit+LINE_SIZE],{(LINEoffset_bit){1'b0}}};
						m_wdata <= queue_out_buf[LINE_SIZE-1:0];
						DM_write_state <= DM_W_IDLE;
					end
					else begin
						pt_ren <= pt_ren;
						m_wen <= m_wen;
						m_waddr <= m_waddr;
						m_wdata <= m_wdata;
						DM_write_state <= DM_W_AXIREAD;
					end
					pt_raddr<= 'b0;
					queue_out_buf <= queue_out_buf;
				end
			endcase
		end
	end	
	
endmodule




module queue #(
	parameter integer WIDTH = 512,
	parameter integer DEPTH = 8

)(  
	input wire aclk, 
	input wire aresetn,
	input wire [WIDTH-1:0] dataIn, 
	input wire RD, 
	input wire WR, 
	input wire EN, 
	output wire [WIDTH-1:0] dataOut, 
	output wire EMPTY, 
	output wire FULL 
);  
reg [2:0]  Count = 0; 
reg [WIDTH-1:0] FIFO [0:DEPTH]; 
reg [2:0]  readCounter, writeCounter; 
assign EMPTY = (Count==0)? 1'b1:1'b0; 
assign FULL = (Count==(DEPTH))? 1'b1:1'b0; 
assign dataOut = FIFO[readCounter]; 
wire ract, wact;
assign ract = (RD ==1'b1 && Count!=0);
assign wact = (WR==1'b1 && Count<DEPTH);

always @ (posedge aclk) 
begin 
	if (EN==0); 
	else begin 
		if (~aresetn) begin 
			readCounter <= 0; 
			writeCounter <= 0; 
		end
		else begin
		    if (ract) begin 
                if (readCounter==DEPTH) begin 
    		        readCounter <= 0; 
    		    end
            	else begin
                    readCounter <= readCounter+1;        	
            	end		
    		end 
    		if (wact) begin
    			FIFO[writeCounter]  <= dataIn; 
    	        if (writeCounter==DEPTH) begin
    		         writeCounter <= 0; 
    		    end
    		    else begin
    			     writeCounter  <= writeCounter+1;
    			end 
    		end
    	end 
	end 
end 
always @ (posedge aclk) 
begin
    if (~aresetn) begin 
        Count <= 'b0;
    end
    else begin
        if(ract&&!wact) begin
            Count<=Count-1;
        end
        else if(!ract&&wact) begin
            Count<=Count+1;
        end 
        else begin
            Count<=Count;
        end
    end               
end


endmodule