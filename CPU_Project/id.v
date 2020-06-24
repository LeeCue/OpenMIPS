`include "defines.v"
module id(
	input	wire	rst,
	input	wire[`InstAddrBus]		pc_i,
	input	wire[`InstBus]			inst_i,
	
	//����ִ�н׶ε�ָ�����������Լ�ָ������
	input	wire					ex_wreg_i,
	input	wire[`RegBus]			ex_wdata_i,
	input	wire[`RegAddrBus]		ex_wd_i,
	
	//���ڷô�׶ε�ָ���������
	input	wire					mem_wreg_i,
	input	wire[`RegBus]			mem_wdata_i,
	input	wire[`RegAddrBus]		mem_wd_i,
	
	//��ȡ��Regfile��ֵ
	input	wire[`RegBus]			reg1_data_i,
	input	wire[`RegBus]			reg2_data_i,
	
	//�����Regfile����Ϣ
	output	reg						reg1_read_o,
	output	reg						reg2_read_o,
	output	reg[`RegAddrBus]		reg1_addr_o,
	output	reg[`RegAddrBus]		reg2_addr_o,
	
	//�͵�ִ�н׶ε���Ϣ
	output	reg[`AluOpBus]			aluop_o,
	output 	reg[`AluSelBus]			alusel_o,
	output	reg[`RegBus]			reg1_o,
	output	reg[`RegBus]			reg2_o,
	output	reg[`RegAddrBus]		wd_o,
	output	reg[`RegBus]			immediate,
	output	reg						alusrc_o,
	output	reg						wreg_o,
	
	//�͵��ô�׶ε���Ϣ
	output	reg						memW_o,
	output	reg						memR_o,
	output	reg						in_o,
	output	reg						out_o,
	
	//�͵�PCģ�����Ϣ
	output	reg						branch_o,
	output	reg[`RegBus]			pc_o
);

	//ȡָ���е�ָ���롢������
	wire[5:0] op  = inst_i[31:26];		//ָ����
	wire[4:0] op2 = inst_i[10:6];		//ȡsa�ֶ�
	wire[5:0] op3 = inst_i[5:0];		//Func�ֶ�
	wire[4:0] op4 = inst_i[20:16];		//ȡĿ�ļĴ�����ַ
	wire[15:0] imm = inst_i[15:0];		//ȡ�������ֶ�
	
	wire[`RegBus]	imm_sll2;			//����������2
	wire[`RegBus]	pc_plus_4;			
	
	assign	pc_plus_4 = pc_i + 4;
	
	assign	imm_sll2 = {14'b0,inst_i[15:0],2'b00};

	
	//��ʾָ���Ƿ���Ч
	reg instvalid;
	
	//һ����ָ���������
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
			wd_o		<=  inst_i[15:11];		//Ĭ��д��15:11λ��ʾ�Ĵ�����ַ
			wreg_o		<= `WriteDisable;
			instvalid	<= `InstInvalid;
			reg1_read_o	<= `ReadDisable;
			reg2_read_o	<= `ReadDisable;
			reg1_addr_o	<=  inst_i[25:21];		//Ĭ��ͨ��Regfile���˿�1��ȡ�ļĴ�����ַ
			reg2_addr_o	<=  inst_i[20:16];		//Ĭ��ͨ��Regfile���˿�2��ȡ�ļĴ�����ַ
			alusrc_o	<= 1'b0;
			immediate	<= `ZeroWord;
			memW_o	<= `WriteDisable;
			memR_o	<= `ReadDisable;
			branch_o	<= `NotBranch;
			pc_o		<= `ZeroWord;
			in_o		<= `NotIn;				//Ĭ�ϲ���ҪIN��Ԫ
			out_o		<= `NotOut;				//Ĭ�ϲ���ҪOUT��Ԫ
			
			case(op)
				`EXE_R_type:	begin			//����op��ֵ�ж��Ƿ���R-typeָ��
				case(op2)
					5'b00000:	begin
						case(op3)			//���ݹ������ж�������ָ��
							`EXE_ADD:begin		//addָ��
								//����������Ϊ
								alusel_o	<= `EXE_ADD_sel;
								//R-typeָ�� ��Ҫ�����д��Ŀ�ļĴ���������wreg_oΪWriteEnable
								wreg_o		<= `WriteEnable;
								//��������ΪR-type����
								aluop_o		<= `EXE_arithmetic_op;
								//��Ҫͨ��Regfile�Ķ��˿�1��ȡ�Ĵ���
								reg1_read_o	<= `ReadEnable;
								//��Ҫͨ��Regfile�Ķ��˿�2��ȡ�Ĵ���
								reg2_read_o	<= `ReadEnable;
								//ָ��ִ��Ҫд��Ŀ�ļĴ�����ַ
								wd_o		<= inst_i[15:11];
								//R-typeָ������Чָ��
								instvalid	<= `InstValid;
								//R-typeָ���Ҫ������
								immediate	<= `ZeroWord;
								//R-typeָ��ѡ��Ĵ���2�е�ֵ
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
					//lw_mָ�� ��Ҫ���������д��Ŀ�ļĴ���������wreg_oΪWriteEnable
					wreg_o		<= `WriteEnable;
					//��������ΪI-type����
					aluop_o		<= `EXE_ls_op;
					alusel_o	<= `EXE_ADD_sel;
					//��Ҫͨ��Regfile�Ķ��˿�1��ȡ�Ĵ�������ΪѰַ��ַ�еĻ�ֵ
					reg1_read_o	<= `ReadEnable;
					//����Ҫͨ��Regfile�Ķ��˿�2��ȡ�Ĵ���
					reg2_read_o	<= `ReadDisable;
					//ָ��ִ��Ҫд��Ŀ�ļĴ�����ַ
					wd_o		<= inst_i[20:16];
					//lw_mָ������Чָ��
					instvalid	<= `InstValid;
					//lw_mָ����Ҫ������
					immediate	<= inst_i[15:0];
					//lw_mָ��ѡ������������ΪѰַ��ַ�е�ƫ����
					alusrc_o	<= 1'b1;
					//lw_m��ָ����Ҫ�ô档lw_m����Ҫ���洢��Ԫд�����ݣ���Ҫ��������
					memW_o	<= `WriteDisable;
					memR_o	<= `ReadEnable;
				end
				`EXE_sw_m:	begin 
					//sw_mָ�� ����Ҫ���������д��Ŀ�ļĴ���������wreg_oΪWriteDisable
					wreg_o		<= `WriteDisable;
					//��������ΪI-type����
					aluop_o		<= `EXE_ls_op;
					alusel_o	<= `EXE_ADD_sel;
					//��Ҫͨ��Regfile�Ķ��˿�1��ȡ�Ĵ�������ΪѰַ��ַ�еĻ�ֵ
					reg1_read_o	<= `ReadEnable;
					//��Ҫͨ��Regfile�Ķ��˿�2��ȡ�Ĵ���������Ҫ�������
					reg2_read_o	<= `ReadEnable;
					//ָ��ִ��Ҫд��Ŀ�ļĴ�����ַ��sw_m����ҪҪд���Ŀ�ļĴ����ĵ�ַ
					wd_o		<= `NOPRegAddr;
					//sw_mָ������Чָ��
					instvalid	<= `InstValid;
					//sw_mָ����Ҫ������
					immediate	<= inst_i[15:0];
					//sw_mָ��ѡ��������
					alusrc_o	<= 1'b1;
					//sw_mָ����Ҫ�ô档sw_m��Ҫ���洢��Ԫд�����ݣ�����Ҫ��������
					memW_o	<= `WriteEnable;
					memR_o	<= `ReadDisable;
					branch_o	<= `NotBranch;
				end
				`EXE_beq: begin 
					//beqָ�� ����Ҫ���������д��Ŀ�ļĴ���������wreg_oΪWriteDisable
					wreg_o		<= `WriteDisable;
					//��������Ϊ����������
					aluop_o		<= `EXE_nop_op;
					alusel_o	<= `EXE_NOP_sel;
					//��Ҫͨ��Regfile�Ķ��˿�1��ȡ�Ĵ�������Ϊת���ж��е�һ����
					reg1_read_o	<= `ReadEnable;
					//��Ҫͨ��Regfile�Ķ��˿�2��ȡ�Ĵ�������Ϊת���ж��еڶ�����
					reg2_read_o	<= `ReadEnable;
					//ָ��ִ��Ҫд��Ŀ�ļĴ�����ַ��beq����ҪҪд���Ŀ�ļĴ����ĵ�ַ
					wd_o		<= `NOPRegAddr;
					//beqָ������Чָ��
					instvalid	<= `InstValid;
					//beqָ���Ҫ����������󴫵�
					immediate	<= `ZeroWord;
					alusrc_o	<= 1'b1;
					if(reg1_o == reg2_o) begin 
						branch_o	<= `Branch;
						pc_o		<= pc_plus_4 + imm_sll2;	
					end
				end
				`EXE_j: begin 
					//jָ�� ����Ҫ���������д��Ŀ�ļĴ���������wreg_oΪWriteDisable
					wreg_o		<= `WriteDisable;
					//��������Ϊ����������
					aluop_o		<= `EXE_nop_op;
					alusel_o	<= `EXE_NOP_sel;
					//����Ҫͨ��Regfile�Ķ��˿�1��ȡ�Ĵ���
					reg1_read_o	<= `ReadDisable;
					//����Ҫͨ��Regfile�Ķ��˿�2��ȡ�Ĵ���
					reg2_read_o	<= `ReadDisable;
					//ָ��ִ��Ҫд��Ŀ�ļĴ�����ַ��j����ҪҪд���Ŀ�ļĴ����ĵ�ַ
					wd_o		<= `NOPRegAddr;
					//jָ������Чָ��
					instvalid	<= `InstValid;
					//jָ���Ҫ����������󴫵�
					immediate	<= `ZeroWord;
					//jָ��ѡ��������
					alusrc_o	<= 1'b1;
					branch_o	<= `Branch;
					pc_o		<= {pc_plus_4[31:28],inst_i[25:0],2'b00};
				end
				`EXE_lw_io: begin 
					//lw_ioָ�� ��Ҫ���������д��Ŀ�ļĴ���������wreg_oΪWriteEnable
					wreg_o		<= `WriteEnable;
					//��������Ϊ������
					aluop_o		<= `EXE_ls_op;
					alusel_o	<= `EXE_NOP_sel;
					//����Ҫͨ��Regfile�Ķ��˿�1��ȡ�Ĵ�������ΪѰַ��ַ�еĻ�ֵ
					reg1_read_o	<= `ReadDisable;
					//����Ҫͨ��Regfile�Ķ��˿�2��ȡ�Ĵ���
					reg2_read_o	<= `ReadDisable;
					//ָ��ִ��Ҫд��Ŀ�ļĴ�����ַ
					wd_o		<= inst_i[20:16];
					//lw_ioָ������Чָ��
					instvalid	<= `InstValid;
					//lw_ioָ���Ҫ������
					immediate	<= `ZeroWord;
					//lw_ioָ�ѡ������������ΪѰַ��ַ�е�ƫ����
					alusrc_o	<= 1'b1;
					//lw_ioָ����Ҫ�ô档lw_io����Ҫ���洢��Ԫд�����ݣ�����Ҫ��������
					memW_o		<= `WriteDisable;
					memR_o		<= `ReadDisable;
					//iw_ioָ����ҪIO��Ԫ����IN��Ԫ������ֱ�����뵽�Ĵ�����
					in_o		<= `In;
					out_o		<= `NotOut;
				end
				`EXE_sw_io: begin 
					//sw_ioָ�� ����Ҫ���������д��Ŀ�ļĴ���������wreg_oΪWriteDisable
					wreg_o		<= `WriteDisable;
					//��������Ϊ������
					aluop_o		<= `EXE_ls_op;
					alusel_o	<= `EXE_NOP_sel;
					//����Ҫͨ��Regfile�Ķ��˿�1��ȡ�Ĵ�������ΪѰַ��ַ�еĻ�ֵ
					reg1_read_o	<= `ReadDisable;
					//��Ҫͨ��Regfile�Ķ��˿�2��ȡ�Ĵ�������ΪҪ���������
					reg2_read_o	<= `ReadEnable;
					//ָ��ִ��Ҫд��Ŀ�ļĴ�����ַ
					wd_o		<= `NOPRegAddr;
					//sw_ioָ������Чָ��
					instvalid	<= `InstValid;
					//sw_ioָ���Ҫ������
					immediate	<= `ZeroWord;
					//sw_ioָ�ѡ������������ΪѰַ��ַ�е�ƫ����
					alusrc_o	<= 1'b1;
					//sw_ioָ����Ҫ�ô档sw_m����Ҫ���洢��Ԫд�����ݣ�����Ҫ��������
					memW_o		<= `WriteDisable;
					memR_o		<= `ReadDisable;
					//sw_ioָ����ҪIO��Ԫ�����Ĵ����е�����ֱ�����OUT��Ԫ
					in_o		<= `NotIn;
					out_o		<= `Out;
				end
			default:begin
			end
			endcase
		end
	end					
	
	
	//ȷ�����������Դ������1
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
			reg1_o	<=	reg1_data_i;	//Regfile���˿�1�����ֵ
		end 
		else begin
			reg1_o	<= `ZeroWord;
		end
	end
	
	
	
	//ȷ�����������Դ������2
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
			
	
				
			
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	