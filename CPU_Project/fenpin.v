`include "defines.v"
module fenpin(
	input	wire		clk,
	input	wire		rst,
	
	output	reg			clk_1
);

	parameter	T1s	= 24_999_999;
	
	integer		cnt;
	
	always@ (posedge clk) begin 
		if(rst == `RstEnable) begin 
			cnt	<= 0;
			clk_1 <= 0;
		end
		if(cnt == T1s) begin 
			clk_1 <= ~clk_1;
			cnt <= 0;
		end else begin 
			cnt <= cnt + 1;
		end
	end
	
	
endmodule