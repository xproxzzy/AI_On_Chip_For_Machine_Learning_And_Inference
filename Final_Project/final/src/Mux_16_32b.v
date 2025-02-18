module Mux_16_32b(
	input		[3:0]	sel,
	input		[31:0]	input_data_0,
	input		[31:0]	input_data_1,
	input		[31:0]	input_data_2,
	input		[31:0]	input_data_3,
	input		[31:0]	input_data_4,
	input		[31:0]	input_data_5,
	input		[31:0]	input_data_6,
	input		[31:0]	input_data_7,
	input		[31:0]	input_data_8,
	input		[31:0]	input_data_9,
	input		[31:0]	input_data_10,
	input		[31:0]	input_data_11,
	input		[31:0]	input_data_12,
	input		[31:0]	input_data_13,
	input		[31:0]	input_data_14,
	input		[31:0]	input_data_15,
	output	reg	[31:0]	output_data
);
always @(*)
begin
	case(sel)
		4'b0000:output_data = input_data_0;
		4'b0001:output_data = input_data_1;
		4'b0010:output_data = input_data_2;
		4'b0011:output_data = input_data_3;
		4'b0100:output_data = input_data_4;
		4'b0101:output_data = input_data_5;
		4'b0110:output_data = input_data_6;
		4'b0111:output_data = input_data_7;
		4'b1000:output_data = input_data_8;
		4'b1001:output_data = input_data_9;
		4'b1010:output_data = input_data_10;
		4'b1011:output_data = input_data_11;
		4'b1100:output_data = input_data_12;
		4'b1101:output_data = input_data_13;
		4'b1110:output_data = input_data_14;
		4'b1111:output_data = input_data_15;
		default:output_data = 32'd0;
	endcase
end
endmodule