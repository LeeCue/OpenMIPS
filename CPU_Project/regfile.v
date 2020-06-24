`include "defines.v"
module regfile(
	input	wire	clk,
	input	wire	rst,
	
	//写端口
	input	wire				we,			//写使能
	input	wire[`RegAddrBus]	waddr,		//写入寄存器的地址
	input	wire[`RegBus]		wdata,		//写入的数据
	
	//读端口1
	input	wire				re1,		//端口1的读使能
	input	wire[`RegAddrBus]	raddr1,		//端口1的地址
	output	reg[`RegBus]		rdata1,		//端口1的数据
	
	//读端口2
	input	wire				re2,		//端口2的读使能
	input	wire[`RegAddrBus]	raddr2,		//端口2的地址
	output	reg[`RegBus]		rdata2		//端口2的数据
);


	//定义32个32个寄存器
	reg[`RegBus]	regs[0:`RegNum-1];
	
	initial	begin
		regs[1] = 32'd5;
		regs[2] = 32'd5;
		regs[3] = 32'd6;
		regs[4] = 32'd7;
		regs[5] = 32'd8;
	end
	
	
	//写操作
	always@ (posedge clk) begin
		if(rst == `RstDisable) begin
			if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
				regs[waddr] <= wdata;
			end
		end
	end
	
	
	//读端口1的读操作
	always@ (*) begin
		if(rst == `RstEnable) begin
			rdata1 <= `ZeroWord;
		end else if(raddr1 == `RegNumLog2'h0) begin
			rdata1 <= `ZeroWord;
		end else if((raddr1 == waddr) && (we == `WriteEnable)
						&& (re1 == `ReadEnable)) begin
			rdata1 <= wdata;
		end else if(re1 == `ReadEnable) begin
			rdata1 <= regs[raddr1];
		end else begin
			rdata1 <= `ZeroWord;
		end
	end
	
	
	//读端口2的读操作
	always@ (*) begin
		if(rst == `RstEnable) begin
			rdata2 <= `ZeroWord;
		end else if(raddr2 == `RegNumLog2'h0) begin
			rdata2 <= `ZeroWord;
		end else if((raddr2 == waddr) && (we == `WriteEnable)
						&& (re2 == `ReadEnable)) begin
			rdata2 <= wdata;
		end else if(re2 == `ReadEnable) begin
			rdata2 <= regs[raddr2];
		end else begin
			rdata2 <= `ZeroWord;
		end
	end
	
endmodule
			
			
			
			
			
			
			
			
			
			
			
			
	
	