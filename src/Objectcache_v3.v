//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) 
//Date        : 2021-03-03
//Host        : Duheon
//Design      : Object cache
//Version     : 1.0
//--------------------------------------------------------------------------------
`timescale 1 ns / 1 ps
`define C_LOG_2(n) (\
(n) <= (1<<0) ? 0 : (n) <= (1<<1) ? 1 :\
(n) <= (1<<2) ? 2 : (n) <= (1<<3) ? 3 :\
(n) <= (1<<4) ? 4 : (n) <= (1<<5) ? 5 :\
(n) <= (1<<6) ? 6 : (n) <= (1<<7) ? 7 :\
(n) <= (1<<8) ? 8 : (n) <= (1<<9) ? 9 :\
(n) <= (1<<10) ? 10 : (n) <= (1<<11) ? 11 :\
(n) <= (1<<12) ? 12 : (n) <= (1<<13) ? 13 :\
(n) <= (1<<14) ? 14 : (n) <= (1<<15) ? 15 :\
(n) <= (1<<16) ? 16 : (n) <= (1<<17) ? 17 :\
(n) <= (1<<18) ? 18 : (n) <= (1<<19) ? 19 :\
(n) <= (1<<20) ? 20 : (n) <= (1<<21) ? 21 :\
(n) <= (1<<22) ? 22 : (n) <= (1<<23) ? 23 :\
(n) <= (1<<24) ? 24 : (n) <= (1<<25) ? 25 :\
(n) <= (1<<26) ? 26 : (n) <= (1<<27) ? 27 :\
(n) <= (1<<28) ? 28 : (n) <= (1<<29) ? 29 :\
(n) <= (1<<30) ? 30 : (n) <= (1<<31) ? 31 : 32)

