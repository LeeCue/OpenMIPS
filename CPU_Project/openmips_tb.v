//ʱ�䵥λ��1ns��������1ps
`timescale	1ns/1ps
`include "defines.v"
module openmips_tb();
	
	reg		CLOCK_10K;
	reg		rst;

	reg		cancel;
	wire[`InstAddrBus]	pc_o;
	wire[`RegBus]		res_o;
	wire				out;
	
	reg				k1_ten_i;
	reg				k2_ge_i;
	wire[`RegBus]	data_from_in;
	wire			clk_1_o;
	
	//ÿ��50000ns��CLOCK_10K�źŷ�תһ�Σ�����ÿһ��������100000ns����Ӧ10KHZ
	initial	begin
		CLOCK_10K = 1'b0;
		cancel = 1'b0;
		forever #50000	CLOCK_10K = ~CLOCK_10K; 	//10KHZ
		//forever #10	CLOCK_10K = ~CLOCK_10K; 	//50MHZ
	end
	
	//��ʼ������ (1HZ)
	initial	begin
		rst = `RstEnable;
		#195 rst = `RstDisable;
		
		#200  k2_ge_i = 1'b1;
		#205  k2_ge_i = 1'b0;
		
		#210  k1_ten_i = 1'b1;
		#220  k1_ten_i = 1'b0; 
		
		//#230  cancel = 1'b1;
		//#235  cancel = 1'b0;
		//#1000 $stop;
	end

	
	//������Сsopc
	openmips_spoc openmips_spoc0(
				.clk(clk_1_o),
				.rst(rst),
				.data_show_i(data_from_in),
				.enter(cancel),
				.pc(pc_o),
				.data_show_o(res_o),
				.out_o(out)
	);
	
	//����data_ioģ�飨������ʵ������չʾ������ݵ�ַ��
	data_io data_io0(
			.clk(CLOCK_10K),			.rst(rst),
			.k1_ten(k1_ten_i),		.k2_ge(k2_ge_i),
			.pc_in(pc_o),			.res(res_o),
			.out_i(out),			.data_o(data_from_in)
	);
	
	//������Ƶģ��
	fenpin fenpin0(
			.clk(CLOCK_10K),			.rst(rst),
			.clk_1(clk_1_o)
	);
	
endmodule