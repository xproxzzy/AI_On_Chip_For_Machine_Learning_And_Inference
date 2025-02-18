module Multiplier_8_1 (
	input [7:0] input_a,
	input input_b,
	output reg [7:0] product
);
always @ (*)
begin
	if (input_b == 1'b1)
	begin
		product = input_a;
	end
	else
	begin
		product = 8'b0;
	end
end
endmodule