module Signed_extension_mux (
	input	[7:0]		input_data0,
	input	[7:0]		input_data1,
	input	[7:0]		input_data2,
	input	[7:0]		input_data3,
	input	[7:0]		input_data4,
	input	[7:0]		input_data5,
	input	[7:0]		input_data6,
	input	[7:0]		ifmap,
	input	[7:0]		filter,
    input	[3:0]		filter_Quant_size,
	output  reg [23:0]	output_data0,
	output  reg [23:0]	output_data1,
	output  reg [23:0]	output_data2,
	output  reg [23:0]	output_data3,
	output  reg [23:0]	output_data4,
	output  reg [23:0]	output_data5,
	output  reg [23:0]	output_data6,
	output  reg [23:0]	output_data7
);
always @(*)
begin
	if(filter_Quant_size == 4'd8)
	begin
		output_data0 = {{16{input_data0[7]}}, input_data0[7:0]};
		output_data1 = {{16{input_data1[7]}}, input_data1[7:0]};
		output_data2 = {{16{input_data2[7]}}, input_data2[7:0]};
		output_data3 = {{16{input_data3[7]}}, input_data3[7:0]};
		output_data4 = {{16{input_data4[7]}}, input_data4[7:0]};
		output_data5 = {{16{input_data5[7]}}, input_data5[7:0]};
		output_data6 = {{16{input_data6[7]}}, input_data6[7:0]};
		if(filter[7] == 1'b1)	output_data7 = $signed(8'b1111_1111)*$signed(ifmap);
		else					output_data7 = 24'd0;
	end
	else if(filter_Quant_size == 4'd4)
	begin
		output_data0 = {{20{input_data0[3]}}, input_data0[3:0]};
		output_data1 = {{20{input_data1[3]}}, input_data1[3:0]};
		output_data2 = {{20{input_data2[3]}}, input_data2[3:0]};
		if(filter[3] == 1'b1)	output_data3 = $signed(4'b1111)*$signed(ifmap[3:0]);
		else					output_data3 = 24'd0;
		output_data4 = {{20{input_data4[3]}}, input_data4[3:0]};
		output_data5 = {{20{input_data5[3]}}, input_data5[3:0]};
		output_data6 = {{20{input_data6[3]}}, input_data6[3:0]};
		if(filter[7] == 1'b1)	output_data7 = $signed(4'b1111)*$signed(ifmap[3:0]);
		else					output_data7 = 24'd0;
	end
	else if(filter_Quant_size == 4'd2)
	begin
		output_data0 = {{22{input_data0[1]}}, input_data0[1:0]};
		if(filter[1] == 1'b1)	output_data1 = $signed(2'b11)*$signed(ifmap[1:0]);
		else					output_data1 = 24'd0;
		output_data2 = {{22{input_data0[5]}}, input_data0[5:4]};
		if(filter[1] == 1'b1)	output_data3 = $signed(2'b11)*$signed(ifmap[5:4]);
		else					output_data3 = 24'd0;
		output_data4 = {{22{input_data4[1]}}, input_data4[1:0]};
		if(filter[5] == 1'b1)	output_data5 = $signed(2'b11)*$signed(ifmap[1:0]);
		else					output_data5 = 24'd0;
		output_data6 = {{22{input_data4[5]}}, input_data4[5:4]};
		if(filter[5] == 1'b1)	output_data7 = $signed(2'b11)*$signed(ifmap[5:4]);
		else					output_data7 = 24'd0;
	end
	else
	begin
		output_data0 = 24'd0;
		output_data1 = 24'd0;
		output_data2 = 24'd0;
		output_data3 = 24'd0;
		output_data4 = 24'd0;
		output_data5 = 24'd0;
		output_data6 = 24'd0;
		output_data7 = 24'd0;
	end
end
endmodule