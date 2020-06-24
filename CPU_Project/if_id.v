`include "defines.v"
module if_id(
	input	wire	clk,
	input	wire	rst,
	
	//来自于取指阶段的信号
	input 	wire[`InstAddrBus]	if_pc,
	input	wire[`InstBus]		if_inst,
	
	//来自于CTRL模块的信号
	input	wire[5:0]			stall,
	
	//对应译码阶段的信号
	output	reg[`InstAddrBus]	id_pc,
	output	reg[`InstBus]		id_inst
);

	
	always@	(posedge clk) begin
		if (rst == `RstEnable) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end else if(stall[1] == `Stop && stall[2] == `NoStop) begin 	//暂停取指阶段，后续阶段继续执行
			id_pc	<= `ZeroWord;
			id_inst	<= `ZeroWord;
		end else if(stall[1] == `NoStop) begin 
			id_pc	<= if_pc;
			id_inst	<= if_inst;
		end
	end
	
	
endmodule