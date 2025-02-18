`include "def.svh"
`include "Adder.v"
`include "Buffer.v"
`include "Controller.v"
`include "Filter_spad.v"
`include "Ifmap_spad.v"
`include "Mul_hybrid.v"
`include "MUX.v"
`include "Psum_spad.v"

module PE (
	input clk,
	input rst,
	//Layer setting 
	input set_info,
	input [2:0] Ch_size,
	input [5:0] ifmap_column,
	input [5:0] ofmap_column,
	input [3:0] ifmap_Quant_size,
	input [3:0] filter_Quant_size,
	//data to PE.sv
	input filter_enable,
	input [7:0] filter,
	input ifmap_enable,
	input [31:0] ifmap,
	input ipsum_enable,
	input [`Psum_BITS-1:0] ipsum, 
	input opsum_ready,
	//data from PE.sv
	output reg  filter_ready,
	output reg  ifmap_ready,	
	output reg  ipsum_ready,
	output reg  [`Psum_BITS-1:0] opsum,
	output reg  opsum_enable
);  
wire	[3:0]	ifmap_Quant_size_store;
wire	[3:0]	filter_Quant_size_store;

wire	[3:0]	ifmap_spad_addr;
wire			ifmap_spad_wen;
wire			ifmap_spad_ren;
wire	[7:0]	ifmap_spad_rdata;
wire			shift;

wire	[3:0]	filter_spad_addr;
wire			filter_spad_wen;
wire			filter_spad_ren;
wire	[7:0]	filter_spad_rdata;

wire			psum_spad_wen;
wire			psum_spad_ren;
wire	[23:0]	psum_spad_rdata;
wire	[23:0]	psum_spad_wdata;

wire			buffer_wen;
wire			buffer_ren;
wire			buffer_sel;

wire	[23:0]	multiplier_output;

wire	[23:0]	mux_output;

wire	[23:0]	adder_output;

Ifmap_spad Ifmap_spad(
	.clk(clk),
	.rst(rst),
	.addr(ifmap_spad_addr),
	.wen(ifmap_spad_wen),
	.wdata(ifmap),
	.ren(ifmap_spad_ren),
	.shift(shift),
	.rdata(ifmap_spad_rdata)
);

Filter_spad Filter_spad(
	.clk(clk),
	.rst(rst),
	.addr(filter_spad_addr),
	.wen(filter_spad_wen),
	.wdata(filter),
	.ren(filter_spad_ren),
	.rdata(filter_spad_rdata)
);

Psum_spad Psum_spad(
	.clk(clk),
	.rst(rst),
	.wen(psum_spad_wen),
	.wdata(psum_spad_wdata),
	.ren(psum_spad_ren),
	.rdata(psum_spad_rdata)
);

Mul_hybrid Mul_hybrid(
	.ifmap(ifmap_spad_rdata),
	.filter(filter_spad_rdata),
	.ifmap_Quant_size(ifmap_Quant_size_store),
	.filter_Quant_size(filter_Quant_size_store),
	.product(multiplier_output)
);

MUX MUX(
	.input_data_0(multiplier_output),
	.input_data_1(ipsum),
	.sel(ipsum_enable),
	.output_data(mux_output)
);

Adder Adder(
	.input_data_0(mux_output),
	.input_data_1(psum_spad_rdata),
	.output_data(adder_output)
);

Buffer Buffer(
	.clk(clk),
	.rst(rst),
	.input_data(adder_output),
	.wen(buffer_wen),
	.ren(buffer_ren),
	.sel(buffer_sel),
	.output_data_0(psum_spad_wdata),
	.output_data_1(opsum)
);

Controller Controller(
	.clk(clk),
	.rst(rst),
	//Layer setting 
	.set_info(set_info),
	.Ch_size(Ch_size),
	.ifmap_column(ifmap_column),
	.ofmap_column(ofmap_column),
	.ifmap_Quant_size(ifmap_Quant_size),
	.filter_Quant_size(filter_Quant_size),
	.ifmap_Quant_size_store(ifmap_Quant_size_store),
	.filter_Quant_size_store(filter_Quant_size_store),
	//data to PE.sv
	.filter_enable(filter_enable),
	.ifmap_enable(ifmap_enable),
	.ipsum_enable(ipsum_enable),
	.opsum_ready(opsum_ready),
	//data from PE.sv
	.filter_ready(filter_ready),
	.ifmap_ready(ifmap_ready),
	.ipsum_ready(ipsum_ready),
	.opsum_enable(opsum_enable),

	.ifmap_spad_addr(ifmap_spad_addr),
	.ifmap_spad_wen(ifmap_spad_wen),
	.ifmap_spad_ren(ifmap_spad_ren),
	.shift(shift),

	.filter_spad_addr(filter_spad_addr),
	.filter_spad_wen(filter_spad_wen),
	.filter_spad_ren(filter_spad_ren),

	.psum_spad_wen(psum_spad_wen),
	.psum_spad_ren(psum_spad_ren),

	.buffer_wen(buffer_wen),
	.buffer_ren(buffer_ren),
	.buffer_sel(buffer_sel)
); 
endmodule