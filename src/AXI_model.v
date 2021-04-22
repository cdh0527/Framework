`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/15 17:40:32
// Design Name: 
// Module Name: AXI_model
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


module AXI_model(
   ACLK,
   ARESETN,
   APB_WADDR,
   APB_WDATA,
   APB_WENABLE,
   APB_WREADY,
   APB_RADDR,
   APB_RDATA,
   APB_RENABLE,
   APB_RREADY,
   APB_RVALID,
   finish
);
parameter OBID_BASE_BIT = 37;
parameter NUM_OBJECT = 3;
input ACLK;
input ARESETN;
input [39:0] APB_WADDR;
input [511:0] APB_WDATA;
input APB_WENABLE;
output reg APB_WREADY;
input [39:0] APB_RADDR;
output reg [511:0] APB_RDATA;
input APB_RENABLE;
output reg APB_RREADY;   
output reg APB_RVALID;
input finish;

reg axi_wvalid_l;
reg axi_rvalid_l;

reg signed [31:0] mem_a [1023:0];
reg signed [31:0] mem_x [1023:0];
reg signed [31:0] mem_y [1023:0];

initial $readmemh("a.mem", mem_a);
initial $readmemh("x.mem", mem_x);
initial $readmemh("y.mem", mem_y);

reg [2:0] mem_sel;    

always @(posedge ACLK)
begin
  axi_wvalid_l <= APB_WENABLE;
  axi_rvalid_l <= APB_RENABLE;
end
always @(posedge ACLK)
begin
    if(finish) begin
        $writememh("a.mem", mem_a);
        $writememh("x.mem", mem_x);
        $writememh("y.mem", mem_y);
    end
end

reg [39:0] waddr_reg;
reg [511:0] wdata_reg;

reg [3:0] axiw_cnt;
always @(negedge ARESETN or posedge ACLK)
begin
  if(~ARESETN)
  begin
    APB_WREADY <= 1;
    axiw_cnt <= 0;
	mem_sel <= 0;
	waddr_reg <= 0;
	wdata_reg <= 0;
  end
  else if(APB_WENABLE > axi_wvalid_l)
  begin
    APB_WREADY <= 0;
    axiw_cnt <= axiw_cnt + 1'b1;
	mem_sel <= 0;
	waddr_reg <= APB_WADDR;
	wdata_reg <= APB_WDATA;
  end
  else if(axiw_cnt == 3)
  begin
   APB_WREADY <= 1;
   axiw_cnt <= 0;
   mem_sel <= waddr_reg[OBID_BASE_BIT+NUM_OBJECT-1:OBID_BASE_BIT];
  end
  else if(axiw_cnt > 0)
  begin
    APB_WREADY <= APB_WREADY;
    axiw_cnt <= axiw_cnt + 1'b1; 
	mem_sel <= 0;     
	waddr_reg <= waddr_reg;
	wdata_reg <= wdata_reg;		
  end
  else begin
    APB_WREADY <= APB_WREADY;
    axiw_cnt <= axiw_cnt;
	mem_sel <= 0;
	waddr_reg <= waddr_reg;
	wdata_reg <= wdata_reg;	
  end
end
reg[31:0] acnt;
reg[4:0] axir_cnt;


always @(negedge ARESETN or posedge ACLK)
begin
  if(~ARESETN)
  begin
    APB_RREADY <= 1;
    axir_cnt <= 0;
	APB_RVALID <= 0;
   acnt <= 0;
  end
  else if(APB_RENABLE > axi_rvalid_l)
  begin
    APB_RREADY <= 0;
    axir_cnt <= axir_cnt + 1'b1;
	APB_RVALID <= 0;
  end
  else if(axir_cnt == 20)
  begin
   APB_RREADY <= 1;
   axir_cnt <= 0;
   APB_RVALID <= 1;
   case(APB_RADDR[OBID_BASE_BIT+NUM_OBJECT-1:OBID_BASE_BIT])
            3'd4: APB_RDATA <= {mem_a[APB_RADDR[11:2]+10'd15],  mem_a[APB_RADDR[11:2]+10'd14], 	mem_a[APB_RADDR[11:2]+10'd13],  mem_a[APB_RADDR[11:2]+10'd12],
								mem_a[APB_RADDR[11:2]+10'd11],  mem_a[APB_RADDR[11:2]+10'd10], 	mem_a[APB_RADDR[11:2]+10'd9],   mem_a[APB_RADDR[11:2]+10'd8],
								mem_a[APB_RADDR[11:2]+10'd7],  	mem_a[APB_RADDR[11:2]+10'd6], 	mem_a[APB_RADDR[11:2]+10'd5],  	mem_a[APB_RADDR[11:2]+10'd4],
								mem_a[APB_RADDR[11:2]+10'd3], 	mem_a[APB_RADDR[11:2]+10'd2], 	mem_a[APB_RADDR[11:2]+10'd1], 	mem_a[APB_RADDR[11:2]+10'd0]};
								//mem_a[APB_RADDR[11:2]+10'd16], mem_a[APB_RADDR[11:2]+10'd17], mem_a[APB_RADDR[11:2]+10'd18], mem_a[APB_RADDR[11:2]+10'd19],
								//mem_a[APB_RADDR[11:2]+10'd20], mem_a[APB_RADDR[11:2]+10'd21], mem_a[APB_RADDR[11:2]+10'd22], mem_a[APB_RADDR[11:2]+10'd23],
								//mem_a[APB_RADDR[11:2]+10'd24], mem_a[APB_RADDR[11:2]+10'd25], mem_a[APB_RADDR[11:2]+10'd26], mem_a[APB_RADDR[11:2]+10'd27],
								//mem_a[APB_RADDR[11:2]+10'd28], mem_a[APB_RADDR[11:2]+10'd29], mem_a[APB_RADDR[11:2]+10'd30], mem_a[APB_RADDR[11:2]+10'd31]};
            3'd2: APB_RDATA <= {mem_x[APB_RADDR[11:2]+10'd15],  mem_x[APB_RADDR[11:2]+10'd14], 	mem_x[APB_RADDR[11:2]+10'd13],  mem_x[APB_RADDR[11:2]+10'd12],
								mem_x[APB_RADDR[11:2]+10'd11],  mem_x[APB_RADDR[11:2]+10'd10], 	mem_x[APB_RADDR[11:2]+10'd9],   mem_x[APB_RADDR[11:2]+10'd8],
								mem_x[APB_RADDR[11:2]+10'd7],  	mem_x[APB_RADDR[11:2]+10'd6], 	mem_x[APB_RADDR[11:2]+10'd5],  	mem_x[APB_RADDR[11:2]+10'd4],
								mem_x[APB_RADDR[11:2]+10'd3], 	mem_x[APB_RADDR[11:2]+10'd2], 	mem_x[APB_RADDR[11:2]+10'd1], 	mem_x[APB_RADDR[11:2]+10'd0]};
								//mem_x[APB_RADDR[11:2]+10'd16], mem_x[APB_RADDR[11:2]+10'd17], mem_x[APB_RADDR[11:2]+10'd18], mem_x[APB_RADDR[11:2]+10'd19],
								//mem_x[APB_RADDR[11:2]+10'd20], mem_x[APB_RADDR[11:2]+10'd21], mem_x[APB_RADDR[11:2]+10'd22], mem_x[APB_RADDR[11:2]+10'd23],
								//mem_x[APB_RADDR[11:2]+10'd24], mem_x[APB_RADDR[11:2]+10'd25], mem_x[APB_RADDR[11:2]+10'd26], mem_x[APB_RADDR[11:2]+10'd27],
								//mem_x[APB_RADDR[11:2]+10'd28], mem_x[APB_RADDR[11:2]+10'd29], mem_x[APB_RADDR[11:2]+10'd30], mem_x[APB_RADDR[11:2]+10'd31]};
            3'd1: APB_RDATA <= {mem_y[APB_RADDR[11:2]+10'd15],  mem_y[APB_RADDR[11:2]+10'd14], 	mem_y[APB_RADDR[11:2]+10'd13],  mem_y[APB_RADDR[11:2]+10'd12],
								mem_y[APB_RADDR[11:2]+10'd11],  mem_y[APB_RADDR[11:2]+10'd10], 	mem_y[APB_RADDR[11:2]+10'd9],   mem_y[APB_RADDR[11:2]+10'd8],
								mem_y[APB_RADDR[11:2]+10'd7],  	mem_y[APB_RADDR[11:2]+10'd6], 	mem_y[APB_RADDR[11:2]+10'd5],  	mem_y[APB_RADDR[11:2]+10'd4],
								mem_y[APB_RADDR[11:2]+10'd3], 	mem_y[APB_RADDR[11:2]+10'd2], 	mem_y[APB_RADDR[11:2]+10'd1], 	mem_y[APB_RADDR[11:2]+10'd0]};
								//mem_y[APB_RADDR[11:2]+10'd16], mem_y[APB_RADDR[11:2]+10'd17], mem_y[APB_RADDR[11:2]+10'd18], mem_y[APB_RADDR[11:2]+10'd19],
								//mem_y[APB_RADDR[11:2]+10'd20], mem_y[APB_RADDR[11:2]+10'd21], mem_y[APB_RADDR[11:2]+10'd22], mem_y[APB_RADDR[11:2]+10'd23],
								//mem_y[APB_RADDR[11:2]+10'd24], mem_y[APB_RADDR[11:2]+10'd25], mem_y[APB_RADDR[11:2]+10'd26], mem_y[APB_RADDR[11:2]+10'd27],
								//mem_y[APB_RADDR[11:2]+10'd28], mem_y[APB_RADDR[11:2]+10'd29], mem_y[APB_RADDR[11:2]+10'd30], mem_y[APB_RADDR[11:2]+10'd31]};
            default : APB_RDATA <= 512'd1;
/*
            40'd0: APB_RDATA <= {32'h80000000,32'h00000003,32'h00000002,32'h00000002,32'h00000002,32'h40800000,32'h40a00000,32'h40c00000,32'h3f800000,32'h3f800000,32'h3f800000,32'h3f800000,32'h00000004,32'h00000004,32'h00000004,32'h00000004,
                                 64'h3f800000,64'h3f800000,64'h3f800000,64'h3f800000,64'h3f8000C0,64'h3f800180,64'h3f800100,64'h3f800080};
            40'd1: APB_RDATA <= {32'h80000000,32'h41234000,64'h41235000,64'h41236000,64'h41237000,64'h41238000,64'h41239000,64'h41240000,64'h41241000,64'h41242000,64'h41243000,64'h41244000,64'h41245000,64'h41246000,64'h41247000,64'h41248000,64'h41249000};
            40'd2: APB_RDATA <= {32'h80000000,32'h41250000,64'h41251000,64'h41252000,64'h41253000,64'h41254000,64'h41255000,64'h41256000,64'h41257000,64'h41258000,64'h41259000,64'h41260000,64'h41261000,64'h41262000,64'h41263000,64'h41264000,64'h41265000};
            40'd3: APB_RDATA <= {32'h80000000,32'h41266000,64'h41267000,64'h41268000,64'h41269000,64'h41270000,64'h41271000,64'h41272000,64'h41273000,64'h41274000,64'h41275000,64'h41276000,64'h41277000,64'h41278000,64'h41279000,64'h41280000,64'h41281000};
            40'd4: APB_RDATA <= {32'h80000000,32'h41298000,64'h41299000,64'h41300000,64'h41301000,64'h41302000,64'h41303000,64'h41304000,64'h41305000,64'h41306000,64'h41307000,64'h41308000,64'h41309000,64'h41310000,64'h41311000,64'h41312000,64'h41313000};
            40'd5: APB_RDATA <= {32'h80000000,32'h41314000,64'h41315000,64'h41316000,64'h41317000,64'h41318000,64'h41319000,64'h41320000,64'h41321000,64'h41322000,64'h41323000,64'h41324000,64'h41325000,64'h41326000,64'h41327000,64'h41328000,64'h41329000};
            40'd6: APB_RDATA <= {32'h80000000,32'h41330000,64'h41331000,64'h41332000,64'h41333000,64'h41334000,64'h41335000,64'h41336000,64'h41337000,64'h41338000,64'h41339000,64'h41340000,64'h41341000,64'h41342000,64'h41343000,64'h41344000,64'h41345000};
            40'd7: APB_RDATA <= {32'h80000000,32'h41346000,64'h41347000,64'h41348000,64'h41349000,64'h41350000,64'h41351000,64'h41352000,64'h41353000,64'h41354000,64'h41355000,64'h41356000,64'h41357000,64'h41358000,64'h41359000,64'h41360000,64'h41361000};
            default : APB_RDATA <= 1024'd1;
            */
   endcase
  end
  else if(axir_cnt > 0)
  begin
    APB_RREADY <= APB_RREADY;
    axir_cnt <= axir_cnt + 1'b1;     
	APB_RVALID <= 0;
  end
  else begin
    APB_RREADY <= APB_RREADY;
    axir_cnt <= axir_cnt;
	APB_RVALID <= 0;
  end
end

reg error_flag;
genvar i;
generate
	for( i=0 ; i<16 ; i=i+1) begin
		always @ ( posedge ACLK) begin
			if(mem_sel>0) begin
				case(mem_sel)
					3'd4:mem_a[waddr_reg[11:2]+i] <= wdata_reg[32*(i+1)-1:32*i];
					3'd2:mem_x[waddr_reg[11:2]+i] <= wdata_reg[32*(i+1)-1:32*i];
					3'd1:mem_y[waddr_reg[11:2]+i] <= wdata_reg[32*(i+1)-1:32*i];
				endcase
			end
			else;
		end
	end
endgenerate

endmodule