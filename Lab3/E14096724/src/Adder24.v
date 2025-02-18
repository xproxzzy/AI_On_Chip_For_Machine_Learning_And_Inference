module Adder24 (
	input	[23:0]		input_a,
    input	[23:0]		input_b,
	output	reg	[23:0]	sum
);
always @ (*)
begin
	sum = input_a + input_b;
end
endmodule