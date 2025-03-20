module programMemory
	#(parameter DATAWIDTH=8,
				ADDWIDTH=7)
	(input clk,
	 input wrEn,
	 input [ADDWIDTH-1:0]readAdd,writeAdd,
	 input [DATAWIDTH-1:0]writeData,
	 output [31:0]instruction);

	reg [DATAWIDTH-1:0]memo[0:(2**ADDWIDTH)-1]; //2**7 = 128 DEPTH of program memory with 32 bit width 

	always@(posedge clk)begin
		if(wrEn)begin //perform writ eoperation when writ enable is high 
			memo[writeAdd]<=writeData;
		end
		else begin
			memo[writeAdd]<=memo[writeAdd];
		end
	end
    assign instruction={memo[readAdd+'d3],memo[readAdd+'d2],memo[readAdd+'d1],memo[readAdd]}; // give the output to control unit from the address which is pointed by program counter
	
endmodule