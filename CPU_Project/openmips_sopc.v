`include "defines.v"
module openmips_spoc(
	input	wire	clk,
	input	wire	rst,

	//�����ⲿ���������
	input	wire[`RegBus]	data_show_i,
	//�����ⲿ��ȡ����ͣ�ź�
	input	wire			enter,
	
	//�͵��ⲿ�������Ϣ
	output	wire[`RegBus]	data_show_o,
	output	wire			out_o,
	
	//input	wire	ce,
	output	wire[`InstAddrBus]	pc
);

	//����ָ��洢��ROM
	wire[`InstAddrBus]	inst_addr;
	wire[`InstBus]		inst;
	wire				rom_ce;

	//�������ݴ洢��RAM
	wire				memW_i;
	wire				memR_i;
	wire[`RegBus]		mem_addr_i;
	wire[`RegBus]		mem_data_i;
	wire[`RegBus]		mem_data_o;
	wire[3:0]			mem_sel_i;
	wire				mem_ce_i;
	
	//����IO��Ԫ
	wire				io_we_i;
	wire				io_re_i;
	wire[`RegBus]		io_data;
	
	//����������Openmips
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
	
	
	//����ָ��洢��ROM
	inst_rom inst_rom0(
			.ce(rom_ce),		
			.addr(inst_addr),			.inst(inst)
	);
	
	//�������ݼĴ���RAM
	data_ram data_ram0(
			.clk(clk),					.ce(mem_ce_i),
			.we(memW_i),				.re(memR_i),
			.addr(mem_addr_i),			.sel(mem_sel_i),
			.data_i(mem_data_i),		.data_o(mem_data_o)
	);

	//����IO��Ԫ
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
	


