`include "defines.v"
`timescale	1ns/1ns
module fenpin_tb();

	reg		CLOCK_10K;
	reg		rst;
	
	
	initial begin 
		CLOCK_10K = 1'b0;
		forever	#50000	CLOCK_10K = ~CLOCK_10K;
	end
	
	initial begin 
		rst = `RstEnable;
		#200  rst = `RstDisable;
	end
	
	
	//Àý»¯·ÖÆµÄ£¿é
	fenpin fenpin0(
			.clk(CLOCK_10K),		.rst(rst)
	);
	
	
endmodule