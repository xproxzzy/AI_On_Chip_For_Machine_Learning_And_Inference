module Buffer(
	input				clk,
	input				rst,
	input	[23:0]		input_data,
	input				wen,
	input				ren,
	input				sel,
	output	reg	[23:0]	output_data_0,
	output	reg	[23:0]	output_data_1
);
reg	[23:0] Register;
always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
		Register <= 24'd0;
	end
	else
	begin
		if(wen)
		begin
			Register <= input_data;
		end
	end
end
always @ (*)
begin
	if(ren)
	begin
		if(sel == 1'b0)
		begin
			output_data_0 = Register;
			output_data_1 = 24'd0;
		end
		else
		begin
			output_data_0 = 24'd0;
			output_data_1 = Register;
		end
	end
	else
	begin
		output_data_0 = 24'd0;
		output_data_1 = 24'd0;
	end
end
endmodule