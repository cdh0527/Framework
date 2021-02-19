//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) 
//Date        : 2021-02-09
//Host        : Duheon
//Design      : Object cache
//Version     : 0.1
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

module objectCache #(
	parameter integer WORD_SIZE_BYTE = 4,
	parameter integer LINE_SIZE_BYTE = 64,
	parameter integer ADDR_WIDTH = 40,
	parameter integer NUM_ENTRY_BIT = 1,
	parameter integer WORD_SIZE = WORD_SIZE_BYTE*8
) (
	input wire aclk,
	input wire aresetn,
	//slave port
	input wire [ADDR_WIDTH-1:0] s_addr,
	input wire [WORD_SIZE-1:0] s_wdata,
	input wire s_ren,
	input wire s_wen,
	output reg [WORD_SIZE-1:0] s_rdata,
	output reg s_data_valid,
	//master port
	output reg [ADDR_WIDTH-1:0] m_addr,
	output reg [WORD_SIZE-1:0] m_wdata,
	output reg m_ren,
	output reg m_wen,
	input wire [WORD_SIZE-1:0] m_rdata,
	input wire m_rdata_valid,
	input wire m_ready
);
	
	localparam [8:0]
		S_IDLE = 0,
		S_CMP = 1,
		S_HIT = 2,
		S_FETCH_1 = 4,
		S_FETCH_2 = 8,
		S_FETCH_3 = 16,
		S_WB_1 = 32,
		S_WB_2 = 64;
		S_ERROR = 128;
	localparam STATE_BIT = 9;
	localparam WORD_OFFSET = 'C_LOG_2(LINE_SIZE_BYTE/WORD_SIZE_BYTE);
		
	wire [NUM_ENTRY_BIT-1:0] entry;
	wire [ADDR_WIDTH-NUM_ENTRY_BIT-1:0] o_tag;
	wire [LINE_SIZE_BYTE*8-1:0] writedata;
	reg [LINE_SIZE_BYTE*8-1:0] writedata_buf;
	wire [WORD_SIZE_BYTE-1:0] byte_en;
	wire set_write;
	wire hit_write;
	wire [LINE_SIZE_BYTE/WORD_SIZE_BYTE-1:0] word_en;
	wire [LINE_SIZE_BYTE*8-1:0] readdata;
	wire hit;
	wire modify;
	wire miss;
	wire valid;
	wire read_miss;
	reg s_ren_buf, s_wen_buf;
	
	assign entry = (Cache_CS==S_FETCH&&m_rdata_valid) ? m_addr[ADDR_WIDTH-1:NUM_ENTRY_BIT] : s_addr[ADDR_WIDTH-1:NUM_ENTRY_BIT];
	assign o_tag = (Cache_CS==S_FETCH&&m_rdata_valid) ? m_addr[NUM_ENTRY_BIT-1:0] : s_addr[NUM_ENTRY_BIT-1:0];
		
	set #(
		.WORD_SIZE_BYTE(WORD_SIZE_BYTE),
		.LINE_SIZE_BYTE(LINE_SIZE_BYTE),
		.ADDR_WIDTH(ADDR_WIDTH),
		.NUM_ENTRY_BIT(NUM_ENTRY_BIT),
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
		.hit        (hit),
		.modify     (modify),
		.miss       (miss),
		.valid      (valid),
		.read_miss	(read_miss),
		.invalid    (0)
	);
	assign byte_en = {{WORD_SIZE_BYTE}1'b1}

	reg [STATE_BIT-1:0] Cache_CS, Cache_NS;
	always @(*) begin	
		case(Cache_CS)
			S_IDLE: begin
				if(s_wen||s_ren) begin
					Cache_NS = S_CMP;
				end
				else begin
					Cache_NS = S_IDLE;
				end
			end
			S_CMP: begin
				if(hit) begin
					Cache_NS = S_HIT;
				end
				else if(miss&modify) begin
					Cache_NS = S_WB;
				end
				else if(miss&~modify) begin
					Cache_NS = S_FETCH_1;
				end
				else begin
					Cache_NS = C_CMP;
				end
			end
			S_FETCH_1: begin//wait ready
				if(m_ready) begin 
					Cache_NS = S_FETCH_2;
				end
				else begin
					Cache_NS = S_FETCH_1;
				end
			end
			S_FETCH_2: begin//wait data
				if(m_rdata_valid) begin
					
					Cache_NS = S_FETCH_3;
				end
				else begin
					Cache_NS = S_FETCH_2;
				end
			end			
			S_HIT: begin
				Cache_NS = S_IDLE;
			end
		endcase
	end
	always @ (posedge aclk) begin
		if(~resetn) begin
			Cache_CS <= S_IDLE;
		end
		else begin
			Cache_CS <= Cache_NS;
		end
	end
	
	
	genvar i;
	reg [WORD_SIZE_BYTE*8-1:0] readdata_buf[LINE_SIZE_BYTE/WORD_SIZE_BYTE-1:0];
	reg word_en_buf [LINE_SIZE_BYTE/WORD_SIZE_BYTE-1:0];
	generate
	for (i=0 ; i<LINE_SIZE_BYTE/WORD_SIZE_BYTE ; i=i+1) begin
	always @ (posedge aclk) begin
		if(~resetn) begin
			writedata_buf[(i+1)*WORD_SIZE_BYTE*8-1:i*WORD_SIZE_BYTE*8] <= {(WORD_SIZE_BYTE*8)1'b0};
			word_en_buf[i]=1'b0;
		end
		else begin
			if(Cache_CS[S_IDLE]) begin//write hit
				writedata_buf[(i+1)*WORD_SIZE_BYTE*8-1:i*WORD_SIZE_BYTE*8] <= s_wdata;
				word_en_buf[i] <= (s_addr[WORD_OFFSET-1:0]==i);
			end
		end
	end	
	assign word_en[i] = word_en_buf[i];
	always @ (posedge aclk) begin
		if(~resetn) begin
			readdata_buf[i] <= {(WORD_SIZE_BYTE*8)1'b0}
		end
		else begin
			if(Cache_CS[CMP]) begin//read hit
				readdata_buf[i] <= readdata[(i+1)*WORD_SIZE_BYTE*8-1:i*WORD_SIZE_BYTE*8];
			end
		end
	end	
	endgenerate
	assign s_rdata = readdata_buf[s_addr[WORD_OFFSET-1:0]];
	always @ (posedge aclk) begin
		if(~resetn) begin
			s_data_valid <= 1'b0;
			hit_write <= 1'b0;
			s_ren_buf <= 1'b0;
			s_wen_buf <= 1'b0;
		end
		else begin			
			if(Cache_CS[C_IDLE]) begin
				s_ren_buf <= s_ren;
				s_wen_buf <= s_wen;
			end
			else begin
				s_ren_buf <= s_ren_buf;
				s_wen_buf <= s_wen_buf;
			end
			
			if(Cache_NS[C_HIT]&&(s_wen_buf||s_ren_buf)) begin
				s_data_valid <= 1'b1;
				if(s_wen_buf) begin
					hit_write <= 1'b1;
				end
			end
			else begin
				s_data_valid <= 1'b0;
				hit_write <= 1'b0;
			end
			
		end
	end
	
	
	
	
endmodule

module set # (
	parameter integer WORD_SIZE_BYTE = 4,
	parameter integer LINE_SIZE_BYTE = 64,
	parameter integer ADDR_WIDTH = 40,
	parameter integer NUM_ENTRY_BIT = 1,
)(
	input wire aclk,
	input wire aresetn,
	input wire [NUM_ENTRY_BIT-1:0] entry,
	input wire [ADDR_WIDTH-NUM_ENTRY_BIT-1:0] o_tag,
	input wire [LINE_SIZE_BYTE*8-1:0] writedata,
	input wire [WORD_SIZE_BYTE-1:0] byte_en,
	input wire write,
	input wire [LINE_SIZE_BYTE/WORD_SIZE_BYTE-1:0] word_en,
	output wire [LINE_SIZE_BYTE*8-1:0] readdata,
	output wire hit,
	output wire modify,
	output wire miss,
	output wire valid,
	input wire read_miss,
	input wire invalid
);
	wire [ADDR_WIDTH-NUM_ENTRY_BIT-1:0] i_tag;
	wire dirty;
	wire [ADDR_WIDTH-NUM_ENTRY_BIT-1+2:0] write_tag_entry;
	genvar i,j;
	generate
	for(i=0 ; i<LINE_SIZE_BYTE/WORD_SIZE_BYTE ; i=i+1) begin:MAKE_LINE
		for(j=0 ; j<WORD_SIZE_BYTE ; j=j+1) begin:MAKE_WORD
			simple_ram #(.width(8), .widthad(NUM_ENTRY_BIT)) byte_ram(.clk(aclk), .wraddress(entry), .wren(write&&word_en[i]&&byte_en[j]), .data(writedata[((j+1)*8+i*WORD_SIZE_BYTE*8):(j*8+i*WORD_SIZE_BYTE*8)]), .rdaddress(entry), .q(readdata[((j+1)*8+i*WORD_SIZE_BYTE*8):(j*8+i*WORD_SIZE_BYTE*8)]));
		end
	end
	endgenerate
	//write_tag_entry = {dirty, valid, tag}
	assign write_tag_entry = (invalid)? {1'b0, 1'b0, {(ADDR_WIDTH-NUM_ENTRY_BIT){1'b0}}} :(read_miss) ? {1'b0, 1'b1, o_tag} : (modify || miss ) ? {1'b1, 1'b1, o_tag} : {1'b1, 1'b1, i_tag};
	simple_ram #(.width(ADDR_WIDTH-NUM_ENTRY_BIT-1+2), .widthad(NUM_ENTRY_BIT)) ram_tag(aclk, entry, write, write_tag_entry, entry, {dirty, valid, i_tag});
	
`ifdef SIM
    integer k;

    initial begin
        for(k = 0; k <=(2**cache_entry-1); k=k+1) begin
	        ram_tag.mem[k] = 0;
        end
    end
`endif
endmodule