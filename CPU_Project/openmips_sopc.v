`include "defines.v"
module openmips_spoc(
	input	wire	clk,
	input	wire	rst,

	//来自外部输入的数据
	input	wire[`RegBus]	data_show_i,
	//来自外部的取消暂停信号
	input	wire			enter,
	
	//送到外部输出的信息
	output	wire[`RegBus]	data_show_o,
	output	wire			out_o,
	
	//input	wire	ce,
	output	wire[`InstAddrBus]	pc
);

	//连接指令存储器ROM
	wire[`InstAddrBus]	inst_addr;
	wire[`InstBus]		inst;
	wire				rom_ce;

	//连接数据存储器RAM
	wire				memW_i;
	wire				memR_i;
	wire[`RegBus]		mem_addr_i;
	wire[`RegBus]		mem_data_i;
	wire[`RegBus]		mem_data_o;
	wire[3:0]			mem_sel_i;
	wire				mem_ce_i;
	
	//连接IO单元
	wire				io_we_i;
	wire				io_re_i;
	wire[`RegBus]		io_data;
	
	//例化处理器Openmips
	openmips openmips0(
			.clk(clk),			.rst(rst),
			.rom_addr_o(inst_addr),		.rom_data_i(inst),
			.rom_ce_o(rom_ce),			
			
			.ram_data_i(mem_data_o),	.ram_addr_o(mem_addr_i),
			.ram_data_o(mem_data_i),	.ram_we_o(memW_i),
			.ram_re_o(memR_i),			.ram_sel_o(mem_sel_i),
			.ram_ce_o(mem_ce_i),
			
			.data_i(data_show_i),		.data_o(io_data),
			.io_we_o(io_we_i),			.io_re_o(io_re_i),
			
			.enter_i(enter)
	);
	
	
	//例化指令存储器ROM
	inst_rom inst_rom0(
			.ce(rom_ce),		
			.addr(inst_addr),			.inst(inst)
	);
	
	//例化数据寄存器RAM
	data_ram data_ram0(
			.clk(clk),					.ce(mem_ce_i),
			.we(memW_i),				.re(memR_i),
			.addr(mem_addr_i),			.sel(mem_sel_i),
			.data_i(mem_data_i),		.data_o(mem_data_o)
	);

	//例化IO单元
	io io0(
			.clk(clk),					.rst(rst),
			.we(io_we_i),				.re(io_re_i),
			.data_i(io_data),			
			.data_show_i(data_show_i),
			.out(out_o)
	);
	 
	assign data_show_o = io_data;
	assign pc = inst_addr;
	
	
endmodule
	


