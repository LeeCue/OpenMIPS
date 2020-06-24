`include "defines.v"
module ex(
	input	wire	rst,
	
	//����׶��͵�ִ�н׶ε���Ϣ
	input	wire[`AluOpBus]		aluop_i,
	input	wire[`AluSelBus]	alusel_i,
	input	wire[`RegBus]		reg1_i,
	input	wire[`RegBus]		reg2_i,
	input	wire[`RegAddrBus]	wd_i,
	input	wire[`RegBus]		imm_i,
	input	wire				wreg_i,
	input	wire				alusrc_i,
	input	wire				memW_i,
	input	wire				memR_i,
	input	wire				in_i,
	input	wire				out_i,
	
	//ִ�н��
	output	reg[`RegAddrBus]	wd_o,
	output	reg		wreg_o,
	output	reg[`RegBus]		wdata_o,
	output	reg[`RegBus]		mem_addr_o,
	
	//�͵��ô�׶ε���Ϣ
	output	reg					memW_o,
	output	reg					memR_o,
	output	reg					in_o,
	output	reg					out_o
);

	wire			ov_sum;				//����������
	wire			reg1_eq_reg2;		//��һ���������Ƿ���ڵڶ���������
	wire			reg1_lt_reg2;		//��һ���������Ƿ�С�ڵڶ���������
	reg[`RegBus]	logicout;			//�����߼�����Ľ��
	reg[`RegBus]	arithmeticres;		//������������Ľ��
	wire[`RegBus]	reg2_i_mux;			//��������ĵڶ���������reg2_i�Ĳ���
	wire[`RegBus]	result_sum;			//����ӷ����
	wire[`RegBus]	data2;				//ALU�ڶ���������
	wire[`RegBus]	left2_data;			//����������2
	
	//һ���������б�����ֵ
	//����Ǽ��������з��űȽ����㣬��ôreg2_i_mux���ڵڶ���������reg2_i�Ĳ��룬����͵��ڵڶ���������reg2_i
	assign	reg2_i_mux = ((alusel_i == `EXE_SUB_sel)  ||
						  (alusel_i == `EXE_SLT_sel))  ?
						  (~reg2_i) + 1 : reg2_i;
	
	//������������2
	assign	left2_data = imm_i << 2;
	
	//ѡ��ALU�ڶ���������
	assign	data2 = (alusrc_i == 1'b1) ? imm_i : reg2_i_mux;
	
	//����ӷ��������Ľ��
	assign	result_sum = reg1_i + data2;
	
	//�����Ƿ�������ӷ�ָ��(add)�ͼ���ָ��(sub)ִ�е�ʱ��
	assign	ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) || 
					  ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));
	
	//���������1�Ƿ�С�ڲ�����2
	assign	reg1_lt_reg2 = ((alusel_i == `EXE_SLT_sel)) ? 
							((reg1_i[31] && !reg2_i[31]) ||
							 (!reg1_i[31] && !reg2_i[31]) && result_sum[31]) ||
							 (reg1_i[31] && reg2_i[31] && result_sum[31])
							 :(reg1_i < reg2_i);
	
	//�������ݲ�ͬ���������ͣ���arithmeticres��logicout��ֵ
	always@ (*) begin
		case(alusel_i)
			`EXE_ADD_sel, `EXE_SUB_sel: begin
				arithmeticres <= result_sum;		//�ӷ�����������
			end
			`EXE_SLT_sel: begin
				arithmeticres <= {31'b0,reg1_lt_reg2};		//�Ƚ�����
			end
			`EXE_AND_sel: begin
				logicout <= reg1_i & reg2_i;		//�߼������
			end
			`EXE_OR_sel: begin
				logicout <= reg1_i | reg2_i;		//�߼������
			end
			default: begin
				arithmeticres <= `ZeroWord;
				logicout <= `ZeroWord;
			end
		endcase
	end
				
	
	//����ȷ��Ҫд����ֵ
	always@ (*) begin
		if(rst == `RstEnable) begin
			wdata_o <= `ZeroWord;
			wd_o	<= `NOPRegAddr;
			memW_o	<= `WriteDisable;
			memR_o	<= `ReadDisable;
			mem_addr_o	<= `ZeroWord;
			wreg_o	<= `WriteDisable;
			in_o	<= `NotIn;
			out_o	<= `NotOut;
		end else begin
			memW_o	<= memW_i;
			memR_o	<= memR_i;
			in_o	<= in_i;
			out_o	<= out_i;
			//�����add��subָ���������������ô����wreg_oΪWriteDisable����д��Ŀ�ļĴ���
			if(((alusel_i == `EXE_ADD_sel) || (alusel_i == `EXE_SUB_sel)) && (ov_sum == 1'b1)) begin
				wreg_o <= `WriteDisable;
			end else begin
				wreg_o <= wreg_i;
			end
			case(aluop_i)
				`EXE_arithmetic_op: begin 					//�����R-typeָ��
					case(alusel_i)
					`EXE_ADD_sel, `EXE_SUB_sel, `EXE_SLT_sel: begin
						wdata_o <= arithmeticres;
						wd_o <=	wd_i;
						mem_addr_o <= `ZeroWord;
					end
					`EXE_AND_sel, `EXE_OR_sel: begin
						wdata_o <= logicout;
						wd_o <=	wd_i;
						mem_addr_o <= `ZeroWord;
					end
					default:	begin
						wdata_o <= `ZeroWord;
						wd_o <=	wd_i;
						mem_addr_o <= `ZeroWord;
					end
					endcase
				end
				`EXE_ls_op: begin 
					mem_addr_o <= arithmeticres;
					wdata_o <= reg2_i;
					wd_o <= wd_i;
				end
			endcase	
		end
	end
endmodule	
	
	
	
	
	
	
	