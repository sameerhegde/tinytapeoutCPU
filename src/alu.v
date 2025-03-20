module alu #(
	parameter DATAWIDTH = 32
	)(
	input [2:0]opcode,
	input [DATAWIDTH-1:0]data1,data2,
	output reg [DATAWIDTH-1:0]result);
	
	localparam 	ADD = 3'b000, //Localparam are added for easy changes if required for opcodes
				SUB = 3'b001,
				AND = 3'b010,
				OR = 3'b011,
				XOR = 3'b100;
	always@(*)begin
		//case statements so based on the opcode the operation is performed
		case(opcode) 
			ADD:result=data1+data2;
			SUB:result=data1-data2;
			AND:result=data1&data2;
			OR:result=data1|data2;
			XOR:result=data1^data2;
			default:result={DATAWIDTH{1'b0}};
		endcase
	end
endmodule
