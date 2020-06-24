`include "defines.v"
module id(
	input	wire	rst,
	input	wire[`InstAddrBus]		pc_i,
	input	wire[`InstBus]			inst_i,
	
	//处于执行阶段的指令运算结果、以及指令类型
	input	wire					ex_wreg_i,
	input	wire[`RegBus]			ex_wdata_i,
	input	wire[`RegAddrBus]		ex_wd_i,
	
	//处于访存阶段的指令的运算结果
	input	wire					mem_wreg_i,
	input	wire[`RegBus]			mem_wdata_i,
	input	wire[`RegAddrBus]		mem_wd_i,
	
	//读取的Regfile的值
	input	wire[`RegBus]			reg1_data_i,
	input	wire[`RegBus]			reg2_data_i,
	
	//输出到Regfile的信息
	output	reg						reg1_read_o,
	output	reg						reg2_read_o,
	output	reg[`RegAddrBus]		reg1_addr_o,
	output	reg[`RegAddrBus]		reg2_addr_o,
	
	//送到执行阶段的信息
	output	reg[`AluOpBus]			aluop_o,
	output 	reg[`AluSelBus]			alusel_o,
	output	reg[`RegBus]			reg1_o,
	output	reg[`RegBus]			reg2_o,
	output	reg[`RegAddrBus]		wd_o,
	output	reg[`RegBus]			immediate,
	output	reg						alusrc_o,
	output	reg						wreg_o,
	
	//送到访存阶段的信息
	output	reg						memW_o,
	output	reg						memR_o,
	output	reg						in_o,
	output	reg						out_o,
	
	//送到PC模块的信息
	output	reg						branch_o,
	output	reg[`RegBus]			pc_o
);

	//取指令中的指令码、功能码
	wire[5:0] op  = inst_i[31:26];		//指令码
	wire[4:0] op2 = inst_i[10:6];		//取sa字段
	wire[5:0] op3 = inst_i[5:0];		//Func字段
	wire[4:0] op4 = inst_i[20:16];		//取目的寄存器地址
	wire[15:0] imm = inst_i[15:0];		//取立即数字段
	
	wire[`RegBus]	imm_sll2;			//立即数左移2
	wire[`RegBus]	pc_plus_4;			
	
	assign	pc_plus_4 = pc_i + 4;
	
	assign	imm_sll2 = {14'b0,inst_i[15:0],2'b00};

	
	//表示指令是否有效
	reg instvalid;
	
	//一、对指令进行译码
	always@ (*) begin
		if(rst == `RstEnable) begin
			aluop_o		<= `EXE_nop_op;
			alusel_o	<= `EXE_NOP_sel;
			wd_o		<= `NOPRegAddr;
			wreg_o		<= `WriteDisable;
			instvalid	<= `InstInvalid;
			reg1_read_o	<= `ReadDisable;
			reg2_read_o	<= `ReadDisable;
			reg1_addr_o	<= `NOPRegAddr;
			reg2_addr_o	<= `NOPRegAddr;
			alusrc_o	<= 1'b0;
			immediate	<= 32'h0;
			memW_o		<= `WriteDisable;
			memR_o		<= `ReadDisable;
			branch_o	<= `NotBranch;
			pc_o		<= `ZeroWord;
			in_o		<= `NotIn;
			out_o		<= `NotOut;
		end	else begin
			aluop_o		<= `EXE_nop_op;
			alusel_o	<= `EXE_NOP_sel;
			wd_o		<=  inst_i[15:11];		//默认写入15:11位表示寄存器地址
			wreg_o		<= `WriteDisable;
			instvalid	<= `InstInvalid;
			reg1_read_o	<= `ReadDisable;
			reg2_read_o	<= `ReadDisable;
			reg1_addr_o	<=  inst_i[25:21];		//默认通过Regfile读端口1读取的寄存器地址
			reg2_addr_o	<=  inst_i[20:16];		//默认通过Regfile读端口2读取的寄存器地址
			alusrc_o	<= 1'b0;
			immediate	<= `ZeroWord;
			memW_o	<= `WriteDisable;
			memR_o	<= `ReadDisable;
			branch_o	<= `NotBranch;
			pc_o		<= `ZeroWord;
			in_o		<= `NotIn;				//默认不需要IN单元
			out_o		<= `NotOut;				//默认不需要OUT单元
			
			case(op)
				`EXE_R_type:	begin			//根据op的值判断是否是R-type指令
				case(op2)
					5'b00000:	begin
						case(op3)			//根据功能码判断是哪种指令
							`EXE_ADD:begin		//add指令
								//运算子类型为
								alusel_o	<= `EXE_ADD_sel;
								//R-type指令 需要将结果写入目的寄存器，所以wreg_o为WriteEnable
								wreg_o		<= `WriteEnable;
								//运算类型为R-type运算
								aluop_o		<= `EXE_arithmetic_op;
								//需要通过Regfile的读端口1读取寄存器
								reg1_read_o	<= `ReadEnable;
								//需要通过Regfile的读端口2读取寄存器
								reg2_read_o	<= `ReadEnable;
								//指令执行要写的目的寄存器地址
								wd_o		<= inst_i[15:11];
								//R-type指令是有效指令
								instvalid	<= `InstValid;
								//R-type指令不需要立即数
								immediate	<= `ZeroWord;
								//R-type指令选择寄存器2中的值
								alusrc_o	<= 1'b0;
							end
							`EXE_SUB:begin
								alusel_o	<= `EXE_SUB_sel;
								wreg_o		<= `WriteEnable;
								aluop_o		<= `EXE_arithmetic_op;
								reg1_read_o	<= `ReadEnable;
								reg2_read_o	<= `ReadEnable;
								wd_o		<= inst_i[15:11];
								instvalid	<= `InstValid;
								immediate	<= `ZeroWord;
								alusrc_o	<= 1'b0;
							end
							`EXE_OR:begin
								alusel_o	<= `EXE_OR_sel;
								wreg_o		<= `WriteEnable;
								aluop_o		<= `EXE_arithmetic_op;
								reg1_read_o	<= `ReadEnable;
								reg2_read_o	<= `ReadEnable;
								wd_o		<= inst_i[15:11];
								instvalid	<= `InstValid;
								immediate	<= `ZeroWord;
								alusrc_o	<= 1'b0;
							end
							`EXE_AND:begin
								alusel_o	<= `EXE_AND_sel;
								wreg_o		<= `WriteEnable;
								aluop_o		<= `EXE_arithmetic_op;
								reg1_read_o	<= `ReadEnable;
								reg2_read_o	<= `ReadEnable;
								wd_o		<= inst_i[15:11];
								instvalid	<= `InstValid;
								immediate	<= `ZeroWord;
								alusrc_o	<= 1'b0;
							end
							`EXE_SLT:begin
								alusel_o	<= `EXE_SLT_sel;
								wreg_o		<= `WriteEnable;
								aluop_o		<= `EXE_arithmetic_op;
								reg1_read_o	<= `ReadEnable;
								reg2_read_o	<= `ReadEnable;
								wd_o		<= inst_i[15:11];
								instvalid	<= `InstValid;
								immediate	<= `ZeroWord;
								alusrc_o	<= 1'b0;
							end
							default:begin
							end
							endcase
						end
					default:begin
					end
					endcase
				end
				`EXE_lw_m:	begin 
					//lw_m指令 需要将读出结果写入目的寄存器，所以wreg_o为WriteEnable
					wreg_o		<= `WriteEnable;
					//运算类型为I-type运算
					aluop_o		<= `EXE_ls_op;
					alusel_o	<= `EXE_ADD_sel;
					//需要通过Regfile的读端口1读取寄存器，作为寻址地址中的基值
					reg1_read_o	<= `ReadEnable;
					//不需要通过Regfile的读端口2读取寄存器
					reg2_read_o	<= `ReadDisable;
					//指令执行要写的目的寄存器地址
					wd_o		<= inst_i[20:16];
					//lw_m指令是有效指令
					instvalid	<= `InstValid;
					//lw_m指令需要立即数
					immediate	<= inst_i[15:0];
					//lw_m指令选择立即数，作为寻址地址中的偏移量
					alusrc_o	<= 1'b1;
					//lw_m型指令需要访存。lw_m不需要往存储单元写入数据，需要读出数据
					memW_o	<= `WriteDisable;
					memR_o	<= `ReadEnable;
				end
				`EXE_sw_m:	begin 
					//sw_m指令 不需要将读出结果写入目的寄存器，所以wreg_o为WriteDisable
					wreg_o		<= `WriteDisable;
					//运算类型为I-type运算
					aluop_o		<= `EXE_ls_op;
					alusel_o	<= `EXE_ADD_sel;
					//需要通过Regfile的读端口1读取寄存器，作为寻址地址中的基值
					reg1_read_o	<= `ReadEnable;
					//需要通过Regfile的读端口2读取寄存器，读出要保存的数
					reg2_read_o	<= `ReadEnable;
					//指令执行要写的目的寄存器地址，sw_m不需要要写入的目的寄存器的地址
					wd_o		<= `NOPRegAddr;
					//sw_m指令是有效指令
					instvalid	<= `InstValid;
					//sw_m指令需要立即数
					immediate	<= inst_i[15:0];
					//sw_m指令选择立即数
					alusrc_o	<= 1'b1;
					//sw_m指令需要访存。sw_m需要往存储单元写入数据，不需要读出数据
					memW_o	<= `WriteEnable;
					memR_o	<= `ReadDisable;
					branch_o	<= `NotBranch;
				end
				`EXE_beq: begin 
					//beq指令 不需要将读出结果写入目的寄存器，所以wreg_o为WriteDisable
					wreg_o		<= `WriteDisable;
					//运算类型为无运算类型
					aluop_o		<= `EXE_nop_op;
					alusel_o	<= `EXE_NOP_sel;
					//需要通过Regfile的读端口1读取寄存器，作为转移判断中第一个数
					reg1_read_o	<= `ReadEnable;
					//需要通过Regfile的读端口2读取寄存器，作为转移判断中第二个数
					reg2_read_o	<= `ReadEnable;
					//指令执行要写的目的寄存器地址，beq不需要要写入的目的寄存器的地址
					wd_o		<= `NOPRegAddr;
					//beq指令是有效指令
					instvalid	<= `InstValid;
					//beq指令不需要将立即数向后传递
					immediate	<= `ZeroWord;
					alusrc_o	<= 1'b1;
					if(reg1_o == reg2_o) begin 
						branch_o	<= `Branch;
						pc_o		<= pc_plus_4 + imm_sll2;	
					end
				end
				`EXE_j: begin 
					//j指令 不需要将读出结果写入目的寄存器，所以wreg_o为WriteDisable
					wreg_o		<= `WriteDisable;
					//运算类型为无运算类型
					aluop_o		<= `EXE_nop_op;
					alusel_o	<= `EXE_NOP_sel;
					//不需要通过Regfile的读端口1读取寄存器
					reg1_read_o	<= `ReadDisable;
					//不需要通过Regfile的读端口2读取寄存器
					reg2_read_o	<= `ReadDisable;
					//指令执行要写的目的寄存器地址，j不需要要写入的目的寄存器的地址
					wd_o		<= `NOPRegAddr;
					//j指令是有效指令
					instvalid	<= `InstValid;
					//j指令不需要将立即数向后传递
					immediate	<= `ZeroWord;
					//j指令选择立即数
					alusrc_o	<= 1'b1;
					branch_o	<= `Branch;
					pc_o		<= {pc_plus_4[31:28],inst_i[25:0],2'b00};
				end
				`EXE_lw_io: begin 
					//lw_io指令 需要将读出结果写入目的寄存器，所以wreg_o为WriteEnable
					wreg_o		<= `WriteEnable;
					//运算类型为无运算
					aluop_o		<= `EXE_ls_op;
					alusel_o	<= `EXE_NOP_sel;
					//不需要通过Regfile的读端口1读取寄存器，作为寻址地址中的基值
					reg1_read_o	<= `ReadDisable;
					//不需要通过Regfile的读端口2读取寄存器
					reg2_read_o	<= `ReadDisable;
					//指令执行要写的目的寄存器地址
					wd_o		<= inst_i[20:16];
					//lw_io指令是有效指令
					instvalid	<= `InstValid;
					//lw_io指令不需要立即数
					immediate	<= `ZeroWord;
					//lw_io指令不选择立即数，作为寻址地址中的偏移量
					alusrc_o	<= 1'b1;
					//lw_io指令需要访存。lw_io不需要往存储单元写入数据，不需要读出数据
					memW_o		<= `WriteDisable;
					memR_o		<= `ReadDisable;
					//iw_io指令需要IO单元。将IN单元的数字直接输入到寄存器中
					in_o		<= `In;
					out_o		<= `NotOut;
				end
				`EXE_sw_io: begin 
					//sw_io指令 不需要将读出结果写入目的寄存器，所以wreg_o为WriteDisable
					wreg_o		<= `WriteDisable;
					//运算类型为无运算
					aluop_o		<= `EXE_ls_op;
					alusel_o	<= `EXE_NOP_sel;
					//不需要通过Regfile的读端口1读取寄存器，作为寻址地址中的基值
					reg1_read_o	<= `ReadDisable;
					//需要通过Regfile的读端口2读取寄存器，作为要输出的数据
					reg2_read_o	<= `ReadEnable;
					//指令执行要写的目的寄存器地址
					wd_o		<= `NOPRegAddr;
					//sw_io指令是有效指令
					instvalid	<= `InstValid;
					//sw_io指令不需要立即数
					immediate	<= `ZeroWord;
					//sw_io指令不选择立即数，作为寻址地址中的偏移量
					alusrc_o	<= 1'b1;
					//sw_io指令需要访存。sw_m不需要往存储单元写入数据，不需要读出数据
					memW_o		<= `WriteDisable;
					memR_o		<= `ReadDisable;
					//sw_io指令需要IO单元。将寄存器中的数据直接输出OUT单元
					in_o		<= `NotIn;
					out_o		<= `Out;
				end
			default:begin
			end
			endcase
		end
	end					
	
	
	//确定进行运算的源操作数1
	always@ (*) begin
		if(rst == `RstEnable) begin
			reg1_o	<= `ZeroWord;
		end
		else if((reg1_read_o == `ReadEnable) && (ex_wreg_i == `WriteEnable)
					&& (ex_wd_i == reg1_addr_o)) begin 
			reg1_o <= ex_wdata_i;
		end
		else if((reg1_read_o == `ReadEnable) && (mem_wreg_i == `WriteEnable)
					&& (mem_wd_i == reg1_addr_o)) begin 
			reg1_o <= mem_wdata_i;
		end
		else if(reg1_read_o == `ReadEnable) begin
			reg1_o	<=	reg1_data_i;	//Regfile读端口1的输出值
		end 
		else begin
			reg1_o	<= `ZeroWord;
		end
	end
	
	
	
	//确定进行运算的源操作数2
	always@ (*) begin
		if(rst == `RstEnable) begin
			reg2_o	<= `ZeroWord;
		end
		else if((reg2_o == `ReadEnable) && (ex_wreg_i == `WriteEnable)
					&& (ex_wd_i == reg2_addr_o)) begin 
			reg2_o <= ex_wdata_i;
		end
		else if((reg2_o == `ReadEnable) && (mem_wreg_i == `WriteEnable)
					&& (mem_wd_i == reg2_addr_o)) begin 
			reg2_o <= mem_wdata_i;
		end
		else if(reg2_read_o == `ReadEnable) begin
			reg2_o	<= reg2_data_i;
		end 
		else begin
			reg2_o	<= `ZeroWord;
		end
	end
	
endmodule
			
	
				
			
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	