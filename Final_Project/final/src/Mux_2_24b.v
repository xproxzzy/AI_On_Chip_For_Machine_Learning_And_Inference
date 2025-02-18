module Mux_2_24b(
	input				clk,
	input				rst,
	input				sel,
	input		[23:0]	pe_output,
	input		[23:0]	buffer_output,
	output	reg	[23:0]	output_data
);
reg	[23:0]	Register;
always@(posedge clk or posedge rst)
begin
	if(rst)
	begin
		Register <= 24'd0;
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