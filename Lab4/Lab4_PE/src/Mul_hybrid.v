`include "../include/def.svh"
`include "Multiplier_8_1.v"
`include "Signed_extension_mux.v"
`include "Shifter1.v"
`include "Shifter2.v"
`include "Shifter4.v"
`include "Adder24.v"
module Mul_hybrid (
	input	[7:0]	ifmap,			//input feature map
	input	[7:0]	filter, 		//filter
	input	[3:0]	ifmap_Quant_size,
	input	[3:0]	filter_Quant_size,
	output	reg		[`Psum_BITS-1:0]	product
);
wire [7:0] mul_output [6:0];
wire [`Psum_BITS-1:0] extension_output [7:0];
wire [`Psum_BITS-1:0] shifter_output0 [7:0];
wire [`Psum_BITS-1:0] adder_output0 [3:0];
wire [`Psum_BITS-1:0] shifter_output1 [3:0];
wire [`Psum_BITS-1:0] adder_output1 [1:0];
wire [`Psum_BITS-1:0] shifter_output2 [1:0];
wire [`Psum_BITS-1:0] adder_output2;

Multiplier_8_1 Multiplier_8_1_0(.input_a(ifmap), .input_b(filter[0]), .product(mul_output[0]));
Multiplier_8_1 Multiplier_8_1_1(.input_a(ifmap), .input_b(filter[1]), .product(mul_output[1]));
Multiplier_8_1 Multiplier_8_1_2(.input_a(ifmap), .input_b(filter[2]), .product(mul_output[2]));
Multiplier_8_1 Multiplier_8_1_3(.input_a(ifmap), .input_b(filter[3]), .product(mul_output[3]));
Multiplier_8_1 Multiplier_8_1_4(.input_a(ifmap), .input_b(filter[4]), .product(mul_output[4]));
Multiplier_8_1 Multiplier_8_1_5(.input_a(ifmap), .input_b(filter[5]), .product(mul_output[5]));
Multiplier_8_1 Multiplier_8_1_6(.input_a(ifmap), .input_b(filter[6]), .product(mul_output[6]));

Signed_extension_mux Signed_extension_mux(
	.input_data0(mul_output[0]), 
	.input_data1(mul_output[1]), 
	.input_data2(mul_output[2]), 
	.input_data3(mul_output[3]), 
	.input_data4(mul_output[4]), 
	.input_data5(mul_output[5]), 
	.input_data6(mul_output[6]), 
	.ifmap(ifmap), 
	.filter(filter), 
	.filter_Quant_size(filter_Quant_size), 
	.output_data0(extension_output[0]), 
	.output_data1(extension_output[1]), 
	.output_data2(extension_output[2]), 
	.output_data3(extension_output[3]), 
	.output_data4(extension_output[4]), 
	.output_data5(extension_output[5]), 
	.output_data6(extension_output[6]), 
	.output_data7(extension_output[7])
);

assign shifter_output0[0] = extension_output[0];
assign shifter_output0[2] = extension_output[2];
assign shifter_output0[4] = extension_output[4];
assign shifter_output0[6] = extension_output[6];
Shifter1 Shifter1_0(.input_data(extension_output[1]), .output_data(shifter_output0[1]));
Shifter1 Shifter1_1(.input_data(extension_output[3]), .output_data(shifter_output0[3]));
Shifter1 Shifter1_2(.input_data(extension_output[5]), .output_data(shifter_output0[5]));
Shifter1 Shifter1_3(.input_data(extension_output[7]), .output_data(shifter_output0[7]));

Adder24 Adder24_0_0(.input_a(shifter_output0[0]), .input_b(shifter_output0[1]), .sum(adder_output0[0]));
Adder24 Adder24_0_1(.input_a(shifter_output0[2]), .input_b(shifter_output0[3]), .sum(adder_output0[1]));
Adder24 Adder24_0_2(.input_a(shifter_output0[4]), .input_b(shifter_output0[5]), .sum(adder_output0[2]));
Adder24 Adder24_0_3(.input_a(shifter_output0[6]), .input_b(shifter_output0[7]), .sum(adder_output0[3]));

assign shifter_output1[0] = adder_output0[0];
assign shifter_output1[2] = adder_output0[2];
Shifter2 Shifter2_0(.input_data(adder_output0[1]), .output_data(shifter_output1[1]));
Shifter2 Shifter2_1(.input_data(adder_output0[3]), .output_data(shifter_output1[3]));

Adder24 Adder24_1_0(.input_a(shifter_output1[0]), .input_b(shifter_output1[1]), .sum(adder_output1[0]));
Adder24 Adder24_1_1(.input_a(shifter_output1[2]), .input_b(shifter_output1[3]), .sum(adder_output1[1]));

assign shifter_output2[0] = adder_output1[0];
Shifter4 Shifter4_0(.input_data(adder_output1[1]), .output_data(shifter_output2[1]));

Adder24 Adder24_2_0(.input_a(shifter_output2[0]), .input_b(shifter_output2[1]), .sum(adder_output2));

always @(*)
begin
	if(ifmap_Quant_size == 4'd8)
	begin
		product = adder_output2;
	end
	else if(ifmap_Quant_size == 4'd4)
	begin
		product = {adder_output1[1][11:0], adder_output1[0][11:0]};
	end
	else if(ifmap_Quant_size == 4'd2)
	begin
		product = {adder_output0[3][5:0], adder_output0[2][5:0], adder_output0[1][5:0], adder_output0[0][5:0]};
	end
	else
	begin
		product = 24'd0;
	end
end
endmodule