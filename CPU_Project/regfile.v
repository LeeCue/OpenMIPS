`include "defines.v"
module regfile(
	input	wire	clk,
	input	wire	rst,
	
	//д�˿�
	input	wire				we,			//дʹ��
	input	wire[`RegAddrBus]	waddr,		//д��Ĵ����ĵ�ַ
	input	wire[`RegBus]		wdata,		//д�������
	
	//���˿�1
	input	wire				re1,		//�˿�1�Ķ�ʹ��
	input	wire[`RegAddrBus]	raddr1,		//�˿�1�ĵ�ַ
	output	reg[`RegBus]		rdata1,		//�˿�1������
	
	//���˿�2
	input	wire				re2,		//�˿�2�Ķ�ʹ��
	input	wire[`RegAddrBus]	raddr2,		//�˿�2�ĵ�ַ
	output	reg[`RegBus]		rdata2		//�˿�2������
);


	//����32��32���Ĵ���
	reg[`RegBus]	regs[0:`RegNum-1];
	
	initial	begin
		regs[1] = 32'd5;
		regs[2] = 32'd5;
		regs[3] = 32'd6;
		regs[4] = 32'd7;
		regs[5] = 32'd8;
	end
	
	
	//д����
	always@ (posedge clk) begin
		if(rst == `RstDisable) begin
			if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
				regs[waddr] <= wdata;
			end
		end
	end
	
	
	//���˿�1�Ķ�����
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
	
	
	//���˿�2�Ķ�����
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
			
			
			
			
			
			
			
			
			
			
			
			
	
	