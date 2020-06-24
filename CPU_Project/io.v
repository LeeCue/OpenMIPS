`include "defines.v"
module io(
	input	wire			rst,
	input	wire			clk,
	input	wire			we,
	input	wire			re,
	//����OUT���������
	input	wire[`RegBus]	data_i,
	//�����ⲿ���������
	input	wire[`RegBus]	data_show_i,
	
	//�����INָ�����Ϣ
	output	reg[`RegBus]	data_o,
	//������ⲿ����Ϣ
	output	reg[`RegBus]	data_show_o,
	output	wire			out
);

	assign out	= we;

	//д�����������OUT��Ԫ��
	always@ (posedge clk) begin 
		if(rst == `RstEnable) begin 
			data_show_o	<= `ZeroWord;
		end else if(we == `WriteEnable) begin 
			data_show_o	<= data_i;
		end
	end
	
	
	//������
	always@ (*) begin 
		if(rst == `RstEnable) begin 
			data_o <= `ZeroWord;
		end else if(re == `ReadEnable) begin 
			data_o <= data_show_i;
		end
	end

endmodule