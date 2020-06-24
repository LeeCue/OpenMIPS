`include "defines.v"
module pc_reg(
	input 	wire				clk,
	input	wire				rst,
	
	//来自于译码阶段的地址转移信息
	input	wire				branch_i,
	input	wire[`RegBus]		pc_i,
	
	//来自控制模块CTRL
	input	wire[5:0]			stall,
	
	output	reg					ce,
	output	reg[`InstAddrBus]		pc
);
	
	
	always@ (posedge clk) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;				//复位的时候指令存储器禁用
			//cnt	= 0;
		end	else begin
			ce <= `ChipEnable;				//复位结束后，指令存储器使能
		end
	end
	
	always@ (posedge clk) begin
		if (ce == `ChipDisable) begin
			pc <= `ZeroWord;				//指令存储器禁用的时候的，pc为0
		end 
		else if(stall[0] == `NoStop) begin 
			if(branch_i == `Branch) begin 
				pc <= pc_i;
			end else begin 
				pc <= pc + 4'h4;
			end
		end 
	end
endmodule