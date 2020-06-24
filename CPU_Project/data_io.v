`include "defines.v"
module data_io(
	//来自实验箱的输入
	input	wire	clk,
	input	wire	rst,
	input	wire	k1_ten,
	input	wire	k2_ge,
	
	//来自sopc的输入
	input	wire[`InstAddrBus]	pc_in,
	input	wire[`RegBus]		res,
	input	wire				out_i,		
	
	//输出给程序的数据
	output	reg[`RegBus]	data_o,

	//输出给实验箱的信息
	output	reg[2:0]	sel,
	output	reg[7:0]	seg
);
	parameter	T1KHZ = 2_499;
	parameter	T1HZ = 24_999_999;
	integer     cnt1;
	integer		cnt2;

	reg		clk_10k;
	reg		clk_1;

	reg[`RegBus]	result;
	
	reg[3:0]		shiwei;
	reg[3:0]		gewei;
	
	wire[3:0]	pc_2;
	wire[3:0]	pc_1;
	
	wire[3:0]	res_2;
	wire[3:0]	res_1;
	
	assign	pc_2 = pc_in[3:0];
	assign	pc_1 = pc_in[7:4];
	
	assign	res_2 = result[3:0];
	assign	res_1 = result[7:4];
	
	initial begin 
		sel = 3'b000;
	end
	
	always@ (posedge clk) begin 
		if(rst == `RstEnable) begin 
			cnt1	<= 0;
			clk_10k <= 0;
			cnt2	<= 0;
			clk_1	<= 0;
		end
		if(cnt1 == T1KHZ) begin 
			clk_10k <= ~clk_10k;
			cnt1 <= 0;
		end else begin 
			cnt1 <= cnt1 + 1;
		end
		if(cnt2 == T1HZ) begin 
			clk_1 <= ~clk_1;
			cnt2	<= 0;
		end else begin 
			cnt2 <= cnt2 + 1;
		end
	end
	
	always@ (posedge clk_1) begin 
		if(rst == `RstEnable) begin 
			shiwei <= 4'b0000;
			gewei <= 4'b0000;
		end
		if(k1_ten == 1'b0) begin 
			if(shiwei == 4'b1111) begin 
				shiwei <= 4'b0000;
			end else begin 
				shiwei <= shiwei + 1;
			end
		end
		if(k2_ge == 1'b0) begin 
			if(gewei == 4'b1111) begin 
				gewei <= 4'b0000;
			end else begin 
				gewei <= gewei + 1;
			end
		end
	end
	
	always@ (posedge clk_10k) begin
		if(sel == 3'b111) begin 
			sel <= 3'b000;
		end else begin 
			sel <= sel + 1;
		end
	end
	
	always@ (*) begin	
		if(rst == `RstEnable) begin 
			seg <= `data_0;
			result <= `ZeroWord;
			data_o <= `ZeroWord;
			//shiwei <= 4'b0000;
			//gewei <= 4'b0000;
		end else begin 
			if(out_i == `WriteEnable) begin 
				result <= res; 
			end
			data_o <= {26'd0,shiwei[3:0],gewei[3:0]};
			if(sel == 3'b000) begin 
				case(pc_1) 
					4'd0: begin 
						seg = `data_0;
					end
					4'd1: begin 
						seg = `data_1;
					end
					4'd2: begin 
						seg = `data_2;
					end
					4'd3: begin 
						seg = `data_3;
					end
					4'd4: begin 
						seg = `data_4;
					end
					4'd5: begin 
						seg = `data_5;
					end
					4'd6: begin 
						seg = `data_6;
					end
					4'd7: begin 
						seg = `data_7;
					end
					4'd8: begin 
						seg = `data_8;
					end
					4'd9: begin 
						seg = `data_9;
					end
					4'd10: begin 
						seg = `data_a;
					end
					4'd11: begin 
						seg = `data_b;
					end
					4'd12: begin 
						seg = `data_c;
					end
					4'd13: begin 
						seg = `data_d;
					end
					4'd14: begin 
						seg = `data_e;
					end
					4'd15: begin 
						seg = `data_f;
					end
				endcase
			end
			else if(sel == 3'b001) begin			
				case(pc_2) 
					4'd0: begin 
						seg = `data_0;
					end
					4'd1: begin 
						seg = `data_1;
					end
					4'd2: begin 
						seg = `data_2;
					end
					4'd3: begin 
						seg = `data_3;
					end
					4'd4: begin 
						seg = `data_4;
					end
					4'd5: begin 
						seg = `data_5;
					end
					4'd6: begin 
						seg = `data_6;
					end
					4'd7: begin 
						seg = `data_7;
					end
					4'd8: begin 
						seg = `data_8;
					end
					4'd9: begin 
						seg = `data_9;
					end
					4'd10: begin 
						seg = `data_a;
					end
					4'd11: begin 
						seg = `data_b;
					end
					4'd12: begin 
						seg = `data_c;
					end
					4'd13: begin 
						seg = `data_d;
					end
					4'd14: begin 
						seg = `data_e;
					end
					4'd15: begin 
						seg = `data_f;
					end
				endcase
			end
			else if(sel == 3'b110) begin 
				case(res_1) 
					4'd0: begin 
						seg = `data_0;
					end
					4'd1: begin 
						seg = `data_1;
					end
					4'd2: begin 
						seg = `data_2;
					end
					4'd3: begin 
						seg = `data_3;
					end
					4'd4: begin 
						seg = `data_4;
					end
					4'd5: begin 
						seg = `data_5;
					end
					4'd6: begin 
						seg = `data_6;
					end
					4'd7: begin 
						seg = `data_7;
					end
					4'd8: begin 
						seg = `data_8;
					end
					4'd9: begin 
						seg = `data_9;
					end
					4'd10: begin 
						seg = `data_a;
					end
					4'd11: begin 
						seg = `data_b;
					end
					4'd12: begin 
						seg = `data_c;
					end
					4'd13: begin 
						seg = `data_d;
					end
					4'd14: begin 
						seg = `data_e;
					end
					4'd15: begin 
						seg = `data_f;
					end
				endcase
			end
			else if(sel == 3'b111) begin 
				case(res_2) 
					4'd0: begin 
						seg = `data_0;
					end
					4'd1: begin 
						seg = `data_1;
					end
					4'd2: begin 
						seg = `data_2;
					end
					4'd3: begin 
						seg = `data_3;
					end
					4'd4: begin 
						seg = `data_4;
					end
					4'd5: begin 
						seg = `data_5;
					end
					4'd6: begin 
						seg = `data_6;
					end
					4'd7: begin 
						seg = `data_7;
					end
					4'd8: begin 
						seg = `data_8;
					end
					4'd9: begin 
						seg = `data_9;
					end
					4'd10: begin 
						seg = `data_a;
					end
					4'd11: begin 
						seg = `data_b;
					end
					4'd12: begin 
						seg = `data_c;
					end
					4'd13: begin 
						seg = `data_d;
					end
					4'd14: begin 
						seg = `data_e;
					end
					4'd15: begin 
						seg = `data_f;
					end
				endcase
			end
			else if(sel == 3'b100) begin 
				case(shiwei) 
					4'd0: begin 
						seg = `data_0;
					end
					4'd1: begin 
						seg = `data_1;
					end
					4'd2: begin 
						seg = `data_2;
					end
					4'd3: begin 
						seg = `data_3;
					end
					4'd4: begin 
						seg = `data_4;
					end
					4'd5: begin 
						seg = `data_5;
					end
					4'd6: begin 
						seg = `data_6;
					end
					4'd7: begin 
						seg = `data_7;
					end
					4'd8: begin 
						seg = `data_8;
					end
					4'd9: begin 
						seg = `data_9;
					end
					4'd10: begin 
						seg = `data_a;
					end
					4'd11: begin 
						seg = `data_b;
					end
					4'd12: begin 
						seg = `data_c;
					end
					4'd13: begin 
						seg = `data_d;
					end
					4'd14: begin 
						seg = `data_e;
					end
					4'd15: begin 
						seg = `data_f;
					end
				endcase
			end
			else if(sel == 3'b101) begin 
				case(gewei) 
					4'd0: begin 
						seg = `data_0;
					end
					4'd1: begin 
						seg = `data_1;
					end
					4'd2: begin 
						seg = `data_2;
					end
					4'd3: begin 
						seg = `data_3;
					end
					4'd4: begin 
						seg = `data_4;
					end
					4'd5: begin 
						seg = `data_5;
					end
					4'd6: begin 
						seg = `data_6;
					end
					4'd7: begin 
						seg = `data_7;
					end
					4'd8: begin 
						seg = `data_8;
					end
					4'd9: begin 
						seg = `data_9;
					end
					4'd10: begin 
						seg = `data_a;
					end
					4'd11: begin 
						seg = `data_b;
					end
					4'd12: begin 
						seg = `data_c;
					end
					4'd13: begin 
						seg = `data_d;
					end
					4'd14: begin 
						seg = `data_e;
					end
					4'd15: begin 
						seg = `data_f;
					end
				endcase
			end
			else begin 
				seg = `data_0;
			end
		end
	end 
	
endmodule