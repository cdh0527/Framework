//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) 
//Date        : 2021-03-01
//Host        : Duheon, dooheon0527@gmail.com
//Design      : arbiter
//Version     : 0.1
//--------------------------------------------------------------------------------
module mem_bus #(
	parameter integer PE_ADDR_WIDTH = 40,
	parameter integer DATA_WIDTH = 512,
	parameter integer NUM_DATA_OBJECT = 3
)(
	input wire aclk,
	input wire aresetn,
	//master
	input wire [NUM_DATA_OBJECT*PE_ADDR_WIDTH-1:0] p_raddr,
	input wire [NUM_DATA_OBJECT*PE_ADDR_WIDTH-1:0] p_waddr,
	input wire [NUM_DATA_OBJECT*DATA_WIDTH-1:0] p_wdata,
	input wire [NUM_DATA_OBJECT-1:0] p_ren,
	input wire [NUM_DATA_OBJECT-1:0] p_wen,
	output wire [NUM_DATA_OBJECT*DATA_WIDTH-1:0] p_rdata,
	output wire [NUM_DATA_OBJECT-1:0] p_rdata_valid,
	output wire [NUM_DATA_OBJECT-1:0] p_rready,
	output wire [NUM_DATA_OBJECT-1:0] p_wready,
	//slave
	output wire [PE_ADDR_WIDTH+NUM_DATA_OBJECT-1:0] m_raddr,
	output wire [PE_ADDR_WIDTH+NUM_DATA_OBJECT-1:0] m_waddr,
	output wire [DATA_WIDTH-1:0] m_wdata,
	output wire m_ren,
	output wire m_wen,
	input wire [DATA_WIDTH+NUM_DATA_OBJECT-1:0] m_rdata,
	input wire m_rdata_valid,
	input wire m_rready,
	input wire m_wready
);
	localparam SEL_WIDTH = ((NUM_DATA_OBJECT > 1) ? $clog2(NUM_DATA_OBJECT) : 1);
	wire [SEL_WIDTH-1:0] read_sel, write_sel;
	wire [NUM_DATA_OBJECT-1:0] read_grant, write_grant;
	wire read_act, write_act;
	//read_port
	wire [PE_ADDR_WIDTH-1:0] p_raddr_trans [0:NUM_DATA_OBJECT-1];
	wire p_ren_trans [0:NUM_DATA_OBJECT-1];
	//manage priority
	arbiter #(
		.NUM_PORTS(NUM_DATA_OBJECT)
	) read_arbiter (
		.aclk(aclk),
		.aresetn(aresetn),
		.request(p_ren),
		.grant(read_grant),
		.select(read_sel),
		.active(read_act)
	);
	//when receive read data, decoding the data and routing to master by read_id
	wire [NUM_DATA_OBJECT-1:0] m_read_id;
	assign m_read_id = (m_rdata_valid)?m_rdata[DATA_WIDTH+NUM_DATA_OBJECT-1:DATA_WIDTH]:0;
	genvar i;
	generate
	for(i=0 ; i<NUM_DATA_OBJECT ; i=i+1) begin
		//master
		assign p_raddr_trans[i] = p_raddr[(i+1)*PE_ADDR_WIDTH-1:i*PE_ADDR_WIDTH];
		assign p_ren_trans[i] = p_ren[(i+1)-1:i];
		//slave
		assign p_rready[i] = (read_grant[i])?m_rready:0;
		assign p_rdata[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH] = m_rdata[DATA_WIDTH-1:0];
		assign p_rdata_valid[i] = (m_read_id==(1<<i))?1'b1:1'b0;
	end
	endgenerate
	assign m_raddr = (read_act)?{read_grant, p_raddr_trans[read_sel]}:0;
	assign m_ren = (read_act)?p_ren_trans[read_sel]:0;
	
	//write_port
	arbiter #(
		.NUM_PORTS(NUM_DATA_OBJECT)
	) write_arbiter (
		.aclk(aclk),
		.aresetn(aresetn),
		.request(p_wen),
		.grant(write_grant),
		.select(write_sel),
		.active(write_act)
	);
	wire [PE_ADDR_WIDTH-1:0] p_waddr_trans [0:NUM_DATA_OBJECT-1];
	wire [DATA_WIDTH-1:0] p_wdata_trans [0:NUM_DATA_OBJECT-1];
	wire p_wen_trans [0:NUM_DATA_OBJECT-1];	
	
	generate
	for(i=0 ; i<NUM_DATA_OBJECT ; i=i+1) begin
		assign p_wready[i] = (write_grant[i])?m_wready:0;
		assign p_waddr_trans[i] = p_waddr[(i+1)*PE_ADDR_WIDTH-1:i*PE_ADDR_WIDTH];
		assign p_wdata_trans[i] = p_wdata[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH];
		assign p_wen_trans[i] = p_wen[(i+1)-1:i];
	end
	endgenerate
	assign m_waddr = (write_act)?{write_grant, p_waddr_trans[write_sel]}:0;
	assign m_wdata = (write_act)?p_wdata_trans[write_sel]:0;
	assign m_wen = (write_act)?p_wen_trans[write_sel]:0;

