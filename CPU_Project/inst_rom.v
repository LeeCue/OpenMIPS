`include "defines.v"
module inst_rom(
	input	wire				ce,
	input	wire[`InstAddrBus]	addr,	
	output	reg[`InstBus]		inst
);

	//reg[`InstBus]	inst_mem[0:`InstMemNum-1];
	reg[`InstBus]	inst_mem[0:50];
	reg[4:0] n;
	
	/*initial	begin
		$readmemh("inst_rom.txt",inst_mem);
		//for(n=0;n<=5;n=n+1)
		//$display("%b",inst_mem[n]);
	end*/
	
	initial begin 
		inst_mem[0] = 32'h04222821;
		inst_mem[1] = 32'h04A33822;
		inst_mem[2] = 32'h04434025;
		inst_mem[3] = 32'h04224824;
		inst_mem[4] = 32'h04445023;
		inst_mem[5] = 32'h0C2B0001;
		inst_mem[6] = 32'h10220004;
		inst_mem[7] = 32'h00000000;
		inst_mem[8] = 32'h00000000;
		inst_mem[9] = 32'h00000000;
		inst_mem[10] = 32'h00000000;
		inst_mem[11] = 32'h2C270001;
		inst_mem[12] = 32'h05676021;
		inst_mem[13] = 32'h00000000;
		inst_mem[14] = 32'h1C410001;
		inst_mem[15] = 32'h14000014;
		inst_mem[16] = 32'h2C2C0001;
		inst_mem[17] = 32'h00000000;
		inst_mem[18] = 32'h00000000;
		inst_mem[19] = 32'h00000000;
		inst_mem[20] = 32'h2C2B0001;
		inst_mem[21] = 32'h14000000;
	end
	
	always@ (*) begin
		if(ce == `ChipDisable) begin
			inst <= `ZeroWord;
		end else begin
			inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
		end
	end
	
	
	
endmodule