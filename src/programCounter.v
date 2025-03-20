module programCounter #(
	parameter WIDTH = 7
	)(
	input clk,rst,
	input [6:0]opcodeIn,
	output reg [WIDTH-1:0]pointer);

	always@(posedge clk)begin
		if(rst)begin
			pointer<={WIDTH{1'b0}};
		end
		//HALT istruction is added (Flow control) so when HALT occurs the PC will not update
		else if(opcodeIn==7'b0000001)begin 
			pointer<=pointer;
		end
		else begin
			pointer<=pointer+'d4;
		end
	end
endmodule
