module Shifter1 (
	input	[23:0]		input_data, 
	output	reg	[23:0]	output_data
);
always @ (*)
begin
	output_data = input_data << 1;
end
endmodule