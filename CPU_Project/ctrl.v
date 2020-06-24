`include "defines.v"
module	ctrl(
	input	wire		rst,
	
	//���Էô�׶ε���ͣ����
	input	wire		stallreq_from_mem,
	
	//�������ⲿ��ȡ����ͣ�ź�
	input	wire		enter,
	
	output	reg[5:0]	stall
);

	wire	not_enter;
	
	assign not_enter = ~enter;

	always@ (*) begin 
		if(rst == `RstEnable) begin 
			stall	<= 6'b000000;
		end
		else if(stallreq_from_mem == `Stop && not_enter == 1'b1) begin 
			stall	<= 6'b011111;
		end else begin 
			stall	<= 6'b000000;
		end
	end
		


endmodule

