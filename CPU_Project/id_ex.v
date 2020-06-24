`include "defines.v"
module id_ex(
	input	wire	clk,
	input	wire	rst,

	//从译码阶段传递过来的信息
	input	wire[`AluOpBus]		id_aluop,
	input	wire[`AluSelBus]	id_alusel,
	input	wire[`RegBus]		id_reg1,
	input	wire[`RegBus]		id_reg2,
	input	wire[`RegAddrBus]	id_wd,
	input	wire[`RegBus]		id_imm,
	input	wire				id_wreg,
	input	wire				id_alusrc,
	input	wire				id_memW,
	input	wire				id_memR,
	input	wire				id_in,
	input	wire				id_out,
	
	//来自控制模块的信息
	input	wire[5:0]			stall,
	
	//传递到执行阶段的信息
	output	reg[`AluOpBus]		ex_aluop,
	output	reg[`AluSelBus]		ex_alusel,
	output	reg[`RegBus]		ex_reg1,
	output	reg[`RegBus]		ex_reg2,
	output	reg[`RegAddrBus]	ex_wd,
	output	reg[`RegBus]		ex_imm,
	output	reg					ex_alusrc,
	output	reg					ex_wreg,
	output	reg					ex_memW,
	output	reg					ex_memR,
	output	reg					ex_in,
	output	reg					ex_out
);


	always@	(posedge clk) begin
		if(rst == `RstEnable)	begin
			ex_aluop	<= `EXE_nop_op;
			ex_alusel	<= `EXE_NOP_sel;
			ex_reg1		<= `ZeroWord;
			ex_reg2		<= `ZeroWord;
			ex_wd		<= `NOPRegAddr;
			ex_wreg		<= `WriteDisable;
			ex_imm		<= 32'h0;
			ex_alusrc	<= 1'b0;
			ex_memW		<= `WriteDisable;
			ex_memR		<= `ReadDisable;
			ex_in		<= `NotIn;
			ex_out		<= `NotOut;
		end	else if(stall[2] == `Stop && stall[3] == `NoStop) begin 
			ex_aluop	<= `EXE_nop_op;
			ex_alusel	<= `EXE_NOP_sel;
			ex_reg1		<= `ZeroWord;
			ex_reg2		<= `ZeroWord;
			ex_wd		<= `NOPRegAddr;
			ex_wreg		<= `WriteDisable;
			ex_imm		<= 32'h0;
			ex_alusrc	<= 1'b0;
			ex_memW		<= `WriteDisable;
			ex_memR		<= `ReadDisable;
			ex_in		<= `NotIn;
			ex_out		<= `NotOut;
		end else if(stall[2] == `NoStop) begin 
			ex_aluop	<=  id_aluop;
			ex_alusel	<=  id_alusel;
			ex_reg1		<=  id_reg1;
			ex_reg2		<=  id_reg2;
			ex_wd		<=  id_wd;
			ex_wreg		<=  id_wreg;
			ex_imm		<=  id_imm;
			ex_alusrc	<=  id_alusrc;
			ex_memW		<=  id_memW;
			ex_memR		<=  id_memR;
			ex_in		<=  id_in;
			ex_out		<=  id_out;
		end
	end

endmodule
			