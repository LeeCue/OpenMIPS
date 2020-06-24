`include "defines.v"
module ex_mem(
	input	wire	clk,
	input	wire	rst,
	
	//来自执行阶段的值
	input	wire[`RegAddrBus]	ex_wd,
	input	wire				ex_wreg,
	input	wire[`RegBus]		ex_wdata,
	input	wire				ex_memW,
	input	wire				ex_memR,
	input	wire[`RegBus]		ex_addr,
	input	wire				ex_in,
	input	wire				ex_out,
	
	//来自控制模块的信息
	input	wire[5:0]			stall,
	
	//送到访存阶段的信息
	output	reg[`RegAddrBus]	mem_wd,
	output	reg					mem_wreg,
	output	reg[`RegBus]		mem_wdata,
	output	reg					mem_W,
	output	reg					mem_R,
	output	reg[`RegBus]		mem_addr,
	output	reg					mem_in,
	output	reg					mem_out
);

	always@ (posedge clk) begin
		if(rst == `RstEnable) begin
			mem_wd	<= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
			mem_wdata <= `ZeroWord;
			mem_W	<= `WriteDisable;
			mem_R	<= `ReadDisable;
			mem_addr  <= `ZeroWord;
			mem_in	<= `NotIn;
			mem_out	<= `NotOut;
		end else if(stall[3] == `Stop && stall[4] == `NoStop) begin 
			mem_wd	<= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
			mem_wdata <= `ZeroWord;
			mem_W	<= `WriteDisable;
			mem_R	<= `ReadDisable;
			mem_addr  <= `ZeroWord;
			mem_in	<= `NotIn;
			mem_out	<= `NotOut;
		end else if(stall[3] == `NoStop) begin 
			mem_wd	<= ex_wd;
			mem_wreg <= ex_wreg;
			mem_wdata <= ex_wdata;
			mem_W	<=	ex_memW;
			mem_R	<=	ex_memR;
			mem_addr <= ex_addr;
			mem_in	<= ex_in;
			mem_out	<= ex_out;
		end
	end
	
	
endmodule