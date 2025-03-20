module controlUnit #(
parameter	DATAWIDTH = 32,
		REGADD = 5,
		IMM_DATA_WIDTH = 20
	)(
	input clk,reset,
	input [DATAWIDTH-1:0]instruction,
	output reg regWrEn, //enabling the register write 
	output reg [REGADD-1:0]readAdd1,readAdd2,writeAdd, //address for registers 
	output reg [IMM_DATA_WIDTH-1:0]immData, // immidate data to writ einto register for LOAD 
	output reg isLoad, //for load operation in top module 
	output reg [2:0]opcodeAlu); //opcode for alu to perform operation 

	//wires taken to make it easy to note and instruction are decoded in this 
	wire [6:0]FUNC7 = instruction[31:25];
	wire [4:0]RS2 = instruction[24:20];
	wire [4:0]RS1 = instruction[19:15];
	wire [2:0]FUNC3 = instruction[14:12];
	wire [4:0]RD = instruction[11:7];
	wire [6:0]OPCODE = instruction[6:0];

	localparam 	EN = 1'b1,
				ENn = 1'b0,
				ADD = 3'b000,
				SUB = 3'b001,
				AND = 3'b010,
				OR = 3'b011,
				XOR = 3'b100;

	always@(posedge clk)begin
		if(reset)begin
			isLoad<=ENn;
			regWrEn<=ENn;
			opcodeAlu<=3'b111; //make alu goto default when reset 
			readAdd1<={REGADD{1'b0}};
			readAdd2<={REGADD{1'b0}};
			writeAdd<={REGADD{1'b0}};
			immData<={IMM_DATA_WIDTH{1'b0}};
		end
		else begin
			case(OPCODE)
				//ALU operation opcode for alu operation '0110011 
				7'b0110011:	begin
								isLoad<=ENn;
								readAdd1<=RS1;
								readAdd2<=RS2;
								regWrEn<=EN;
								writeAdd<=RD;
								immData<={IMM_DATA_WIDTH{1'b0}};
								
								case({FUNC7,FUNC3}) //check the functions and send opcode to alu to perform required operation
									10'b0000000_000:begin
													opcodeAlu<=ADD;
												end
									10'b0100000_000:begin
													opcodeAlu<=SUB;
												end
									10'b0000000_110:begin
													opcodeAlu<=AND;
												end
									10'b0000000_111:begin
													opcodeAlu<=OR;
													end
									10'b0000000_100:begin
													opcodeAlu<=XOR;
												end
									default:begin
												opcodeAlu<=3'b111;
											end
								endcase
							end
							
				//load operation {FUNC7,RS1,RS2,FUNC3} ---> immidate value to store RD --> destination register 
				7'b0010011: begin
								isLoad<=EN;
								regWrEn<=EN;
								opcodeAlu<=ADD;
								readAdd1<={REGADD{1'b0}};
								readAdd2<={REGADD{1'b0}};
								writeAdd<=RD;
								immData<={FUNC7,RS2,RS1,FUNC3};
							end
				default:	begin
								isLoad<=ENn;
								regWrEn<=ENn;
								opcodeAlu<=3'b111; //make alu goto default when reset 
								readAdd1<={REGADD{1'b0}};
								readAdd2<={REGADD{1'b0}};
								writeAdd<={REGADD{1'b0}};
								immData<={IMM_DATA_WIDTH{1'b0}};
							end
			endcase
		end
	end
endmodule
