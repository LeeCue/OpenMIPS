`include "defines.v"
module pc_reg(
	input 	wire				clk,
	input	wire				rst,
	
	//����������׶εĵ�ַת����Ϣ
	input	wire				branch_i,
	input	wire[`RegBus]		pc_i,
	
	//���Կ���ģ��CTRL
	input	wire[5:0]			stall,
	
	output	reg					ce,
	output	reg[`InstAddrBus]		pc
);
	
	
	always@ (posedge clk) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;				//��λ��ʱ��ָ��洢������
			//cnt	= 0;
		end	else begin
			ce <= `ChipEnable;				//��λ������ָ��洢��ʹ��
		end
	end
	
	always@ (posedge clk) begin
		if (ce == `ChipDisable) begin
			pc <= `ZeroWord;				//ָ��洢�����õ�ʱ��ģ�pcΪ0
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