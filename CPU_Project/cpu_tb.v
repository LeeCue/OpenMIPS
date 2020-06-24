`timescale	1ns/1ps
`include "defines.v"
module cpu_tb();

	reg		CLOCK_50;
	reg		rst;
	
	reg		k1_ten;
	reg		k2_ge;
	reg		enter;
	
	//每隔10ns，CLOCK_50信号翻转一次，所以每一个周期是20ns，对应50MHZ
	initial	begin
		CLOCK_50 = 1'b0;
		enter = 1'b0;
		forever #10	CLOCK_50 = ~CLOCK_50; 	//50MHZ
	end
	
	initial begin 
		rst = `RstEnable;
		#2000000 rst = `RstDisable;
		//#2000000 k2_ge = 1'b0;
		#8000000 enter = 1'b1;
	end
	
	//例化cpu模块
	cpu cpu0(
			.CLOCK_50(CLOCK_50),
			.rst(rst),
			.enter(enter),
			.k1(k1_ten),
			.k2(k2_ge)
	);
	
endmodule