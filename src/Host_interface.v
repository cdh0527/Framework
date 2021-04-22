//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) 
//Date        : 2021-03-02
//Host        : Duheon
//Design      : Host_interface
//Version     : 0.2
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

	module Host_interface #
	(
		parameter integer C_S_AXI_ID_WIDTH	= 1,
		parameter integer C_S_AXI_DATA_WIDTH	= 64,
		parameter integer C_S_AXI_ADDR_WIDTH	= 40,
		parameter integer C_S_AXI_AWUSER_WIDTH	= 0,
		parameter integer C_S_AXI_ARUSER_WIDTH	= 0,
		parameter integer C_S_AXI_WUSER_WIDTH	= 0,
		parameter integer C_S_AXI_RUSER_WIDTH	= 0,
		parameter integer C_S_AXI_BUSER_WIDTH	= 0,		
		parameter integer PAGETABLE_SIZE = 1024 * 1024 * 8,
		parameter integer MMR_SIZE = 1024,
		
		parameter integer C_S_AXI_WSTRB = C_S_AXI_DATA_WIDTH/8,
		parameter integer PAGETABLE_LINE_WIDTH = C_S_AXI_DATA_WIDTH,
		parameter integer PAGETABLE_INDEX = PAGETABLE_SIZE/PAGETABLE_LINE_WIDTH,
		parameter integer PAGETABLE_INDEX_BIT = `C_LOG_2(PAGETABLE_INDEX),		
		parameter integer MMR_LINE_WIDTH = C_S_AXI_DATA_WIDTH,
		parameter integer MMR_INDEX = MMR_SIZE/MMR_LINE_WIDTH,
		parameter integer MMR_INDEX_BIT = `C_LOG_2(MMR_INDEX),
		parameter integer PE_ADDR_WIDTH = 40		/// need to fix, 
		
	)
	(
		input wire  S_AXI_ACLK,
		input wire  S_AXI_ARESETN,
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_AWID,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		input wire [7 : 0] S_AXI_AWLEN,
		input wire [2 : 0] S_AXI_AWSIZE,
		input wire [1 : 0] S_AXI_AWBURST,
		input wire  S_AXI_AWLOCK,
		input wire [3 : 0] S_AXI_AWCACHE,
		input wire [2 : 0] S_AXI_AWPROT,
		input wire [3 : 0] S_AXI_AWQOS,
		input wire [3 : 0] S_AXI_AWREGION,
		input wire [C_S_AXI_AWUSER_WIDTH-1 : 0] S_AXI_AWUSER,
		input wire  S_AXI_AWVALID,
		output wire  S_AXI_AWREADY,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		input wire  S_AXI_WLAST,
		input wire [C_S_AXI_WUSER_WIDTH-1 : 0] S_AXI_WUSER,
		input wire  S_AXI_WVALID,
		output wire  S_AXI_WREADY,
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_BID,
		output wire [1 : 0] S_AXI_BRESP,
		output wire [C_S_AXI_BUSER_WIDTH-1 : 0] S_AXI_BUSER,
		output wire  S_AXI_BVALID,
		input wire  S_AXI_BREADY,
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_ARID,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		input wire [7 : 0] S_AXI_ARLEN,
		input wire [2 : 0] S_AXI_ARSIZE,
		input wire [1 : 0] S_AXI_ARBURST,
		input wire  S_AXI_ARLOCK,
		input wire [3 : 0] S_AXI_ARCACHE,
		input wire [2 : 0] S_AXI_ARPROT,
		input wire [3 : 0] S_AXI_ARQOS,
		input wire [3 : 0] S_AXI_ARREGION,
		input wire [C_S_AXI_ARUSER_WIDTH-1 : 0] S_AXI_ARUSER,
		input wire  S_AXI_ARVALID,
		output wire  S_AXI_ARREADY,
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_RID,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		output wire [1 : 0] S_AXI_RRESP,
		output wire  S_AXI_RLAST,
		output wire [C_S_AXI_RUSER_WIDTH-1 : 0] S_AXI_RUSER,
		output wire  S_AXI_RVALID,
		input wire S_AXI_RREADY,
		//!pim_port begin
		input wire [MMR_SIZE-1:0] out_argu,
		input wire rp_pt_ren,
		input wire [PAGETABLE_INDEX_BIT-1:0] rp_pt_raddr,
		output wire [PAGETABLE_LINE_WIDTH-1:0] rp_pt_rdata,
		input wire wp_pt_ren,
		input wire [PAGETABLE_INDEX_BIT-1:0] wp_pt_raddr,
		output wire [PAGETABLE_LINE_WIDTH-1:0] wp_pt_rdata,
		
		input wire [1:0] pim_state,
		
		output reg [MMR_SIZE-1:0] in_argu
		//!pim_port end
	);

	// AXI4FULL signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg [C_S_AXI_BUSER_WIDTH-1 : 0] 	axi_buser;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rlast;
	reg [C_S_AXI_RUSER_WIDTH-1 : 0] 	axi_ruser;
	reg  	axi_rvalid;
	// aw_wrap_en determines wrap boundary and enables wrapping
	wire aw_wrap_en;
	// ar_wrap_en determines wrap boundary and enables wrapping
	wire ar_wrap_en;
	// aw_wrap_size is the size of the write transfer, the
	// write address wraps to a lower address if upper address
	// limit is reached
	wire [31:0]  aw_wrap_size ; 
	// ar_wrap_size is the size of the read transfer, the
	// read address wraps to a lower address if upper address
	// limit is reached
	wire [31:0]  ar_wrap_size ; 
	// The axi_awv_awr_flag flag marks the presence of write address valid
	reg axi_awv_awr_flag;
	//The axi_arv_arr_flag flag marks the presence of read address valid
	reg axi_arv_arr_flag; 
	// The axi_awlen_cntr internal write address counter to keep track of beats in a burst transaction
	reg [7:0] axi_awlen_cntr;
	//The axi_arlen_cntr internal read address counter to keep track of beats in a burst transaction
	reg [7:0] axi_arlen_cntr;
	reg [1:0] axi_arburst;
	reg [1:0] axi_awburst;
	reg [7:0] axi_arlen;
	reg [7:0] axi_awlen;
	
	//local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	//ADDR_LSB is used for addressing 32/64 bit registers/memories
	//ADDR_LSB = 2 for 32 bits (n downto 2) 
	//ADDR_LSB = 3 for 42 bits (n downto 3)

	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32)+ 1;
	localparam integer OPT_MEM_ADDR_BITS = 3;
	localparam integer USER_NUM_MEM = 1;
	//----------------------------------------------
	//-- Signals for user logic memory space example
	//------------------------------------------------
	genvar i;
	genvar j;
	genvar mem_byte_index;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BUSER	= axi_buser;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RLAST	= axi_rlast;
	assign S_AXI_RUSER	= axi_ruser;
	assign S_AXI_RVALID	= axi_rvalid;
	assign S_AXI_BID = S_AXI_AWID;
	assign S_AXI_RID = S_AXI_ARID;
	assign  aw_wrap_size = (C_S_AXI_DATA_WIDTH/8 * (axi_awlen)); 
	assign  ar_wrap_size = (C_S_AXI_DATA_WIDTH/8 * (axi_arlen)); 
	assign  aw_wrap_en = ((axi_awaddr & aw_wrap_size) == aw_wrap_size)? 1'b1: 1'b0;
	assign  ar_wrap_en = ((axi_araddr & ar_wrap_size) == ar_wrap_size)? 1'b1: 1'b0;
	
	

	// Implement axi_awready generation

	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      axi_awv_awr_flag <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag)
	        begin
	          // slave is ready to accept an address and
	          // associated control signals
	          axi_awready <= 1'b1;
	          axi_awv_awr_flag  <= 1'b1; 
	          // used for generation of bresp() and bvalid
	        end
	      else if (S_AXI_WLAST && axi_wready)          
	      // preparing to accept next address after current write burst tx completion
	        begin
	          axi_awv_awr_flag  <= 1'b0;
	        end
	      else        
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       
	// Implement axi_awaddr latching

	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	      axi_awlen_cntr <= 0;
	      axi_awburst <= 0;
	      axi_awlen <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && ~axi_awv_awr_flag)
	        begin
	          // address latching 
	          axi_awaddr <= S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH - 1:0];  
	           axi_awburst <= S_AXI_AWBURST; 
	           axi_awlen <= S_AXI_AWLEN;     
	          // start address of transfer
	          axi_awlen_cntr <= 0;
	        end   
	      else if((axi_awlen_cntr <= axi_awlen) && axi_wready && S_AXI_WVALID)        
	        begin

	          axi_awlen_cntr <= axi_awlen_cntr + 1;

	          case (axi_awburst)
	            2'b00: // fixed burst
	            // The write address for all the beats in the transaction are fixed
	              begin
	                axi_awaddr <= axi_awaddr;          
	                //for awsize = 4 bytes (010)
	              end   
	            2'b01: //incremental burst
	            // The write address for all the beats in the transaction are increments by awsize
	              begin
	                axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                //awaddr aligned to 4 byte boundary
	                axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                //for awsize = 4 bytes (010)
	              end   
	            2'b10: //Wrapping burst
	            // The write address wraps when the address reaches wrap boundary 
	              if (aw_wrap_en)
	                begin
	                  axi_awaddr <= (axi_awaddr - aw_wrap_size); 
	                end
	              else 
	                begin
	                  axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                  axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}}; 
	                end                      
	            default: //reserved (incremental burst for example)
	              begin
	                axi_awaddr <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                //for awsize = 4 bytes (010)
	              end
	          endcase              
	        end
	    end 
	end       
	// Implement axi_wready generation

	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if ( ~axi_wready && S_AXI_WVALID && axi_awv_awr_flag)
	        begin
	          // slave can accept the write data
	          axi_wready <= 1'b1;
	        end
	      //else if (~axi_awv_awr_flag)
	      else if (S_AXI_WLAST && axi_wready)
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       
	// Implement write response logic generation

	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid <= 0;
	      axi_bresp <= 2'b0;
	      axi_buser <= 0;
	    end 
	  else
	    begin    
	      if (axi_awv_awr_flag && axi_wready && S_AXI_WVALID && ~axi_bvalid && S_AXI_WLAST )
	        begin
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; 
	          // 'OKAY' response 
	        end                   
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	          //check if bready is asserted while bvalid is high) 
	          //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	 end   
	// Implement axi_arready generation

	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_arv_arr_flag <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag)
	        begin
	          axi_arready <= 1'b1;
	          axi_arv_arr_flag <= 1'b1;
	        end
	      else if (axi_rvalid && S_AXI_RREADY && axi_arlen_cntr == axi_arlen)
	      // preparing to accept next address after current read completion
	        begin
	          axi_arv_arr_flag  <= 1'b0;
	        end
	      else        
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       
	// Implement axi_araddr latching

	//This process is used to latch the address when both 
	//S_AXI_ARVALID and S_AXI_RVALID are valid. 
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_araddr <= 0;
	      axi_arlen_cntr <= 0;
	      axi_arburst <= 0;
	      axi_arlen <= 0;
	      axi_rlast <= 1'b0;
	      axi_ruser <= 0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID && ~axi_arv_arr_flag)
	        begin
	          // address latching 
	          axi_araddr <= S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH - 1:0]; 
	          axi_arburst <= S_AXI_ARBURST; 
	          axi_arlen <= S_AXI_ARLEN;     
	          // start address of transfer
	          axi_arlen_cntr <= 0;
	          axi_rlast <= 1'b0;
	        end   
	      else if((axi_arlen_cntr <= axi_arlen) && axi_rvalid && S_AXI_RREADY)        
	        begin
	         
	          axi_arlen_cntr <= axi_arlen_cntr + 1;
	          axi_rlast <= 1'b0;
	        
	          case (axi_arburst)
	            2'b00: // fixed burst
	             // The read address for all the beats in the transaction are fixed
	              begin
	                axi_araddr       <= axi_araddr;        
	                //for arsize = 4 bytes (010)
	              end   
	            2'b01: //incremental burst
	            // The read address for all the beats in the transaction are increments by awsize
	              begin
	                axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
	                //araddr aligned to 4 byte boundary
	                axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                //for awsize = 4 bytes (010)
	              end   
	            2'b10: //Wrapping burst
	            // The read address wraps when the address reaches wrap boundary 
	              if (ar_wrap_en) 
	                begin
	                  axi_araddr <= (axi_araddr - ar_wrap_size); 
	                end
	              else 
	                begin
	                axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
	                //araddr aligned to 4 byte boundary
	                axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                end                      
	            default: //reserved (incremental burst for example)
	              begin
	                axi_araddr <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB]+1;
	                //for arsize = 4 bytes (010)
	              end
	          endcase              
	        end
	      else if((axi_arlen_cntr == axi_arlen) && ~axi_rlast && axi_arv_arr_flag )   
	        begin
	          axi_rlast <= 1'b1;
	        end          
	      else if (S_AXI_RREADY)   
	        begin
	          axi_rlast <= 1'b0;
	        end          
	    end 
	end       
	// Implement axi_arvalid generation

	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arv_arr_flag && ~axi_rvalid)
	        begin
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; 
	          // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          axi_rvalid <= 1'b0;
	        end            
	    end
	end    
	// ------------------------------------------
	// -- Example code to access user logic memory region
	// ------------------------------------------
	
	wire [PAGETABLE_INDEX_BIT-1:0] mem_address = (axi_arv_arr_flag? axi_araddr[PAGETABLE_INDEX_BIT+ADDR_LSB-1:ADDR_LSB]:(axi_awv_awr_flag? axi_awaddr[PAGETABLE_INDEX_BIT+ADDR_LSB-1:ADDR_LSB]:0));
	wire read_en = axi_arv_arr_flag;
	wire isMMRread = (axi_araddr[PAGETABLE_INDEX_BIT]?0:1);
	wire isMMRwrite = (axi_awaddr[PAGETABLE_INDEX_BIT]?0:1);
	//Memory mapped register
	wire [MMR_INDEX_BIT-1:0] mmr_address = mem_address[MMR_INDEX_BIT-1:0];
	wire mmr_ren = (isMMRread?axi_arv_arr_flag:0);
	wire mmr_wen = (isMMRwrite?axi_awv_awr_flag:0);
	reg [C_S_AXI_DATA_WIDTH-1:0] mmr_host_rdata;
	reg [MMR_LINE_WIDTH-1:0] mmr [MMR_INDEX-1:0];
	reg [MMR_SIZE-1:0] mmr_reg;
	always @( posedge S_AXI_ACLK )
	begin
		if(mmr_ren) begin
			mmr_host_rdata <= mmr[mmr_address];
		end
		else begin
			mmr_host_rdata <= {MMR_LINE_WIDTH{1'b0}};
		end
	end
	generate
	for(i=0 ; i<C_S_AXI_WSTRB ; i=i+1) begin:MMR_write
	   always @( posedge S_AXI_ACLK )
	   begin
		  if(mmr_wen) begin
			 if(S_AXI_WSTRB[i]==1'b1) begin
				    mmr[mmr_address][(i+1)*8-1:(i*8)] <= S_AXI_WDATA[(i+1)*8-1:(i*8)];
			 end
		  end
		  else if(pim_state == 2) begin //finish state
		      mmr[i] <= out_argu[(i+1)*MMR_LINE_WIDTH-1:(i*MMR_LINE_WIDTH)];
		  end
	   end
	end
	endgenerate
	generate
	for(i=0 ; i<MMR_INDEX ; i=i+1) begin:MMR_start
	   always @( posedge S_AXI_ACLK ) begin	
	      if ( S_AXI_ARESETN == 1'b0 ) begin
	         in_argu <= {MMR_SIZE{1'b0}};
	      end 
	      else	begin
	   	   if(((mmr[MMR_INDEX]&{{(MMR_LINE_WIDTH-1){1'b0}}, 1'b1})!=0) && (pim_state == 0)) begin
	   	      in_argu[(i+1)*MMR_LINE_WIDTH-1:(i*MMR_LINE_WIDTH)]<=mmr[i];
	   	   end
	   	   else if(pim_state == 2) begin
	   		  in_argu[(i+1)*MMR_LINE_WIDTH-1:(i*MMR_LINE_WIDTH)]<={MMR_LINE_WIDTH{1'b0}};
	   	   end
	      end
	   end
	end
	endgenerate
	

	//page table
	wire [PAGETABLE_INDEX_BIT-1:0] pt_address = mem_address[PAGETABLE_INDEX_BIT-1:0];
	wire pt_host_ren = (isMMRread?0:axi_arv_arr_flag);
	wire pt_host_wen = (isMMRwrite?0:axi_awv_awr_flag);
	reg [C_S_AXI_DATA_WIDTH-1:0] pt_host_rdata;
	reg [PAGETABLE_LINE_WIDTH-1:0] pt [PAGETABLE_INDEX-1:0];
	always @( posedge S_AXI_ACLK )
	begin
		if(pt_host_ren) begin
			pt_host_rdata <= pt[pt_address];
		end
		else begin
			pt_host_rdata <= {PAGETABLE_LINE_WIDTH{1'b0}};
		end
	end
	generate
	for(i=0 ; i<=C_S_AXI_WSTRB ; i=i+1) begin:PT_WSTRB
	always @( posedge S_AXI_ACLK )
	   begin
		  if(pt_host_wen) begin
			if(S_AXI_WSTRB[i]==1'b1) begin
				pt[pt_address][(i+1)*8-1:(i*8)] <= S_AXI_WDATA[(i+1)*8-1:(i*8)];
			end
		  end
	   end
	end
	endgenerate
	
	assign rp_pt_rdata = rp_pt_ren?pt[rp_pt_raddr]:'b1;
	assign wp_pt_rdata = rp_pt_ren?pt[wp_pt_raddr]:'b1;
	/* pt_data register version
	always @( posedge S_AXI_ACLK )
	begin
		if(pt_ren) begin
			pt_rdata <= pt[pt_raddr];
		end
		else begin
			pt_rdata <= {PAGETABLE_LINE_WIDTH{1'b0}};
		end
	end*/

	always @( posedge S_AXI_ACLK)
	begin
	  if (axi_rvalid) 
	    begin
	      if(axi_araddr[PAGETABLE_INDEX_BIT]) begin
			    axi_rdata <= pt_host_rdata;
		  end
		  else if(axi_araddr[MMR_INDEX_BIT]==0) begin
				axi_rdata <= mmr_host_rdata;
		  end 
		  else begin
				axi_rdata <= {(C_S_AXI_DATA_WIDTH){1'b1}};
		  end
	    end   
	  else
	    begin
	      axi_rdata <= 32'h00000000;
	    end       
	end 

endmodule