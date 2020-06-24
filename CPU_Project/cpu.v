`include "defines.v"
module cpu(
	input	wire		CLOCK_50,
	input	wire		rst,
	input	wire		enter,
	input	wire		k1,
	input	wire		k2,
	
	output	wire[2:0]	sel,
	output	wire[7:0]	seg
);

	wire	clk_1_o;
	wire[`InstAddrBus]		pc_o;
	wire[`RegBus]			data_from_in;
	wire					out;
	wire[`RegBus]			res_o;
	
	//例化sopc模块
	openmips_spoc openmips_spoc0(
			.clk(clk_1_o),				.rst(rst),
			.enter(enter),		.data_show_i(data_from_in),
			
			.data_show_o(res_o),		.out_o(out),
			.pc(pc_o)
	);
	
	//例化data_io模块
	data_io data_io0(
			.clk(CLOCK_50),	.rst(rst),
			.k1_ten(k1),		.k2_ge(k2),
			.pc_in(pc_o),		.res(res_o),
			.out_i(out),		
			
			.data_o(data_from_in),	.sel(sel),
			.seg(seg)
	);
	
	//例化分频模块
	fenpin fenpin0(
			.clk(CLOCK_50),	.rst(rst),
			
			.clk_1(clk_1_o)
	);
	
endmodule
	