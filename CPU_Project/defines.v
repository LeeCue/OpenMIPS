//********************   ȫ�ֵĺ궨��   ********************                          
`define RstEnable         1'b1				//��λ�ź���Ч
`define RstDisable        1'b0				//��λ�ź���Ч
`define ZeroWord	  	  32'h00000000		//32λ����ֵ0
`define WriteEnable	      1'b1				//ʹ��д
`define WriteDisable	  1'b0				//��ֹд
`define ReadEnable 	      1'b1				//ʹ�ܶ�
`define ReadDisable 	  1'b0				//��ֹ��
`define AluOpBus	      1:0				//�����׶ε�����AluOp_o�Ŀ���
`define AluSelBus	      3:0				//ִ�н׶ε�����AluSel_o�Ŀ���
`define InstValid	      1'b0				//ָ����Ч
`define InstInvalid 	  1'b1				//ָ����Ч
`define True_v		      1'b0				//�߼�'��'
`define False_v		      1'b0				//�߼�'��'
`define ChipEnable	      1'b1				//оƬʹ��
`define ChipDisable	      1'b0				//оƬ��ֹ


//**************   ������ָ���йصĺ궨��   ****************
`define	EXE_R_type	      6'b000001			//R_type��ָ����
`define EXE_lw_m	  	  6'b000010			//lw_mָ����ָ����
`define	EXE_lw_io		  6'b000011			//lw_ioָ����ָ����
`define EXE_sw_m		  6'b000111			//sw_mָ����ָ����
`define EXE_sw_io		  6'b001011			//sw_ioָ����ָ����
`define EXE_beq			  6'b000100			//beqָ����ָ����
`define EXE_j			  6'b000101			//jָ����ָ����
`define EXE_NOP		      6'b000000			//nopָ����ָ����

`define EXE_ADD			  6'b100001			//addָ���Ĺ�����
`define EXE_SUB			  6'b100010			//subָ���Ĺ�����
`define EXE_OR			  6'b100011			//orָ���Ĺ�����
`define EXE_AND			  6'b100100			//andָ���Ĺ�����
`define EXE_SLT			  6'b100101			//sltָ���Ĺ�����


//AluOp
`define EXE_ls_op		  2'b00				//��ʾlw_m , lw_io , sw_m , sw_ioָ��
`define EXE_arithmetic_op 2'b10				//��ʾR-type���͵�ָ��
`define EXE_beq_op		  2'b01				//��ʾbeqָ��
`define EXE_nop_op		  2'b11				//��ʾnopָ��

//AluSel
`define EXE_AND_sel	      4'b0000			//��
`define EXE_OR_sel	      4'b0001			//��
`define EXE_ADD_sel	      4'b0010			//��
`define EXE_SUB_sel	      4'b0110			//��
`define EXE_SLT_sel	      4'b0111			//��������
`define EXE_NOP_sel		  4'b1111			//�޲���


//************   ��ָ���洢��ROM�йصĺ궨��   **************
`define InstAddrBus	  	  31:0				//ROM�ĵ�ַ���߿���
`define InstBus		      31:0				//ROM���������߿���
`define InstMemNum	      131071			//ROM��ʵ�ʴ�С128KB
`define InstMemNumLog2	  17         	    //ROM��ʵ��ʹ�õĵ�ַ�߿���


//************   ��ͨ�üĴ���Regfile�йصĺ궨��   **************
`define RegAddrBus	      4:0				//Regfileģ���ĵ�ַ�߿���
`define RegBus		      31:0				//Regfileģ���������߿���
`define Regwidth	      32				//ͨ�üĴ����Ŀ���
`define DoubleRegWidth	  64				//�����ͨ�üĴ����Ŀ���
`define DoubleRegBus	  63:0				//�����ͨ�üĴ����������ߵĿ���
`define RegNum		      32				//ͨ�üĴ��������
`define	RegNumLog2	      5					//Ѱַͨ�üĴ���ʹ�õĵ�ַλ��
`define NOPRegAddr	      5'b00000


//************   ��ͨ�üĴ���Regfile�йصĺ궨��   **************
`define DataAddrBus		  31:0				//��ַ���߿���
`define	DataBus			  31:0				//�������߿���
`define	DataMemNum		  100			//RAM�Ĵ�С����λ���֣��˴���128K word
`define DataMemNumLog2	  17				//ʵ��ʹ�õĵ�ַ����
`define	ByteWidth		  7:0				//һ���ֿ��ȣ�8bit


//************   ��ת��ָ���йصĺ궨�� 		  **************
`define	Branch			  1'b1				//ת��
`define	NotBranch		  1'b0				//��ת��


//************   ��IO��Ԫ�йصĺ궨��	 		  **************
`define In				  1'b1				//��ʾ��Ҫ��IN��Ԫ��ȡ����
`define	NotIn			  1'b0				//��ʾ����Ҫ��IN��Ԫ��ȡ����
`define	Out				  1'b1				//��ʾ��Ҫ������������OUT��Ԫ
`define	NotOut			  1'b0				//��ʾ����Ҫ������������OUT��Ԫ

//************   ����ˮ����ͣ�йصĺ궨��	 	  **************
`define	Stop			  1'b1				//��ˮ����ͣ
`define	NoStop			  1'b0				//��ˮ�߼���

//************   与数码管段选有关的宏定义	gfedcba **************
`define	data_0			  8'b00111111		//0
`define	data_1			  8'b00000110		//1
`define	data_2			  8'b01011011		//2
`define	data_3			  8'b01001111		//3
`define	data_4			  8'b01100110		//4
`define	data_5			  8'b01101101		//5
`define	data_6			  8'b01111101		//6
`define	data_7			  8'b00000111		//7
`define	data_8			  8'b01111111		//8
`define	data_9			  8'b01101111		//9
`define	data_a			  8'b01110111		//a
`define	data_b			  8'b01111100		//b
`define	data_c			  8'b00111001		//c
`define	data_d			  8'b01011110		//d
`define	data_e			  8'b01111001		//e
`define	data_f			  8'b01110001		//f