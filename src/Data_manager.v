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
	parameter integer PE_ADDR_WIDTH = 40,
	parameter integer LINE_SIZE = 512,	
	parameter integer NUM_DATA_OBJECT = 3
)(
	input wire aclk,
	input wire aresetn,
	output wire [PAGETABLE_INDEX_BIT+NUM_DATA_OBJECT-1:0] rp_pt_raddr,
	output wire rp_pt_ren,
	input wire [PAGETABLE_LINE_WIDTH-1:0] rp_pt_rdata,
	output wire [PAGETABLE_INDEX_BIT+NUM_DATA_OBJECT-1:0] wp_pt_raddr,
	output wire wp_pt_ren,
	input wire [PAGETABLE_LINE_WIDTH-1:0] wp_pt_rdata,	
	//slave
	input wire [PE_ADDR_WIDTH+NUM_DATA_OBJECT-1:0] p_raddr,
	input wire [PE_ADDR_WIDTH+NUM_DATA_OBJECT-1:0] p_waddr,
	input wire [LINE_SIZE-1:0] p_wdata,
	input wire p_ren,
	input wire p_wen,
	output wire [LINE_SIZE+NUM_DATA_OBJECT-1:0] p_rdata,
	output wire p_rdata_valid,
	output wire p_rready,
	output wire p_wready,

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
		.NUM_DATA_OBJECT        (NUM_DATA_OBJECT),
		.PE_ADDR_WIDTH			(PE_ADDR_WIDTH)
	) rc_inst (
		.aclk           (aclk),
		.aresetn        (aresetn),
		.pt_raddr       (rp_pt_raddr),
		.pt_ren         (rp_pt_ren),
		.pt_rdata       (rp_pt_rdata),
		.p_raddr        (p_raddr),
		.p_ren          (p_ren),
		.p_rdata        (p_rdata),
		.p_rdata_valid  (p_rdata_valid),
		.p_rready       (p_rready),
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
		.NUM_DATA_OBJECT        (NUM_DATA_OBJECT),
		.PE_ADDR_WIDTH			(PE_ADDR_WIDTH)
	) wc_inst (
		.aclk       (aclk    ),
		.aresetn    (aresetn ),
		.pt_raddr   (wp_pt_raddr),
		.pt_ren     (wp_pt_ren  ),
		.pt_rdata   (wp_pt_rdata),
		.p_waddr    (p_waddr ),
		.p_wdata    (p_wdata ),
		.p_wen      (p_wen   ),
		.p_wready   (p_wready),
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
	parameter integer PE_ADDR_WIDTH = 40,
	parameter integer LINE_SIZE = 512,	
	parameter integer NUM_DATA_OBJECT = 3	
) (
	input wire aclk,
	input wire aresetn,
	output reg [PAGETABLE_INDEX_BIT+NUM_DATA_OBJECT-1:0] pt_raddr,
	output reg pt_ren,
	input wire [PAGETABLE_LINE_WIDTH-1:0] pt_rdata,
	//slave
	input wire [PE_ADDR_WIDTH+NUM_DATA_OBJECT-1:0] p_raddr,
	input wire p_ren,
	output reg [LINE_SIZE+NUM_DATA_OBJECT-1:0] p_rdata,
	output reg p_rdata_valid,
	output wire p_rready,

	//master
	output reg [ADDR_WIDTH-1:0] m_raddr,
	output reg  m_ren,
	input wire [LINE_SIZE-1:0] m_rdata,
	input wire m_rdata_valid,
	input wire m_rready
);
	//read address port
	wire [PE_ADDR_WIDTH+NUM_DATA_OBJECT-1:0] queue_out;
	reg [PE_ADDR_WIDTH+NUM_DATA_OBJECT-1:0] queue_out_reg;
	wire [NUM_DATA_OBJECT-1:0] id_queue_in, id_queue_out;
	assign id_queue_in = queue_out_reg[PE_ADDR_WIDTH+NUM_DATA_OBJECT-1:PE_ADDR_WIDTH];
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
	assign p_rready = ~queue_FULL;
	
	reg m_rdata_valid_l;	
	always @(posedge aclk) begin
		m_rdata_valid_l <= m_rdata_valid;
	end
	wire wait_queue_rd = (m_rdata_valid>m_rdata_valid_l);
	
	queue #(
		.WIDTH(NUM_DATA_OBJECT),
		.DEPTH(NUM_DATA_OBJECT+1)
	) read_wait_queue (
		.aclk       (aclk),
		.aresetn    (aresetn),
		.dataIn     (id_queue_in),
		.RD         (wait_queue_rd),
		.WR         (m_ren),
		.EN         ('b1),
		.dataOut    (id_queue_out),
		.EMPTY      (error_read_wait_queue_1),
		.FULL 		(error_read_wait_queue_2)
	);	
	queue #(
		.WIDTH(PE_ADDR_WIDTH+NUM_DATA_OBJECT),
		.DEPTH(NUM_DATA_OBJECT+1)
	) read_queue (
		.aclk       (aclk),
		.aresetn    (aresetn),
		.dataIn     (p_raddr),
		.RD         (!read_queue_empty&&m_rready&&(DM_read_state==DM_R_IDLE)),
		.WR         (p_ren),
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
			queue_out_reg <= 'b0;
		end
		else begin
			case(DM_read_state) //need to optimization
				DM_R_IDLE: begin
					if(!read_queue_empty&&m_rready) begin
						DM_read_state <= DM_R_AXIREAD;
						m_ren <= 1'b0;
						pt_ren <= 1'b1;
						pt_raddr <= {queue_out[PE_ADDR_WIDTH+NUM_DATA_OBJECT-1:PE_ADDR_WIDTH],queue_out[PAGETABLE_INDEX_BIT+PAGE_BIT-1:PAGE_BIT]};	
						queue_out_reg <= queue_out;
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
						m_raddr <= pt_rdata|queue_out_reg[PAGE_BIT-1:0];
						DM_read_state <= DM_R_IDLE;
					end
				end
				default;
			endcase
		end
	end
	//read data port
	reg [LINE_SIZE-1:0] p_rdata_buf;
	always @(posedge aclk or negedge aresetn) begin
		if(~aresetn) begin
			p_rdata_valid <= 'b0;
			p_rdata_buf <= 'b0;
		end
		else begin
			if(m_rdata_valid) begin
				p_rdata_valid <= 1'b1;
				p_rdata <= {id_queue_out,m_rdata};
			end
			else if(p_rdata_valid==1'b1) begin
				p_rdata_valid <= 1'b0;
				p_rdata <= p_rdata;
			end
			else begin
				p_rdata_valid <= p_rdata_valid;
				p_rdata <= p_rdata;
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
	parameter integer PE_ADDR_WIDTH = 40,
	parameter integer LINE_SIZE = 512,	
	parameter integer NUM_DATA_OBJECT = 3	
) (
	input wire aclk,
	input wire aresetn,
	output reg [PAGETABLE_INDEX_BIT+NUM_DATA_OBJECT-1:0] pt_raddr,
	output reg pt_ren,
	input wire [PAGETABLE_LINE_WIDTH-1:0] pt_rdata,
	//slave
	input wire [PE_ADDR_WIDTH+NUM_DATA_OBJECT-1:0] p_waddr,
	input wire [LINE_SIZE-1:0] p_wdata,
	input wire p_wen,
	output wire p_wready,

	//master
	output reg [ADDR_WIDTH-1:0] m_waddr,
	output reg [LINE_SIZE-1:0] m_wdata,
	output reg m_wen,
	input wire m_wready	
);
	//write address&data port
	wire [PE_ADDR_WIDTH+LINE_SIZE+NUM_DATA_OBJECT-1:0] queue_out;
	localparam LINEoffset_bit = $clog2(LINE_SIZE/8);
	localparam writeSTATE_BIT = 3;
	localparam [writeSTATE_BIT-1:0]
		DM_W_IDLE = 0,
		DM_W_PTREAD = 1,
		DM_W_AXIREAD = 2;
	reg [writeSTATE_BIT-1:0] DM_write_state;	
	wire write_queue_empty;
	wire [NUM_DATA_OBJECT-1:0] object_id;
	reg [PE_ADDR_WIDTH+LINE_SIZE+NUM_DATA_OBJECT-1:0] queue_out_reg;
	assign object_id = queue_out_reg[PE_ADDR_WIDTH+NUM_DATA_OBJECT+LINE_SIZE-1:PE_ADDR_WIDTH+LINE_SIZE];
	wire queue_FULL;
	assign p_wready = ~queue_FULL;
	
	queue #(
		.WIDTH(NUM_DATA_OBJECT+PE_ADDR_WIDTH+LINE_SIZE), //OBID+ADDR+DATA
		.DEPTH(NUM_DATA_OBJECT+1)
	) write_queue (
		.aclk       (aclk),
		.aresetn    (aresetn),
		.dataIn     ({p_waddr, p_wdata}),
		.RD         (!write_queue_empty&&m_wready&&(DM_write_state==DM_W_IDLE)),
		.WR         (p_wen),
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
			queue_out_reg <= 'b0;
		end
		else begin
			case(DM_write_state) //need to optimization
				DM_W_IDLE: begin
					if(!write_queue_empty&&m_wready) begin
						DM_write_state <= DM_W_AXIREAD;
						pt_ren <= 1'b1;
						pt_raddr <= {queue_out[PE_ADDR_WIDTH+NUM_DATA_OBJECT-1+LINE_SIZE:PE_ADDR_WIDTH+LINE_SIZE],queue_out[PAGETABLE_INDEX_BIT+PAGE_BIT-1+LINE_SIZE:PAGE_BIT+LINE_SIZE]};	//+PAGETABLE_SIZE/object_id;
						queue_out_reg <= queue_out;
						
					end					
					else begin	
						DM_write_state <= DM_W_IDLE;
						pt_ren <= 1'b0;
						pt_raddr <= 'b0;
						queue_out_reg <= queue_out_reg;
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
						m_waddr <= pt_rdata|{queue_out_reg[PAGE_BIT+LINE_SIZE-1:LINEoffset_bit+LINE_SIZE],{(LINEoffset_bit){1'b0}}};
						m_wdata <= queue_out_reg[LINE_SIZE-1:0];
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
					queue_out_reg <= queue_out_reg;
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