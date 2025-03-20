module flipFlop #(
	parameter WIDTH = 32
	)(
	input clk,rst,
	input [WIDTH-1:0]dataIn,
	output reg [WIDTH-1:0]dataOut);

	always@(posedge clk)begin
		if(rst)begin
			dataOut<={WIDTH{1'b0}};
		end
		else begin
			dataOut<=dataIn;
		end
	end
endmodule
