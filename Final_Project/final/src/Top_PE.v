`include "PE_array.v"
`include "Accumulator.v"
`include "Controller.v"
`include "Mux_16_32b.v"
`include "post_unit.sv"

module Top_PE(
	input 				clk,
	input 				rst,
	input				start,
	input		[9:0]	confi,
	input		[23:0]	ifmap_data,
	input		[23:0]	weight_data,
	input		[3:0]	index_data,
	output				ifmap_sram_ren,
	output				weight_sram_ren,
	output				index_sram_ren,
	output		[16:0]	ifmap_sram_addr,
	output		[16:0]	weight_sram_addr,
	output		[16:0]	index_sram_addr,
	output				update, 
	output              post_unit_wen,
	output		[31:0]	data_out,
	output      [21:0]  address,
	output              total_done
);
wire	[55:0]	ifmap_1, ifmap_2, ifmap_3, ifmap_4;
wire	[23:0]	filter_1, filter_2, filter_3, filter_4;
wire	[3:0]	index_1, index_2, index_3, index_4;
wire	[17:0]	psum_1, psum_2, psum_3, psum_4, 
				psum_5, psum_6, psum_7, psum_8, 
				psum_9, psum_10, psum_11, psum_12, 
				psum_13, psum_14, psum_15, psum_16;
wire	[31:0]	result_1, result_2, result_3, result_4, 
				result_5, result_6, result_7, result_8, 
				result_9, result_10, result_11, result_12, 
				result_13, result_14, result_15, result_16;
wire 			fully_connect;

wire    [7:0]   ifmap_buffer_waddr;
wire    [6:0]   filter_buffer_waddr,index_buffer_waddr;
wire            ifmap_buffer_wen,filter_buffer_wen,index_buffer_wen;
wire	[7:0]	ifmap_raddr_1, ifmap_raddr_2, ifmap_raddr_3, ifmap_raddr_4,
				ifmap_raddr_5, ifmap_raddr_6, ifmap_raddr_7, ifmap_raddr_8,
				ifmap_raddr_9, ifmap_raddr_10, ifmap_raddr_11, ifmap_raddr_12,
				ifmap_raddr_13, ifmap_raddr_14, ifmap_raddr_15, ifmap_raddr_16;
wire            ifmap_ren_1, ifmap_ren_2, ifmap_ren_3, ifmap_ren_4,
				ifmap_ren_5, ifmap_ren_6, ifmap_ren_7, ifmap_ren_8,
				ifmap_ren_9, ifmap_ren_10, ifmap_ren_11, ifmap_ren_12,
				ifmap_ren_13, ifmap_ren_14, ifmap_ren_15, ifmap_ren_16,
				ifmap_sel_1_1, ifmap_sel_1_2, ifmap_sel_1_3,
				ifmap_sel_2_1, ifmap_sel_2_2, ifmap_sel_2_3,
				ifmap_sel_3_1, ifmap_sel_3_2, ifmap_sel_3_3,
				ifmap_sel_4_1, ifmap_sel_4_2, ifmap_sel_4_3;
wire    [6:0]   filter_raddr_1, filter_raddr_2, filter_raddr_3, filter_raddr_4,
				filter_raddr_5, filter_raddr_6, filter_raddr_7, filter_raddr_8,
				filter_raddr_9, filter_raddr_10, filter_raddr_11, filter_raddr_12,
				filter_raddr_13, filter_raddr_14, filter_raddr_15, filter_raddr_16;
wire    [6:0]	index_raddr_1, index_raddr_2, index_raddr_3, index_raddr_4;
wire    [31:0]  result;

wire            post_unit_wen;
wire    [5:0]        W;
wire    [9:0]        Co;
wire    [3:0]  result_sel;


post_unit post_unit (.clk(clk),.rst(rst),.alu_type(fully_connect),.data_in(result),.enable(post_unit_wen),
					.data_out(data_out),.address(address),.col_size(W),.channel_size(Co),.total_done(total_done));
PE_array PE_array(
	.clk(clk), 
	.rst(rst), 
	.fully_connect(fully_connect), 
	.ifmap_waddr(ifmap_buffer_waddr),
    .ifmap_wen(ifmap_buffer_wen),
	.filter_waddr(filter_buffer_waddr),
    .filter_wen(filter_buffer_wen),
	.index_waddr(index_buffer_waddr),
    .index_wen(index_buffer_wen),
	.ifmap_wdata(ifmap_data), .filter_wdata(weight_data), .index_wdata(index_data),
	
    .ifmap_raddr_1(ifmap_raddr_1), .ifmap_raddr_2(ifmap_raddr_2), .ifmap_raddr_3(ifmap_raddr_3), .ifmap_raddr_4(ifmap_raddr_4),
	.ifmap_raddr_5(ifmap_raddr_5), .ifmap_raddr_6(ifmap_raddr_6) , .ifmap_raddr_7(ifmap_raddr_7), .ifmap_raddr_8(ifmap_raddr_8),
	.ifmap_raddr_9(ifmap_raddr_9), .ifmap_raddr_10(ifmap_raddr_10), .ifmap_raddr_11(ifmap_raddr_11), .ifmap_raddr_12(ifmap_raddr_12),
	.ifmap_raddr_13(ifmap_raddr_13), .ifmap_raddr_14(ifmap_raddr_14), .ifmap_raddr_15(ifmap_raddr_15), .ifmap_raddr_16(ifmap_raddr_16),
	.ifmap_ren_1(ifmap_ren_1), .ifmap_ren_2(ifmap_ren_2), .ifmap_ren_3(ifmap_ren_3), .ifmap_ren_4(ifmap_ren_4),
	.ifmap_ren_5(ifmap_ren_5), .ifmap_ren_6(ifmap_ren_6), .ifmap_ren_7(ifmap_ren_7), .ifmap_ren_8(ifmap_ren_8),
	.ifmap_ren_9(ifmap_ren_9), .ifmap_ren_10(ifmap_ren_10), .ifmap_ren_11(ifmap_ren_11), .ifmap_ren_12(ifmap_ren_12),
	.ifmap_ren_13(ifmap_ren_13), .ifmap_ren_14(ifmap_ren_14), .ifmap_ren_15(ifmap_ren_15), .ifmap_ren_16(ifmap_ren_16),
	.ifmap_sel_1_1(ifmap_sel_1_1), .ifmap_sel_1_2(ifmap_sel_1_2), .ifmap_sel_1_3(ifmap_sel_1_3),
	.ifmap_sel_2_1(ifmap_sel_2_1), .ifmap_sel_2_2(ifmap_sel_2_2), .ifmap_sel_2_3(ifmap_sel_2_3),
	.ifmap_sel_3_1(ifmap_sel_3_1), .ifmap_sel_3_2(ifmap_sel_3_2), .ifmap_sel_3_3(ifmap_sel_3_3),
	.ifmap_sel_4_1(ifmap_sel_4_1), .ifmap_sel_4_2(ifmap_sel_4_2), .ifmap_sel_4_3(ifmap_sel_4_3),
    .filter_raddr_1(filter_raddr_1), .filter_raddr_2(filter_raddr_2), .filter_raddr_3(filter_raddr_3), .filter_raddr_4(filter_raddr_4),
	.filter_raddr_5(filter_raddr_5), .filter_raddr_6(filter_raddr_6), .filter_raddr_7(filter_raddr_7), .filter_raddr_8(filter_raddr_8),
	.filter_raddr_9(filter_raddr_9),.filter_raddr_10(filter_raddr_10),.filter_raddr_11(filter_raddr_11),.filter_raddr_12(filter_raddr_12),
	.filter_raddr_13(filter_raddr_13),.filter_raddr_14(filter_raddr_14),.filter_raddr_15(filter_raddr_15),.filter_raddr_16(filter_raddr_16),
	.filter_ren_1(filter_ren_1),.filter_ren_2(filter_ren_2),.filter_ren_3(filter_ren_3),.filter_ren_4(filter_ren_4),
	.filter_ren_5(filter_ren_5),.filter_ren_6(filter_ren_6),.filter_ren_7(filter_ren_7),.filter_ren_8(filter_ren_8),
	.filter_ren_9(filter_ren_9),.filter_ren_10(filter_ren_10),.filter_ren_11(filter_ren_11),.filter_ren_12(filter_ren_12),
	.filter_ren_13(filter_ren_13),.filter_ren_14(filter_ren_14),.filter_ren_15(filter_ren_15),.filter_ren_16(filter_ren_16),
	.filter_sel_1_1(filter_sel_1_1),.filter_sel_1_2(filter_sel_1_2),.filter_sel_1_3(filter_sel_1_3),.filter_sel_1_4(filter_sel_1_4),
	.filter_sel_2_1(filter_sel_2_1),.filter_sel_2_2(filter_sel_2_2),.filter_sel_2_3(filter_sel_2_3),.filter_sel_2_4(filter_sel_2_4),
	.filter_sel_3_1(filter_sel_3_1),.filter_sel_3_2(filter_sel_3_2),.filter_sel_3_3(filter_sel_3_3),.filter_sel_3_4(filter_sel_3_4),
	.index_raddr_1(index_raddr_1),.index_raddr_2(index_raddr_2),.index_raddr_3(index_raddr_3),.index_raddr_4(index_raddr_4),
	.index_ren_1(index_ren_1),.index_ren_2(index_ren_2),.index_ren_3(index_ren_3),.index_ren_4(index_ren_4),
	.index_sel_1_1(index_sel_1_1),.index_sel_1_2(index_sel_1_2),.index_sel_1_3(index_sel_1_3),.index_sel_1_4(index_sel_1_4),
	.index_sel_2_1(index_sel_2_1),.index_sel_2_2(index_sel_2_2),.index_sel_2_3(index_sel_2_3),.index_sel_2_4(index_sel_2_4),
	.index_sel_3_1(index_sel_3_1),.index_sel_3_2(index_sel_3_2),.index_sel_3_3(index_sel_3_3),.index_sel_3_4(index_sel_3_4),
	//psum
	.psum_1(psum_1), .psum_2(psum_2), .psum_3(psum_3), .psum_4(psum_4), 
	.psum_5(psum_5), .psum_6(psum_6), .psum_7(psum_7), .psum_8(psum_8), 
	.psum_9(psum_9), .psum_10(psum_10), .psum_11(psum_11), .psum_12(psum_12), 
	.psum_13(psum_13), .psum_14(psum_14), .psum_15(psum_15), .psum_16(psum_16)
);

Controller Controller(
	.clk(clk),
    .rst(rst),
    .start(start),
	.confi(confi),
    //sram	
	.ifmap_sram_addr(ifmap_sram_addr),
	.filter_sram_addr(weight_sram_addr),
	.index_sram_addr(index_sram_addr),
	.ifmap_sram_ren(ifmap_sram_ren),
	.filter_sram_ren(filter_sram_ren),
	.index_sram_ren(index_sram_ren),
	.post_unit_wen(post_unit_wen),
    .update(update), //call SRAM to renew data
    .Co(Co), // to post unit
    .W(W), // to post unit 
	.result_sel(result_sel),
    //buffer
    .ifmap_buffer_waddr(ifmap_buffer_waddr),
    .ifmap_buffer_wen(ifmap_buffer_wen),
	.filter_buffer_waddr(filter_buffer_waddr),
    .filter_buffer_wen(filter_buffer_wen),
	.index_buffer_waddr(index_buffer_waddr),
    .index_buffer_wen(index_buffer_wen),
    .ifmap_raddr_1(ifmap_raddr_1), .ifmap_raddr_2(ifmap_raddr_2), .ifmap_raddr_3(ifmap_raddr_3), .ifmap_raddr_4(ifmap_raddr_4),
	.ifmap_raddr_5(ifmap_raddr_5), .ifmap_raddr_6(ifmap_raddr_6) , .ifmap_raddr_7(ifmap_raddr_7), .ifmap_raddr_8(ifmap_raddr_8),
	.ifmap_raddr_9(ifmap_raddr_9), .ifmap_raddr_10(ifmap_raddr_10), .ifmap_raddr_11(ifmap_raddr_11), .ifmap_raddr_12(ifmap_raddr_12),
	.ifmap_raddr_13(ifmap_raddr_13), .ifmap_raddr_14(ifmap_raddr_14), .ifmap_raddr_15(ifmap_raddr_15), .ifmap_raddr_16(ifmap_raddr_16),
	.ifmap_ren_1(ifmap_ren_1), .ifmap_ren_2(ifmap_ren_2), .ifmap_ren_3(ifmap_ren_3), .ifmap_ren_4(ifmap_ren_4),
	.ifmap_ren_5(ifmap_ren_5), .ifmap_ren_6(ifmap_ren_6), .ifmap_ren_7(ifmap_ren_7), .ifmap_ren_8(ifmap_ren_8),
	.ifmap_ren_9(ifmap_ren_9), .ifmap_ren_10(ifmap_ren_10), .ifmap_ren_11(ifmap_ren_11), .ifmap_ren_12(ifmap_ren_12),
	.ifmap_ren_13(ifmap_ren_13), .ifmap_ren_14(ifmap_ren_14), .ifmap_ren_15(ifmap_ren_15), .ifmap_ren_16(ifmap_ren_16),
	.ifmap_sel_1_1(ifmap_sel_1_1), .ifmap_sel_1_2(ifmap_sel_1_2), .ifmap_sel_1_3(ifmap_sel_1_3),
	.ifmap_sel_2_1(ifmap_sel_2_1), .ifmap_sel_2_2(ifmap_sel_2_2), .ifmap_sel_2_3(ifmap_sel_2_3),
	.ifmap_sel_3_1(ifmap_sel_3_1), .ifmap_sel_3_2(ifmap_sel_3_2), .ifmap_sel_3_3(ifmap_sel_3_3),
	.ifmap_sel_4_1(ifmap_sel_4_1), .ifmap_sel_4_2(ifmap_sel_4_2), .ifmap_sel_4_3(ifmap_sel_4_3),
    .filter_raddr_1(filter_raddr_1), .filter_raddr_2(filter_raddr_2), .filter_raddr_3(filter_raddr_3), .filter_raddr_4(filter_raddr_4),
	.filter_raddr_5(filter_raddr_5), .filter_raddr_6(filter_raddr_6), .filter_raddr_7(filter_raddr_7), .filter_raddr_8(filter_raddr_8),
	.filter_raddr_9(filter_raddr_9),.filter_raddr_10(filter_raddr_10),.filter_raddr_11(filter_raddr_11),.filter_raddr_12(filter_raddr_12),
	.filter_raddr_13(filter_raddr_13),.filter_raddr_14(filter_raddr_14),.filter_raddr_15(filter_raddr_15),.filter_raddr_16(filter_raddr_16),
	.filter_ren_1(filter_ren_1),.filter_ren_2(filter_ren_2),.filter_ren_3(filter_ren_3),.filter_ren_4(filter_ren_4),
	.filter_ren_5(filter_ren_5),.filter_ren_6(filter_ren_6),.filter_ren_7(filter_ren_7),.filter_ren_8(filter_ren_8),
	.filter_ren_9(filter_ren_9),.filter_ren_10(filter_ren_10),.filter_ren_11(filter_ren_11),.filter_ren_12(filter_ren_12),
	.filter_ren_13(filter_ren_13),.filter_ren_14(filter_ren_14),.filter_ren_15(filter_ren_15),.filter_ren_16(filter_ren_16),

	.filter_sel_1_1(filter_sel_1_1),.filter_sel_1_2(filter_sel_1_2),.filter_sel_1_3(filter_sel_1_3),.filter_sel_1_4(filter_sel_1_4),
	.filter_sel_2_1(filter_sel_2_1),.filter_sel_2_2(filter_sel_2_2),.filter_sel_2_3(filter_sel_2_3),.filter_sel_2_4(filter_sel_2_4),
	.filter_sel_3_1(filter_sel_3_1),.filter_sel_3_2(filter_sel_3_2),.filter_sel_3_3(filter_sel_3_3),.filter_sel_3_4(filter_sel_3_4),

	.index_raddr_1(index_raddr_1),.index_raddr_2(index_raddr_2),.index_raddr_3(index_raddr_3),.index_raddr_4(index_raddr_4),
	.index_ren_1(index_ren_1),.index_ren_2(index_ren_2),.index_ren_3(index_ren_3),.index_ren_4(index_ren_4),
	.index_sel_1_1(index_sel_1_1),.index_sel_1_2(index_sel_1_2),.index_sel_1_3(index_sel_1_3),.index_sel_1_4(index_sel_1_4),
	.index_sel_2_1(index_sel_2_1),.index_sel_2_2(index_sel_2_2),.index_sel_2_3(index_sel_2_3),.index_sel_2_4(index_sel_2_4),
	.index_sel_3_1(index_sel_3_1),.index_sel_3_2(index_sel_3_2),.index_sel_3_3(index_sel_3_3),.index_sel_3_4(index_sel_3_4)
);

Accumulator Accumulator_1(.clk(clk), .rst(rst), .psum(psum_1), .result(result_1));
Accumulator Accumulator_2(.clk(clk), .rst(rst), .psum(psum_2), .result(result_2));
Accumulator Accumulator_3(.clk(clk), .rst(rst), .psum(psum_3), .result(result_3));
Accumulator Accumulator_4(.clk(clk), .rst(rst), .psum(psum_4), .result(result_4));
Accumulator Accumulator_5(.clk(clk), .rst(rst), .psum(psum_5), .result(result_5));
Accumulator Accumulator_6(.clk(clk), .rst(rst), .psum(psum_6), .result(result_6));
Accumulator Accumulator_7(.clk(clk), .rst(rst), .psum(psum_7), .result(result_7));
Accumulator Accumulator_8(.clk(clk), .rst(rst), .psum(psum_8), .result(result_8));
Accumulator Accumulator_9(.clk(clk), .rst(rst), .psum(psum_9), .result(result_9));
Accumulator Accumulator_10(.clk(clk), .rst(rst), .psum(psum_10), .result(result_10));
Accumulator Accumulator_11(.clk(clk), .rst(rst), .psum(psum_11), .result(result_11));
Accumulator Accumulator_12(.clk(clk), .rst(rst), .psum(psum_12), .result(result_12));
Accumulator Accumulator_13(.clk(clk), .rst(rst), .psum(psum_13), .result(result_13));
Accumulator Accumulator_14(.clk(clk), .rst(rst), .psum(psum_14), .result(result_14));
Accumulator Accumulator_15(.clk(clk), .rst(rst), .psum(psum_15), .result(result_15));
Accumulator Accumulator_16(.clk(clk), .rst(rst), .psum(psum_16), .result(result_16));

Mux_16_32b Mux_16_32b(
	.sel(result_sel),
	.input_data_0(result_1), 
	.input_data_1(result_2), 
	.input_data_2(result_3), 
	.input_data_3(result_4), 
	.input_data_4(result_5), 
	.input_data_5(result_6), 
	.input_data_6(result_7), 
	.input_data_7(result_8), 
	.input_data_8(result_9), 
	.input_data_9(result_10), 
	.input_data_10(result_11), 
	.input_data_11(result_12), 
	.input_data_12(result_13), 
	.input_data_13(result_14), 
	.input_data_14(result_15), 
	.input_data_15(result_16), 
	.output_data(result)
);
endmodule