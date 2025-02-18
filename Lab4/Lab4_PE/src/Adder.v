module Adder(
	input	[23:0]			input_data_0,
	input	[23:0]			input_data_1,
	output	reg	[23:0]		output_data
);
reg		[23:0]	product;
always @ (*)
begin
	product = input_data_0 + input_data_1;
	if((input_data_0[23]==1'b1)&&(input_data_1[23]==1'b1)&&(product[23]==1'b0))			output_data = 24'b1000_0000_0000_0000_0000_0000;
	else if((input_data_0[23]==1'b0)&&(input_data_1[23]==1'b0)&&(product[23]==1'b1))	output_data = 24'b0111_1111_1111_1111_1111_1111;
	else	output_data = product;
end
endmodule