`include "defines.v"
module io(
	input	wire			rst,
	input	wire			clk,
	input	wire			we,
	input	wire			re,
	//来自OUT输出的数据
	input	wire[`RegBus]	data_i,
	//来自外部输入的数据
	input	wire[`RegBus]	data_show_i,
	
	//输入给IN指令的信息
	output	reg[`RegBus]	data_o,
	//输出到外部的信息
	output	reg[`RegBus]	data_show_o,
	output	wire			out
);

	assign out	= we;

	//写操作（输出到OUT单元）
	always@ (posedge clk) begin 
		if(rst == `RstEnable) begin 
			data_show_o	<= `ZeroWord;
		end else if(we == `WriteEnable) begin 
			data_show_o	<= data_i;
		end
	end
	
	
	//读操作
	always@ (*) begin 
		if(rst == `RstEnable) begin 
			data_o <= `ZeroWord;
		end else if(re == `ReadEnable) begin 
			data_o <= data_show_i;
		end
	end

endmodule