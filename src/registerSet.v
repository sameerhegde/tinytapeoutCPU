module registerSet
	#(parameter dataWidth=32,//Data width in register is of 32 bit 
				addWidth=5)
	(input clk,reset,
	 input WrEn,
	 input [addWidth-1:0]readAdd1,readAdd2,writeAdd,
	 input [dataWidth-1:0]writeData,
	 output [dataWidth-1:0]data1,data2);

	reg [dataWidth-1:0]registers[0:(2**addWidth)-1];
	integer i; 
	always@(posedge clk)begin
		if(reset)begin //Reset all register to ZERO when rst is high 
			for(i=0;i<(2**addWidth);i=i+1)begin
				registers[i]<={dataWidth{1'b0}};
			end
		end
		else begin
			if(WrEn)begin //perform write operation when write enable is high 
				registers[writeAdd]<=writeData;
			end
			else begin
				registers[writeAdd]<=registers[writeAdd];
			end
		end
	end
	//reading from the register is not dependent on clock so that we can access the data dependent only on address 
	assign data1=registers[readAdd1];
	assign data2=registers[readAdd2];

endmodule