endmodule

//arbiter code is referred to https://github.com/bmartini/verilog-arbiter
module arbiter #(
	parameter integer NUM_PORTS = 3,
	parameter integer SEL_WIDTH = ((NUM_PORTS > 1) ? $clog2(NUM_PORTS) : 1)
	)(
		input aclk,
		input aresetn,
		input [NUM_PORTS-1:0]  request,
		output reg [NUM_PORTS-1:0]  grant,
		output reg [SEL_WIDTH-1:0]  select,
		output reg                  active
	);
	localparam WRAP_LENGTH = 2*NUM_PORTS;
	
    function [SEL_WIDTH-1:0] ff1 (
        input [NUM_PORTS-1:0] in
    );
        reg     set;
        integer i;

        begin
            set = 1'b0;
            ff1 = 'b0;
            for (i = 0; i < NUM_PORTS; i = i + 1) begin
                if (in[i] & ~set) begin
                    set = 1'b1;
                    ff1 = i[0 +: SEL_WIDTH];
                end
            end
        end
    endfunction	
	
	integer yy;
    wire                    next;
    wire [NUM_PORTS-1:0]    order;

    reg  [NUM_PORTS-1:0]    token;
    wire [NUM_PORTS-1:0]    token_lookahead [NUM_PORTS-1:0];
    wire [WRAP_LENGTH-1:0]  token_wrap;

	assign token_wrap   = {token, token};
	assign next         = ~|(token & request);
	
    always @(posedge aclk)
        grant <= token & request;	
    always @(posedge aclk)
        select <= ff1(token & request);
    always @(posedge aclk)
        active <= |(token & request);
	
    always @(posedge aclk) begin
        if (~aresetn) begin
			token <= 'b1;
		end
        else if (next) begin
            for (yy = 0; yy < NUM_PORTS; yy = yy + 1) begin : TOKEN_

                if (order[yy]) begin
                    token <= token_lookahead[yy];
                end
            end
        end	
	end
	
   /* always @(*) begin
        if (~aresetn) begin
			token = 'b1;
		end
        else if (next) begin
            for (yy = 0; yy < NUM_PORTS; yy = yy + 1) begin : TOKEN_

                if (order[yy]) begin
                    token = token_lookahead[yy];
                end
            end
        end
	end	*/
    genvar xx;
    generate
        for (xx = 0; xx < NUM_PORTS; xx = xx + 1) begin : ORDER_

            assign token_lookahead[xx]  = token_wrap[xx +: NUM_PORTS];

            assign order[xx]            = |(token_lookahead[xx] & request);

        end
    endgenerate	
endmodule