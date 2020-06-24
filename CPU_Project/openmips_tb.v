//时间单位是1ns，精度是1ps
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
	
	//每隔50000ns，CLOCK_10K信号翻转一次，所以每一个周期是100000ns，对应10KHZ
	initial	begin
		CLOCK_10K = 1'b0;
		cancel = 1'b0;
		forever #50000	CLOCK_10K = ~CLOCK_10K; 	//10KHZ
		//forever #10	CLOCK_10K = ~CLOCK_10K; 	//50MHZ
	end
	
	//初始化按键 (1HZ)
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

	
	//例化最小sopc
	openmips_spoc openmips_spoc0(
				.clk(clk_1_o),
				.rst(rst),
				.data_show_i(data_from_in),
				.enter(cancel),
				.pc(pc_o),
				.data_show_o(res_o),
				.out_o(out)
	);
	
	//例化data_io模块（用来在实验箱上展示相关数据地址）
	data_io data_io0(
			.clk(CLOCK_10K),			.rst(rst),
			.k1_ten(k1_ten_i),		.k2_ge(k2_ge_i),
			.pc_in(pc_o),			.res(res_o),
			.out_i(out),			.data_o(data_from_in)
	);
	
	//例化分频模块
	fenpin fenpin0(
			.clk(CLOCK_10K),			.rst(rst),
			.clk_1(clk_1_o)
	);
	
endmodule