module objectCache_v3 #(
	parameter integer WORD_SIZE_BYTE = 4,
	parameter integer WORD_SIZE_BYTE_BIT = $clog2(WORD_SIZE_BYTE),
	parameter integer LINE_SIZE_BYTE = 64,
	parameter integer PE_ADDR_WIDTH = 40,
	parameter integer NUM_ENTRY_BIT = 1,
	parameter integer WORD_SIZE = WORD_SIZE_BYTE*8,
	parameter integer LINE_SIZE = LINE_SIZE_BYTE*8,
	parameter integer OBJECT_ID = 1,
	parameter integer OBJECT_ID_WIDTH_BIT = 2
) (
	input wire aclk,
	input wire aresetn,
	//slave port
	input wire [PE_ADDR_WIDTH-1:0] p_addr,
	input wire [WORD_SIZE-1:0] p_wdata,
	input wire p_ren,
	input wire p_wen,
	output wire [WORD_SIZE-1:0] p_rdata,
	output wire p_data_valid,
	//master port
	output reg [PE_ADDR_WIDTH-1:0] m_raddr,
	output reg [PE_ADDR_WIDTH-1:0] m_waddr,
	output reg [LINE_SIZE-1:0] m_wdata,
	output reg m_ren,
	output reg m_wen,
	input wire [LINE_SIZE-1:0] m_rdata,
	input wire m_rdata_valid,
	input wire m_rready,
	input wire m_wready,
	//control port
	output reg c_finish_complete,
	input c_finish
);
	localparam STATE_BIT = 10;
	localparam [STATE_BIT-1:0]
		S_RUN = 1,
		S_FETCH_1 = 2,
		S_FETCH_2 = 4,
		S_FETCH_3 = 8,
		S_WB_1 = 16,
		S_WB_2 = 32,
		S_FLUSH = 64,
		S_FINISH = 128,
		S_INVALID = 256,
		S_ERROR = 512;
	localparam [STATE_BIT-1:0]
		S_RUN_BIT = 0,
		S_FETCH_1_BIT = 1,
		S_FETCH_2_BIT = 2,
		S_FETCH_3_BIT = 3,
		S_WB_1_BIT = 4,
		S_WB_2_BIT = 5,
		S_FLUSH_BIT = 6,
		S_FINISH_BIT = 7,
		S_INVALID_BIT = 8,
		S_ERROR_BIT = 9;
	localparam WORD_OFFSET = `C_LOG_2(LINE_SIZE_BYTE/WORD_SIZE_BYTE);
	localparam BYTE_OFFSET = `C_LOG_2(WORD_SIZE_BYTE);
	localparam LINE_SIZE_BIT = `C_LOG_2(LINE_SIZE_BYTE);
	localparam MAX_ENRTY = (2**NUM_ENTRY_BIT);
	
	wire [PE_ADDR_WIDTH-1:0] p_addr_shift = p_addr << WORD_SIZE_BYTE_BIT;
	wire [NUM_ENTRY_BIT-1:0] entry, run_entry;
	wire [PE_ADDR_WIDTH-NUM_ENTRY_BIT-LINE_SIZE_BIT-1:0] o_tag;
	wire [LINE_SIZE_BYTE*8-1:0] writedata;
	wire [WORD_SIZE_BYTE-1:0] byte_en;
	wire [LINE_SIZE_BYTE/WORD_SIZE_BYTE-1:0] word_en;
	wire [LINE_SIZE_BYTE*8-1:0] readdata;
	wire [PE_ADDR_WIDTH-1:0] wb_addr;
	wire hit;
	wire modify;
	wire miss;
	wire valid;
	wire read_miss;
	wire set_write, hit_write;
	wire invalid;
	wire dirty;

	reg finish_mode;
	reg [NUM_ENTRY_BIT:0] flush_entry;

	assign entry = finish_mode ? flush_entry : run_entry;
		
	set #(
		.WORD_SIZE_BYTE(WORD_SIZE_BYTE),
		.LINE_SIZE_BYTE(LINE_SIZE_BYTE),
		.PE_ADDR_WIDTH(PE_ADDR_WIDTH),
		.NUM_ENTRY_BIT(NUM_ENTRY_BIT)
	)
	set0(
		.aclk		(aclk),
		.aresetn    (aresetn),
		.entry      (entry),
		.o_tag      (o_tag),
		.writedata  (writedata),
		.byte_en    (byte_en),
		.write      (set_write),
		.word_en    (word_en),
		.readdata   (readdata),
		.wb_addr	(wb_addr),
		.hit        (hit),
		.modify     (modify),
		.miss       (miss),
		.valid      (valid),
		.dirty      (dirty),
		.read_miss	((p_ren&&!p_wen)),
		.invalid    (invalid)
	);
	
	reg [STATE_BIT-1:0] Cache_CS, Cache_NS;
	always @(*) begin	
		case(Cache_CS)
			S_RUN: begin
			    if((c_finish||finish_mode)&&(flush_entry==0)) begin
					Cache_NS = S_FINISH;
				end
				else begin
				    if(miss&(p_ren|p_wen)) begin
				    	Cache_NS = S_FETCH_1;
				    end
				    else if(modify&(p_ren|p_wen)) begin
				    	Cache_NS = S_WB_1;
				    end
				    else begin
				    	Cache_NS = S_RUN;
				    end
				end
			end
			S_FETCH_1: begin//wait ready
				if(c_finish||finish_mode) begin
				    Cache_NS = S_RUN;
				end
				else begin
				    if(m_rready) begin 
				    	Cache_NS = S_FETCH_2;
				    end
				    else begin
				    	Cache_NS = S_FETCH_1;
				    end
				end
			end
			S_FETCH_2: begin//wait data
				if(c_finish||finish_mode) begin
				    Cache_NS = S_RUN;
				end			
				else begin
				    if(m_rdata_valid&(p_ren|p_wen)) begin					
				    	Cache_NS = S_RUN;
				    end
				    else begin
				    	Cache_NS = S_FETCH_2;
				    end
				end
			end			
			S_WB_1:begin
				if(m_wready) begin 
					if(finish_mode) begin
						Cache_NS = S_INVALID;
					end
					else begin
						Cache_NS = S_FETCH_1;
					end
				end
				else begin
					Cache_NS = S_WB_1;
				end				
			end	
			S_FINISH: begin
				if(flush_entry == MAX_ENRTY) begin
					Cache_NS = S_RUN;
				end
				else begin
					Cache_NS = S_FLUSH;
				end
			end
			S_FLUSH: begin
				if(dirty) begin
					Cache_NS = S_WB_1;
				end
				else begin
					Cache_NS = S_INVALID;
				end
			end
			S_INVALID: begin
				Cache_NS = S_FINISH;
			end
		endcase
	end
	always @ (posedge aclk) begin
		if(~aresetn) begin
			Cache_CS <= S_RUN;
		end
		else begin
			Cache_CS <= Cache_NS;
		end
	end	
	//read hit
	wire [WORD_SIZE_BYTE*8-1:0] readdata_wire[LINE_SIZE_BYTE/WORD_SIZE_BYTE-1:0];
	wire [LINE_SIZE_BYTE*8-1:0] writedata_wire;
	wire [LINE_SIZE_BYTE*8-1:0] fetched_data;
										  
	wire [LINE_SIZE_BYTE/WORD_SIZE_BYTE-1:0] word_en_wire;

    genvar i;
	generate
	for (i=0 ; i<LINE_SIZE_BYTE/WORD_SIZE_BYTE ; i=i+1) begin
		assign readdata_wire[i] = Cache_CS[S_RUN_BIT]?readdata[(i+1)*WORD_SIZE_BYTE*8-1:i*WORD_SIZE_BYTE*8]:m_rdata[(i+1)*WORD_SIZE_BYTE*8-1:i*WORD_SIZE_BYTE*8];
		assign writedata_wire[(i+1)*WORD_SIZE_BYTE*8-1:i*WORD_SIZE_BYTE*8] = p_wdata;
		assign word_en_wire[i] = (p_addr_shift[WORD_OFFSET+BYTE_OFFSET-1:BYTE_OFFSET]==i);					
		assign fetched_data[(i+1)*WORD_SIZE_BYTE*8-1:i*WORD_SIZE_BYTE*8] = ((p_addr_shift[WORD_OFFSET-1:0]==i)&&(p_wen))?p_wdata:m_rdata[(i+1)*WORD_SIZE_BYTE*8-1:i*WORD_SIZE_BYTE*8];		//for write miss												 
	end
	endgenerate
	assign p_rdata = readdata_wire[p_addr_shift[WORD_OFFSET+BYTE_OFFSET-1:BYTE_OFFSET]];
	assign p_data_valid = (Cache_CS[S_RUN_BIT]?hit:(Cache_CS[S_FETCH_2_BIT]?m_rdata_valid:0))&&p_ren;
	assign hit_write = Cache_CS[S_RUN_BIT]&&hit&&p_wen;
	assign o_tag = (Cache_CS[S_RUN_BIT]|Cache_CS[S_WB_1_BIT]) ? p_addr_shift[PE_ADDR_WIDTH-1:NUM_ENTRY_BIT+LINE_SIZE_BIT]:m_raddr[PE_ADDR_WIDTH-1:NUM_ENTRY_BIT+LINE_SIZE_BIT];
	assign run_entry = (Cache_CS[S_RUN_BIT]|Cache_CS[S_WB_1_BIT]) ? p_addr_shift[NUM_ENTRY_BIT+LINE_SIZE_BIT-1:LINE_SIZE_BIT]:(finish_mode)?flush_entry:m_raddr[NUM_ENTRY_BIT+LINE_SIZE_BIT-1:LINE_SIZE_BIT];	
	assign writedata = Cache_CS[S_RUN_BIT]?writedata_wire:fetched_data;
	assign byte_en = {(WORD_SIZE_BYTE){1'b1}};
	assign set_write = finish_mode?invalid:(Cache_CS[S_RUN_BIT]?hit_write:m_rdata_valid);
	assign word_en = Cache_CS[S_RUN_BIT]?word_en_wire:((Cache_CS[S_FETCH_2_BIT]&&m_rdata_valid)?{(LINE_SIZE_BYTE/WORD_SIZE_BYTE){1'b1}}:0);
		
	always @ (posedge aclk) begin
		if(~aresetn) begin	
			m_ren <= 'b0;
			m_raddr <= 'b0;
		end
		else begin
			if(Cache_NS[S_FETCH_1_BIT]&&!Cache_CS[S_FETCH_1_BIT]) begin
				m_ren <= 1'b1;
				m_raddr <= p_addr_shift;			
			end
			else if(Cache_NS[S_RUN_BIT]||(Cache_NS[S_FETCH_2_BIT]&&!Cache_CS[S_FETCH_2_BIT])) begin
				m_ren <= 1'b0;
				m_raddr <= m_raddr;
			end
			else begin
				m_ren <= m_ren;
				m_raddr <= m_raddr;
			end
		end
	end
	always @ (posedge aclk) begin
		if(~aresetn) begin	
			m_wen <= 1'b0;
			m_waddr <= 'b0;
			m_wdata <= 'b0;
		end
		else begin
			if(Cache_NS[S_WB_1_BIT]&&!Cache_CS[S_WB_1_BIT]) begin
				m_wen <= 1'b1;
				m_waddr <= wb_addr<<LINE_SIZE_BIT;
				m_wdata <= readdata;
			end
			else if(!Cache_NS[S_WB_1_BIT]&&Cache_CS[S_WB_1_BIT]) begin
				m_wen <= 1'b0;	
				m_waddr <= m_waddr;
				m_wdata <= m_wdata;
			end
			else begin
				m_wen <= m_wen;
				m_waddr <= m_waddr;
				m_wdata <= m_wdata;
			end
		end
	end
	//for finish state
	always @ (posedge aclk) begin
		if(~aresetn) begin	
			finish_mode <= 'b0;
			c_finish_complete <= 'b0;
		end
		else if(Cache_NS[S_FINISH_BIT]&&Cache_CS[S_RUN_BIT]) begin
			finish_mode <= 1;
			c_finish_complete <= 0;
		end
		else if(Cache_NS[S_RUN_BIT]&&Cache_CS[S_FINISH_BIT]) begin
			finish_mode <= 0;
			c_finish_complete <= 1;
		end
		else begin
			finish_mode <= finish_mode;
			c_finish_complete <= 0;
		end
	end
	always @ (posedge aclk) begin
		if(~aresetn||Cache_CS[S_RUN_BIT]) begin		
			flush_entry <= 'b0;
		end
		else begin
			if(Cache_NS[S_FINISH_BIT]&&(Cache_CS[S_INVALID_BIT])) begin
				flush_entry <= flush_entry+1;
			end
		end
	end
	assign invalid = Cache_CS[S_INVALID_BIT]&&finish_mode;

endmodule

module set # (
	parameter integer WORD_SIZE_BYTE = 4,
	parameter integer LINE_SIZE_BYTE = 64,
	parameter integer PE_ADDR_WIDTH = 40,
	parameter integer NUM_ENTRY_BIT = 1,
	parameter integer LINE_SIZE_BIT = `C_LOG_2(LINE_SIZE_BYTE)
) (
	input wire aclk,
	input wire aresetn,
	input wire [NUM_ENTRY_BIT-1:0] entry,
	input wire [PE_ADDR_WIDTH-NUM_ENTRY_BIT-LINE_SIZE_BIT-1:0] o_tag,
	input wire [LINE_SIZE_BYTE*8-1:0] writedata,
	input wire [WORD_SIZE_BYTE-1:0] byte_en,
	input wire write,
	input wire [LINE_SIZE_BYTE/WORD_SIZE_BYTE-1:0] word_en,
	output wire [LINE_SIZE_BYTE*8-1:0] readdata,
	output wire [PE_ADDR_WIDTH-1:0] wb_addr,
	output wire hit,
	output wire modify,
	output wire miss,
	output wire valid,
	output wire dirty,
	input wire read_miss,
	input wire invalid
);
	wire [PE_ADDR_WIDTH-NUM_ENTRY_BIT-LINE_SIZE_BIT-1:0] i_tag;
	wire [PE_ADDR_WIDTH-NUM_ENTRY_BIT-LINE_SIZE_BIT-1+2:0] write_tag_entry;
	
	assign wb_addr = {i_tag, entry};
	
    assign hit = valid && (o_tag == i_tag);
    assign modify = valid && (o_tag != i_tag) && dirty; //if line eviction is occurred, it must writeback
    assign miss = !valid || ((o_tag != i_tag) && !dirty); //miss occurr and don't need to writeback
	
	genvar i,j;
	generate
	for(i=0 ; i<LINE_SIZE_BYTE/WORD_SIZE_BYTE ; i=i+1) begin:MAKE_LINE
		for(j=0 ; j<WORD_SIZE_BYTE ; j=j+1) begin:MAKE_WORD
			simple_ram #(.width(8), .widthad(NUM_ENTRY_BIT)
			) byte_ram (
			     .clk(aclk),
			     .wraddress(entry),
			     .wren(write&&word_en[i]&&byte_en[j]),
			     .data(writedata[((j+1)*8+i*WORD_SIZE_BYTE*8):(j*8+i*WORD_SIZE_BYTE*8)]), 
			     .rdaddress(entry), 
			     .q(readdata[((j+1)*8+i*WORD_SIZE_BYTE*8):(j*8+i*WORD_SIZE_BYTE*8)])
			);
		end
	end
	endgenerate
	//write_tag_entry = {dirty, valid, tag}
	assign write_tag_entry = (invalid)? {1'b0, 1'b0, {(PE_ADDR_WIDTH-NUM_ENTRY_BIT-LINE_SIZE_BIT){1'b0}}} : //if invalid set zeros
								(read_miss) ? {1'b0, 1'b1, o_tag} : //if read miss 
								(modify || miss ) ? {1'b1, 1'b1, o_tag} : //write miss
									{1'b1, 1'b1, i_tag}; //write hit?
	
	simple_ram #(
	   .width(PE_ADDR_WIDTH-NUM_ENTRY_BIT-LINE_SIZE_BIT+2),
	   .widthad(NUM_ENTRY_BIT)
	) ram_tag (
	   .clk(aclk), 
	   .wraddress(entry), 
	   .wren(write), 
	   .data(write_tag_entry), 
	   .rdaddress(entry), 
	   .q({dirty, valid, i_tag})
	);
	

    integer k;

    initial begin
        for(k = 0; k <=(NUM_ENTRY_BIT); k=k+1) begin
	        ram_tag.mem[k] = {2'b0,{(PE_ADDR_WIDTH-NUM_ENTRY_BIT-LINE_SIZE_BIT-1){1'b1}}};
        end
    end
	  
endmodule