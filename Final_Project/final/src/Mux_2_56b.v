module Mux_2_56b(
	input				clk,
	input				rst,
	input				sel,
	input		[55:0]	pe_output,
	input		[55:0]	buffer_output,
	output	reg	[55:0]	output_data
);
reg	[55:0]	Register;
always@(posedge clk or posedge rst)
begin
	if(rst)
	begin
		Register <= 56'd0;
	end
	else
	begin
		Register <= pe_output;
	end
end
always @(*)
begin
	if(sel)
	begin
		output_data = Register;
	end
	else
	begin
		output_data = buffer_output;
	end
end
endmodule