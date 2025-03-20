//`include "programMemory.v"
//`include "programCounter.v"
//`include "alu.v"
//`include "controlUnit.v"
//`include "registerSet.v"
//`include "flipFlop.v"




module top_cpu #(
	parameter 	DATAWIDTH = 32,
				ADDWIDTH=7,
				REGADD=5,
				IMM_DATA_WIDTH=20
	)(
	input clk,rst,
	input pmWrEn,//write enable signal for program memory 
	input [7:0]instructionIn,
	input [ADDWIDTH-1:0]pmAddr,
	output [DATAWIDTH-1:0]aluresult);
	
	wire [DATAWIDTH-1:0]instruction;
	wire [ADDWIDTH-1:0]pointer;
	wire regWrEn,regWrEn_ff3;
	wire [REGADD-1:0]readAdd1,readAdd2,writeAdd,writeAdd_ff2;
	wire [IMM_DATA_WIDTH-1:0]immData;
	wire isLoad;
	wire [2:0]opcodeAlu;
	wire [DATAWIDTH-1:0]data1,data2;
	wire [DATAWIDTH-1:0]muxOut;
	wire [DATAWIDTH-1:0]aluresult_ff1;
	
	programMemory
	#( 	.DATAWIDTH(8),
		.ADDWIDTH(ADDWIDTH)
	)pm(.clk(clk),
	 .wrEn(pmWrEn),
	 .readAdd(pointer),
	 .writeAdd(pmAddr),
	 .writeData(instructionIn),
	 .instruction(instruction));
	 
	 programCounter #(
	.WIDTH(ADDWIDTH)
	)pc(
	.clk(clk),
	.rst(rst),
	.opcodeIn(instruction[6:0]),
	.pointer(pointer));
	
	controlUnit #(
	.DATAWIDTH(DATAWIDTH),
	.REGADD(REGADD),
	.IMM_DATA_WIDTH(IMM_DATA_WIDTH)
	)cu(
	.clk(clk),
	.reset(rst),
	.instruction(instruction),
	.regWrEn(regWrEn),
	.readAdd1(readAdd1),
	.readAdd2(readAdd2),
	.writeAdd(writeAdd), 
	.immData(immData), // immidate data to writ einto register for LOAD 
	.isLoad(isLoad), //for load operation in top module 
	.opcodeAlu(opcodeAlu)); //opcode for alu to perform operation 
	
	registerSet
	#(	.dataWidth(DATAWIDTH),
		.addWidth(REGADD)
	)rs(
	.clk(clk),
	.reset(rst),
	.WrEn(regWrEn_ff3),
	.readAdd1(readAdd1),
	.readAdd2(readAdd2),
	.writeAdd(writeAdd_ff2),
	.writeData(aluresult_ff1),
	.data1(data1),
	.data2(data2));
	
	 alu #(
	.DATAWIDTH(DATAWIDTH)
	)alUnit(
	.opcode(opcodeAlu),
	.data1(muxOut),
	.data2(data2),
	.result(aluresult));
	
	//FlipFlop for storing the alu reslut before passing it to register set for write back
	flipFlop #(
	.WIDTH(DATAWIDTH)
	)ff1(
	.clk(clk),
	.rst(rst),
	.dataIn(aluresult),
	.dataOut(aluresult_ff1));

	/*FlipFlop for dealying the write address to the register set from control unit,
	so that the data from alu and the address from control unit will reach register set at same cycle */
	flipFlop #(
	.WIDTH(REGADD)
	)ff2(
	.clk(clk),
	.rst(rst),
	.dataIn(writeAdd),
	.dataOut(writeAdd_ff2));

	//store write enable from control unit before passing it to the register set
	flipFlop #(
	.WIDTH(1)
	)ff3(
	.clk(clk),
	.rst(rst),
	.dataIn(regWrEn),
	.dataOut(regWrEn_ff3));
	
	assign muxOut = isLoad?{{(DATAWIDTH-IMM_DATA_WIDTH){1'b0}},immData}:data1;

endmodule
