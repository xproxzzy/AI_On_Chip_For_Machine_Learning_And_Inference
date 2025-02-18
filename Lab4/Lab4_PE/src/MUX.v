module MUX(
	input	[23:0]			input_data_0,
	input	[23:0]			input_data_1,
	input					sel,
	output	reg	[23:0]		output_data
);
always @ (*)
begin
	if(sel == 1'b0)	output_data = input_data_0;
	else			output_data = input_data_1;
end
endmodule