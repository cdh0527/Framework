//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) 
//Date        : 2021-01-31
//Host        : Duheon
//Design      : PIM_tile
//Version     : 0.1
//--------------------------------------------------------------------------------
//Generate log
//Data        : 
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
module PIM_tile# (
	parameter integer MMR_AXI_DATA_WIDTH = 64,
	parameter integer MMR_AXI_ADDR_WIDTH = 40,
	parameter integer NDP_AXI_DATA_WIDTH = 512,
	parameter integer NDP_AXI_ADDR_WIDTH = 40,
	parameter integer MMR_SIZE = 1024
  )(
  aclk,
  resetn,
  MMR_REBUG_araddr,
  MMR_REBUG_arburst,
  MMR_REBUG_arcache,
  MMR_REBUG_arlen,
  MMR_REBUG_arlock,
  MMR_REBUG_arprot,
  MMR_REBUG_arqos,
  MMR_REBUG_arready,
  MMR_REBUG_arregion,
  MMR_REBUG_arsize,
  MMR_REBUG_arvalid,
  MMR_REBUG_awaddr,
  MMR_REBUG_awburst,
  MMR_REBUG_awcache,
  MMR_REBUG_awlen,
  MMR_REBUG_awlock,
  MMR_REBUG_awprot,
  MMR_REBUG_awqos,
  MMR_REBUG_awready,
  MMR_REBUG_awregion,
  MMR_REBUG_awsize,
  MMR_REBUG_awvalid,
  MMR_REBUG_bready,
  MMR_REBUG_bresp,
  MMR_REBUG_bvalid,
  MMR_REBUG_rdata,
  MMR_REBUG_rlast,
  MMR_REBUG_rready,
  MMR_REBUG_rresp,
  MMR_REBUG_rvalid,
  MMR_REBUG_wdata,
  MMR_REBUG_wlast,
  MMR_REBUG_wready,
  MMR_REBUG_wstrb,
  MMR_REBUG_wvalid,
  MMR_araddr,
  MMR_arburst,
  MMR_arcache,
  MMR_arlen,
  MMR_arlock,
  MMR_arprot,
  MMR_arqos,
  MMR_arready,
  MMR_arregion,
  MMR_arsize,
  MMR_arvalid,
  MMR_awaddr,
  MMR_awburst,
  MMR_awcache,
  MMR_awlen,
  MMR_awlock,
  MMR_awprot,
  MMR_awqos,
  MMR_awready,
  MMR_awregion,
  MMR_awsize,
  MMR_awvalid,
  MMR_bready,
  MMR_bresp,
  MMR_bvalid,
  MMR_rdata,
  MMR_rlast,
  MMR_rready,
  MMR_rresp,
  MMR_rvalid,
  MMR_wdata,
  MMR_wlast,
  MMR_wready,
  MMR_wstrb,
  MMR_wvalid,
  NDP_araddr,
  NDP_arburst,
  NDP_arcache,
  NDP_arid,
  NDP_arlen,
  NDP_arlock,
  NDP_arprot,
  NDP_arqos,
  NDP_arready,
  NDP_arsize,
  NDP_arvalid,
  NDP_awaddr,
  NDP_awburst,
  NDP_awcache,
  NDP_awid,
  NDP_awlen,
  NDP_awlock,
  NDP_awprot,
  NDP_awqos,
  NDP_awready,
  NDP_awsize,
  NDP_awvalid,
  NDP_bid,
  NDP_bready,
  NDP_bresp,
  NDP_bvalid,
  NDP_rdata,
  NDP_rid,
  NDP_rlast,
  NDP_rready,
  NDP_rresp,
  NDP_rvalid,
  NDP_wdata,
  NDP_wlast,
  NDP_wready,
  NDP_wstrb,
  NDP_wvalid
  );
  ////!parameter define!begin
  localparam MMR_STRB_BIT = MMR_AXI_DATA_WIDTH/8;
  localparam NDP_STRB_BIT = NDP_AXI_DATA_WIDTH/8;
  ////!parameter define!end
  
  ////!fixed define!begin
  input aclk;
  input resetn;
  input [MMR_AXI_DATA_WIDTH-1:0]MMR_REBUG_araddr;
  input [1:0]MMR_REBUG_arburst;
  input [3:0]MMR_REBUG_arcache;
  input [7:0]MMR_REBUG_arlen;
  input [0:0]MMR_REBUG_arlock;
  input [2:0]MMR_REBUG_arprot;
  input [3:0]MMR_REBUG_arqos;
  output MMR_REBUG_arready;
  input [3:0]MMR_REBUG_arregion;
  input [2:0]MMR_REBUG_arsize;
  input MMR_REBUG_arvalid;
  input [MMR_AXI_DATA_WIDTH-1:0]MMR_REBUG_awaddr;
  input [1:0]MMR_REBUG_awburst;
  input [3:0]MMR_REBUG_awcache;
  input [7:0]MMR_REBUG_awlen;
  input [0:0]MMR_REBUG_awlock;
  input [2:0]MMR_REBUG_awprot;
  input [3:0]MMR_REBUG_awqos;
  output MMR_REBUG_awready;
  input [3:0]MMR_REBUG_awregion;
  input [2:0]MMR_REBUG_awsize;
  input MMR_REBUG_awvalid;
  input MMR_REBUG_bready;
  output [1:0]MMR_REBUG_bresp;
  output MMR_REBUG_bvalid;
  output [MMR_AXI_DATA_WIDTH-1:0]MMR_REBUG_rdata;
  output MMR_REBUG_rlast;
  input MMR_REBUG_rready;
  output [1:0]MMR_REBUG_rresp;
  output MMR_REBUG_rvalid;
  input [MMR_AXI_DATA_WIDTH-1:0]MMR_REBUG_wdata;
  input MMR_REBUG_wlast;
  output MMR_REBUG_wready;
  input [MMR_STRB_BIT-1:0]MMR_REBUG_wstrb;
  input MMR_REBUG_wvalid;
  input [MMR_AXI_ADDR_WIDTH-1:0]MMR_araddr;
  input [1:0]MMR_arburst;
  input [3:0]MMR_arcache;
  input [7:0]MMR_arlen;
  input [0:0]MMR_arlock;
  input [2:0]MMR_arprot;
  input [3:0]MMR_arqos;
  output MMR_arready;
  input [3:0]MMR_arregion;
  input [2:0]MMR_arsize;
  input MMR_arvalid;
  input [MMR_AXI_ADDR_WIDTH-1:0]MMR_awaddr;
  input [1:0]MMR_awburst;
  input [3:0]MMR_awcache;
  input [7:0]MMR_awlen;
  input [0:0]MMR_awlock;
  input [2:0]MMR_awprot;
  input [3:0]MMR_awqos;
  output MMR_awready;
  input [3:0]MMR_awregion;
  input [2:0]MMR_awsize;
  input MMR_awvalid;
  input MMR_bready;
  output [1:0]MMR_bresp;
  output MMR_bvalid;
  output [MMR_AXI_DATA_WIDTH-1:0]MMR_rdata;
  output MMR_rlast;
  input MMR_rready;
  output [1:0]MMR_rresp;
  output MMR_rvalid;
  input [MMR_AXI_DATA_WIDTH-1:0]MMR_wdata;
  input MMR_wlast;
  output MMR_wready;
  input [MMR_STRB_BIT-1:0]MMR_wstrb;
  input MMR_wvalid;
  output [NDP_AXI_ADDR_WIDTH-1:0]NDP_araddr;
  output [1:0]NDP_arburst;
  output [3:0]NDP_arcache;
  output [0:0]NDP_arid;
  output [7:0]NDP_arlen;
  output [0:0]NDP_arlock;
  output [2:0]NDP_arprot;
  output [3:0]NDP_arqos;
  input NDP_arready;
  output [2:0]NDP_arsize;
  output NDP_arvalid;
  output [NDP_AXI_ADDR_WIDTH-1:0]NDP_awaddr;
  output [1:0]NDP_awburst;
  output [3:0]NDP_awcache;
  output [0:0]NDP_awid;
  output [7:0]NDP_awlen;
  output [0:0]NDP_awlock;
  output [2:0]NDP_awprot;
  output [3:0]NDP_awqos;
  input NDP_awready;
  output [2:0]NDP_awsize;
  output NDP_awvalid;
  input [0:0]NDP_bid;
  output NDP_bready;
  input [1:0]NDP_bresp;
  input NDP_bvalid;
  input [NDP_AXI_DATA_WIDTH-1:0]NDP_rdata;
  input [0:0]NDP_rid;
  input NDP_rlast;
  output NDP_rready;
  input [1:0]NDP_rresp;
  input NDP_rvalid;
  output [NDP_AXI_DATA_WIDTH-1:0]NDP_wdata;
  output NDP_wlast;
  input NDP_wready;
  output [NDP_STRB_BIT-1:0]NDP_wstrb;
  output NDP_wvalid;
  wire [MMR_SIZE-1:0] in_argu;
  wire [63:0] argu_64 [7:0];
  wire [31:0] argu_32 [15:0];
  genvar i;
  generate
	for(i=0 ; i<16 ; i=i+1) begin
		assign argu_32[i] = in_argu[(i+1)*32:i*32];
	end
	for(i=0 ; i<8 ; i=i+1) begin
		assign argu_64[i] = in_argu[(i+1)*64+MMR_SIZE/2:i*64+MMR_SIZE/2];
	end
  endgenerate    
  wire PIM_cmd = argu_32[15];
  wire PE_done;
  wire wb_empty;
  wire cache_empty;
  wire finish;
  wire PE_start;
  wire cl_flush;  
  ////!fixed define!end
  
  ////!wire define!begin
  ////!wire define!end
  ////!reg define!begin
  ////!reg define!end
  ////!Host_interface!begin
  Host_interface # (
  )h_interface_inst(
    .S_AXI_ACLK    (aclk),
    .S_AXI_ARESETN (resetn),
    .S_AXI_AWID    (0),
    .S_AXI_AWADDR  (MMR_awaddr),
    .S_AXI_AWLEN   (MMR_awlen),
    .S_AXI_AWSIZE  (MMR_awsize),
    .S_AXI_AWBURST (MMR_awburst),
    .S_AXI_AWLOCK  (MMR_awlock),
    .S_AXI_AWCACHE (MMR_awcache),
    .S_AXI_AWPROT  (MMR_awprot),
    .S_AXI_AWQOS   (MMR_awqos),
    .S_AXI_AWREGION(MMR_awregion),
    .S_AXI_AWUSER  (0),
    .S_AXI_AWVALID (MMR_awvalid),
    .S_AXI_AWREADY (MMR_awready),
    .S_AXI_WDATA   (MMR_wdata),
    .S_AXI_WSTRB   (MMR_wstrb),
    .S_AXI_WLAST   (MMR_wlast),
    .S_AXI_WUSER   (0),
    .S_AXI_WVALID  (MMR_wvalid),
    .S_AXI_WREADY  (MMR_wready),
    .S_AXI_BID     (0),
    .S_AXI_BRESP   (MMR_bresp),
    .S_AXI_BUSER   (0),
    .S_AXI_BVALID  (MMR_bvalid),
    .S_AXI_BREADY  (MMR_bready),
    .S_AXI_ARID    (0),
    .S_AXI_ARADDR  (MMR_araddr),
    .S_AXI_ARLEN   (MMR_arlen),
    .S_AXI_ARSIZE  (MMR_arsize),
    .S_AXI_ARBURST (MMR_arburst),
    .S_AXI_ARLOCK  (MMR_arlock),
    .S_AXI_ARCACHE (MMR_arcache),
    .S_AXI_ARPROT  (MMR_arprot),
    .S_AXI_ARQOS   (MMR_arqos),
    .S_AXI_ARREGION(MMR_arregion),
    .S_AXI_ARUSER  (0),
    .S_AXI_ARVALID (MMR_arvalid),
    .S_AXI_ARREADY (MMR_arready),
    .S_AXI_RID     (0),
    .S_AXI_RDATA   (MMR_rdata),
    .S_AXI_RRESP   (MMR_rresp),
    .S_AXI_RLAST   (MMR_rlast),
    .S_AXI_RUSER   (0),
    .S_AXI_RVALID  (MMR_rvalid),
    .S_AXI_RREADY  (MMR_rready),
    .out_argu      (),
    .pt_ren        (0),
    .pt_raddr      (0),
    .pim_state     (0),
    .pt_rdata      (),
    .in_argu       (in_argu)
  );
  ////!Host_interface!end
  
  ////!PIM_controller!begin
  PIM_controller PIM_controller_inst(
    .aclk(aclk),
    .resetn(resetn),
    .PIM_cmd(PIM_cmd),
    .PE_done(PE_done),
    .wb_empty(wb_empty),
    .cache_empty(cache_empty),
    .finish(finish),
    .PE_start(PE_start),
    .cl_flush(cl_flush)
  );
  ////!PIM_controller!end
endmodule