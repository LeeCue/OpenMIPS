`include "defines.v"
module openmips(
	input	wire		clk,
	input	wire		rst,
	
	input	wire[`RegBus]	rom_data_i,
	output	wire[`RegBus]	rom_addr_o,
	output	wire			rom_ce_o,
	
	//连接到IO单元
	input	wire[`RegBus]	data_i,
	output	wire[`RegBus]	data_o,
	output	wire			io_we_o,
	output	wire			io_re_o,
	
	//来自外部的取消暂停信号
	input	wire			enter_i,
	
	//连接数据存储器RAM
	input	wire[`RegBus]	ram_data_i,
	output	wire[`RegBus]	ram_addr_o,
	output	wire[`RegBus]	ram_data_o,
	output	wire			ram_we_o,
	output	wire			ram_re_o,
	output	wire[3:0]		ram_sel_o,
	output	wire			ram_ce_o
);

	//连接IF/ID模块与译码阶段ID模块的变量
	wire[`InstAddrBus]		pc;
	wire[`InstAddrBus]		id_pc_i;
	wire[`InstBus]			id_inst_i;
	
	
	//连接译码阶段ID模块输出与ID/EX模块输入的变量
	wire[`AluOpBus]		id_aluop_o;
	wire[`AluSelBus]	id_alusel_o;
	wire[`RegBus]		id_reg1_o;
	wire[`RegBus]		id_reg2_o;
	wire				id_wreg_o;
	wire[`RegAddrBus]	id_wd_o;
	wire[`RegBus]		id_immediate_o;
	wire				id_alusrc_o;
	wire				id_memW_o;			
	wire				id_memR_o;
	wire				id_in_o;
	wire				id_out_o;
	
	//连接译码阶段ID模块与PC模块的输入的变量
	wire				id_branch_o;
	wire[`RegBus]		id_pc_o;
	
	
	//连接ID/EX模块输出与执行阶段EX模块的输入的变量
	wire[`AluOpBus]		ex_aluop_i;
	wire[`AluSelBus]	ex_alusel_i;
	wire[`RegBus]		ex_reg1_i;
	wire[`RegBus]		ex_reg2_i;
	wire				ex_wreg_i;
	wire[`RegAddrBus]	ex_wd_i;
	wire[`RegBus]		ex_immediate_i;
	wire				ex_alusrc_i;			
	wire				ex_memW_i;			
	wire				ex_memR_i;
	wire				ex_in_i;
	wire				ex_out_i;
	
	//连接执行阶段EX模块的输出与EX/MEM模块的输入的变量
	wire				ex_wreg_o;
	wire[`RegAddrBus]	ex_wd_o;
	wire[`RegBus]		ex_wdata_o;
	wire[`RegBus]		ex_mem_addr_o;		
	wire				ex_memW_o;			
	wire				ex_memR_o;
	wire				ex_in_o;
	wire				ex_out_o;
	
	
	//连接EX/MEM模块的输出与访存阶段MEM模块的输入变量
	wire				mem_wreg_i;
	wire[`RegAddrBus]	mem_wd_i;
	wire[`RegBus]		mem_wdata_i;
	wire[`RegBus]		mem_addr_i;			
	wire				memW_i;				
	wire				memR_i;
	wire				mem_in_i;
	wire				mem_out_i;
	
	//连接访存阶段MEM模块的输出与MEM/WB模块的输入变量
	wire				mem_wreg_o;
	wire[`RegAddrBus]	mem_wd_o;
	wire[`RegBus]		mem_wdata_o;
	
	//连接MEM/WB模块的输出与回写阶段的输入变量
	wire				wb_wreg_i;
	wire[`RegAddrBus]	wb_wd_i;
	wire[`RegBus]		wb_wdata_i;
	
	
	//连接译码阶段ID模块与通用寄存器Regfile模块的变量
	wire				reg1_read;
	wire				reg2_read;
	wire[`RegBus]		reg1_data;
	wire[`RegBus]		reg2_data;
	wire[`RegAddrBus]	reg1_addr;
	wire[`RegAddrBus]	reg2_addr;
	
	//连接CTRL模块与各个流水级之间的变量
	wire[5:0]			stall_out;
	
	//例化CTRL模块
	ctrl ctrl0(
			.rst(rst),
			.stallreq_from_mem(mem_in_i),
			.enter(enter_i),
			.stall(stall_out)
	);
	
	//PC_reg例化
	pc_reg pc_reg0(
			.clk(clk),	.rst(rst),	.pc(pc),	.ce(rom_ce_o),
			.branch_i(id_branch_o),		.pc_i(id_pc_o),
			
			//从模块传递过来的信息
			.stall(stall_out)	
	);
	
	
	assign	rom_addr_o = pc;		//指令存储器的输入地址就是pc的值
	
	
	//IF/ID模块例化
	if_id if_id0(
			.clk(clk),	.rst(rst),	.if_pc(pc),
			.if_inst(rom_data_i),	.id_pc(id_pc_i),
			.id_inst(id_inst_i),
			
			//从模块传递过来的信息
			.stall(stall_out)
	);
	
	
	//译码阶段ID模块例化
	id id0(
			.rst(rst),	.pc_i(id_pc_i),	.inst_i(id_inst_i),
		
			//来自Regfile模块的输入
			.reg1_data_i(reg1_data),	.reg2_data_i(reg2_data),
		
			//送到Regfile模块的信息
			.reg1_read_o(reg1_read),	.reg2_read_o(reg2_read),
			.reg1_addr_o(reg1_addr),	.reg2_addr_o(reg2_addr),
			
			//处于执行阶段的指令运算结果、及指令类型
			.ex_wreg_i(ex_wreg_o),		.ex_wdata_i(ex_wdata_o),
			.ex_wd_i(ex_wd_o),
			
			//处于访存阶段的指令运算结果
			.mem_wreg_i(mem_wreg_o),	.mem_wdata_i(mem_wdata_o),
			.mem_wd_i(mem_wd_o),
			
			//送到ID/EX模块的信息
			.aluop_o(id_aluop_o),		.alusel_o(id_alusel_o),
			.reg1_o(id_reg1_o),			.reg2_o(id_reg2_o),
			.wd_o(id_wd_o),				.wreg_o(id_wreg_o),
			.immediate(id_immediate_o),	.alusrc_o(id_alusrc_o),
			.in_o(id_in_o),				.out_o(id_out_o),
			
			//送到访存阶段的信息
			.memW_o(id_memW_o),			.memR_o(id_memR_o),
			
			//送到PC模块的信息
			.branch_o(id_branch_o),		.pc_o(id_pc_o)
	);
	
	
	//通用寄存器Regfile模块例化
	regfile regfile0(
			.clk(clk),					.rst(rst),
			.we(wb_wreg_i),				.waddr(wb_wd_i),
			.wdata(wb_wdata_i),			.re1(reg1_read),
			.raddr1(reg1_addr),			.rdata1(reg1_data),
			.re2(reg2_read),			.raddr2(reg2_addr),
			.rdata2(reg2_data)
	);
	
	
	//ID/EX模块例化
	id_ex id_ex0(
			.clk(clk),						.rst(rst),
			
			//从译码阶段ID模块传递过来的信息
			.id_aluop(id_aluop_o),			.id_alusel(id_alusel_o),
			.id_reg1(id_reg1_o),			.id_reg2(id_reg2_o),
			.id_wd(id_wd_o),				.id_wreg(id_wreg_o),
			.id_imm(id_immediate_o),		.id_alusrc(id_alusrc_o),
			.id_memW(id_memW_o),			.id_memR(id_memR_o),
			.id_in(id_in_o),				.id_out(id_out_o),
			
			//从模块传递过来的信息
			.stall(stall_out),
			
			//传递到执行阶段EX模块的信息
			.ex_aluop(ex_aluop_i),			.ex_alusel(ex_alusel_i),
			.ex_reg1(ex_reg1_i),			.ex_reg2(ex_reg2_i),
			.ex_wd(ex_wd_i),				.ex_imm(ex_immediate_i),
			.ex_alusrc(ex_alusrc_i),		.ex_wreg(ex_wreg_i),
			.ex_memW(ex_memW_i),			.ex_memR(ex_memR_i),
			.ex_in(ex_in_i),				.ex_out(ex_out_i)
	);
	
	
	//EX模块例化
	ex ex0(
			.rst(rst),
			
			//从ID/EX模块传递过来的值
			.aluop_i(ex_aluop_i),			.alusel_i(ex_alusel_i),
			.reg1_i(ex_reg1_i),				.reg2_i(ex_reg2_i),
			.wd_i(ex_wd_i),					.imm_i(ex_immediate_i),
			.wreg_i(ex_wreg_i),				.alusrc_i(ex_alusrc_i),
			.memW_i(ex_memW_i),				.memR_i(ex_memR_i),
			.in_i(ex_in_i),					.out_i(ex_out_i),
			
			//输出到EX/MEM模块的信息
			.wd_o(ex_wd_o),					.wreg_o(ex_wreg_o),
			.wdata_o(ex_wdata_o),			.mem_addr_o(ex_mem_addr_o),
			.memW_o(ex_memW_o),				.memR_o(ex_memR_o),
			.in_o(ex_in_o),					.out_o(ex_out_o)
	);

	
	//EX/MEM模块例化
	ex_mem ex_mem0(
			.clk(clk),						.rst(rst),
			
			//来自执行阶段EX模块的信息
			.ex_wd(ex_wd_o),				.ex_wreg(ex_wreg_o),
			.ex_wdata(ex_wdata_o),			.ex_memW(ex_memW_o),
			.ex_memR(ex_memR_o),			.ex_addr(ex_mem_addr_o),
			.ex_in(ex_in_o),				.ex_out(ex_out_o),
			
			//来自控制模块的信息
			.stall(stall_out),
			
			//送到访存阶段MEM模块的信息
			.mem_wd(mem_wd_i),				.mem_wreg(mem_wreg_i),
			.mem_wdata(mem_wdata_i),		.mem_W(memW_i),
			.mem_R(memR_i),					.mem_addr(mem_addr_i),
			.mem_in(mem_in_i),				.mem_out(mem_out_i)
	);


	//MEM模块例化
	mem mem0(
			.rst(rst),
			
			//来自EX/MEM模块的信息
			.wd_i(mem_wd_i),				.wreg_i(mem_wreg_i),
			.wdata_i(mem_wdata_i),			.memW_i(memW_i),
			.memR_i(memR_i),				.mem_addr_i(mem_addr_i),
			.mem_in(mem_in_i),				.mem_out(mem_out_i),
			
			//送到MEM/WB模块的信息
			.wd_o(mem_wd_o),				.wreg_o(mem_wreg_o),
			.wdata_o(mem_wdata_o),
		
			//来自于IN单元的数据
			.data_in(data_i),
			
			//送到OUT单元的数据
			.data_out(data_o),				.io_we(io_we_o),
			.io_re(io_re_o),
			
			//来自数据存储器的信息
			.mem_data_i(ram_data_i),
			
			//送到数据寄存器的信息
			.mem_addr_o(ram_addr_o),		.mem_we_o(ram_we_o),
			.mem_re_o(ram_re_o),			.mem_sel_o(ram_sel_o),
			.mem_data_o(ram_data_o),		.mem_ce_o(ram_ce_o)
	);
	
	
	//MEM/WB模块例化
	mem_wb mem_wb(
			.clk(clk),						.rst(rst),
			
			//来自访存阶段MEM模块的信息
			.mem_wd(mem_wd_o),				.mem_wreg(mem_wreg_o),
			.mem_wdata(mem_wdata_o),
			
			//来自控制模块的信息
			.stall(stall_out),
			
			//送到回写阶段的信息
			.wb_wd(wb_wd_i),				.wb_wreg(wb_wreg_i),
			.wb_wdata(wb_wdata_i)
	);


endmodule