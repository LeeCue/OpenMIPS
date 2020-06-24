`include "defines.v"
module mem(
	input	wire	rst,
	
	//����ִ�н׶ε���Ϣ
	input	wire[`RegAddrBus]	wd_i,
	input	wire				wreg_i,
	input	wire[`RegBus]		wdata_i,
	input	wire				memW_i,
	input	wire				memR_i,
	input	wire[`RegBus]		mem_addr_i,
	input	wire				mem_in,
	input	wire				mem_out,
	
	//������IO���������
	input	wire[`RegBus]		data_in,
	
	//�����ⲿ���ݼĴ���RAM����Ϣ
	input	wire[`RegBus]		mem_data_i,
	
	//�ô�׶ε�ֵ
	output	reg[`RegAddrBus]	wd_o,
	output	reg					wreg_o,
	output	reg[`RegBus]		wdata_o,
	
	//�͵����ݼĴ���RAM����Ϣ
	output	reg[`RegBus]		mem_addr_o,
	output	reg					mem_we_o,
	output	reg					mem_re_o,
	output	reg[3:0]			mem_sel_o,
	output	reg[`RegBus]		mem_data_o,
	output	reg					mem_ce_o,
	
	//�͵�OUT��Ԫ������
	output	reg[`RegBus]		data_out,
	output	reg					io_we,				//IO��Ԫдʹ���ź�
	output	reg					io_re				//IO��Ԫ��ʹ���ź�
);
	
	always@ (*) begin
		if(rst == `RstEnable) begin
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			wdata_o <= `ZeroWord;
			mem_addr_o <= `ZeroWord;
			mem_sel_o <= 4'b0000;
			mem_data_o <= `ZeroWord;
			mem_ce_o <= `ChipDisable;
			mem_we_o <= `WriteDisable;
			mem_re_o <= `ReadDisable;
			data_out <= `ZeroWord;
			io_we	<= `WriteDisable;
			io_re	<= `ReadDisable;
		end	else begin
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			mem_we_o <= memW_i;
			mem_re_o <= memR_i;
			wdata_o <= `ZeroWord;
			mem_addr_o <= `ZeroWord;
			mem_sel_o <= 4'b0000;
			mem_data_o <= `ZeroWord;
			mem_ce_o <= `ChipDisable;
			data_out <= `ZeroWord;
			io_we	<= `WriteDisable;
			io_re	<= `ReadDisable;
			if(memW_i == `WriteEnable || memR_i == `ReadEnable) begin 
				wdata_o <= mem_data_i;
				mem_addr_o <= mem_addr_i;
				mem_sel_o <= 4'b1111;
				mem_data_o <= wdata_i;
				mem_ce_o <= `ChipEnable;
			end else if(mem_in == `In) begin
				wdata_o <= data_in;
				io_we	<= `WriteDisable;
				io_re	<= `ReadEnable;
			end else if(mem_out == `Out) begin 
				data_out <= wdata_i;
				io_we	<= `WriteEnable;
				io_re	<= `ReadDisable;
			end else begin 
				wdata_o <= wdata_i;
				mem_addr_o <= `ZeroWord;
				mem_sel_o <= 4'b0000;
				mem_data_o <= `ZeroWord;
				mem_ce_o <= `ChipDisable;
			end
			
		end
	end
	
	
endmodule