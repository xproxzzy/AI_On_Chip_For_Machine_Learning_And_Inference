`include "PE.v"
`include "Mux_2_4b.v"
`include "Mux_2_24b.v"
`include "Mux_2_56b.v"

module PE_array(
	input		clk, 
	input		rst, 
	input		fully_connect, 
	//ifmap buffer
	input		[7:0]	ifmap_waddr,
	input				ifmap_wen,
	input		[23:0]	ifmap_wdata,
	input		[7:0]	ifmap_raddr_1, ifmap_raddr_2, ifmap_raddr_3, ifmap_raddr_4,
	input		[7:0]	ifmap_raddr_5, ifmap_raddr_6, ifmap_raddr_7, ifmap_raddr_8,
	input		[7:0]	ifmap_raddr_9, ifmap_raddr_10, ifmap_raddr_11, ifmap_raddr_12,
	input		[7:0]	ifmap_raddr_13, ifmap_raddr_14, ifmap_raddr_15, ifmap_raddr_16,
	input				ifmap_ren_1, ifmap_ren_2, ifmap_ren_3, ifmap_ren_4,
	input				ifmap_ren_5, ifmap_ren_6, ifmap_ren_7, ifmap_ren_8,
	input				ifmap_ren_9, ifmap_ren_10, ifmap_ren_11, ifmap_ren_12,
	input				ifmap_ren_13, ifmap_ren_14, ifmap_ren_15, ifmap_ren_16,
	input				ifmap_sel_1_1, ifmap_sel_1_2, ifmap_sel_1_3,
	input				ifmap_sel_2_1, ifmap_sel_2_2, ifmap_sel_2_3,
	input				ifmap_sel_3_1, ifmap_sel_3_2, ifmap_sel_3_3,
	input				ifmap_sel_4_1, ifmap_sel_4_2, ifmap_sel_4_3,
	//filter buffer
	input		[6:0]	filter_waddr,
	input				filter_wen,
	input		[23:0]	filter_wdata,
	input		[6:0]	filter_raddr_1, filter_raddr_2, filter_raddr_3, filter_raddr_4,
	input		[6:0]	filter_raddr_5, filter_raddr_6, filter_raddr_7, filter_raddr_8,
	input		[6:0]	filter_raddr_9, filter_raddr_10, filter_raddr_11, filter_raddr_12,
	input		[6:0]	filter_raddr_13, filter_raddr_14, filter_raddr_15, filter_raddr_16,
	input				filter_ren_1, filter_ren_2, filter_ren_3, filter_ren_4,
	input				filter_ren_5, filter_ren_6, filter_ren_7, filter_ren_8,
	input				filter_ren_9, filter_ren_10, filter_ren_11, filter_ren_12,
	input				filter_ren_13, filter_ren_14, filter_ren_15, filter_ren_16,
	input				filter_sel_1_1, filter_sel_1_2, filter_sel_1_3, filter_sel_1_4,
	input				filter_sel_2_1, filter_sel_2_2, filter_sel_2_3, filter_sel_2_4,
	input				filter_sel_3_1, filter_sel_3_2, filter_sel_3_3, filter_sel_3_4,
	//index buffer
	input		[6:0]	index_waddr,
	input				index_wen,
	input		[3:0]	index_wdata,
	input		[6:0]	index_raddr_1, index_raddr_2, index_raddr_3, index_raddr_4,
	input				index_ren_1, index_ren_2, index_ren_3, index_ren_4,
	input				index_sel_1_1, index_sel_1_2, index_sel_1_3, index_sel_1_4,
	input				index_sel_2_1, index_sel_2_2, index_sel_2_3, index_sel_2_4,
	input				index_sel_3_1, index_sel_3_2, index_sel_3_3, index_sel_3_4,
	//psum
	output		[17:0]	psum_1, psum_2, psum_3, psum_4, psum_5, psum_6, psum_7, psum_8, psum_9, psum_10, psum_11, psum_12, psum_13, psum_14, psum_15, psum_16
);

//Buffer
reg 	[23:0]	ifmap_buffer	[191:0];
reg 	[23:0]	filter_buffer	[127:0];
reg 	[3:0]	index_buffer	[127:0];

//reg, wire
reg		[55:0]	ifmap_rdata_1, ifmap_rdata_2, ifmap_rdata_3, ifmap_rdata_4; 
reg		[55:0]	ifmap_rdata_5, ifmap_rdata_6, ifmap_rdata_7, ifmap_rdata_8;
reg		[55:0]	ifmap_rdata_9, ifmap_rdata_10, ifmap_rdata_11, ifmap_rdata_12; 
reg		[55:0]	ifmap_rdata_13, ifmap_rdata_14, ifmap_rdata_15, ifmap_rdata_16;
reg		[23:0]	filter_rdata_1, filter_rdata_2, filter_rdata_3, filter_rdata_4; 
reg		[23:0]	filter_rdata_5, filter_rdata_6, filter_rdata_7, filter_rdata_8;
reg		[23:0]	filter_rdata_9, filter_rdata_10, filter_rdata_11, filter_rdata_12; 
reg		[23:0]	filter_rdata_13, filter_rdata_14, filter_rdata_15, filter_rdata_16;
reg		[3:0]	index_rdata_1, index_rdata_2, index_rdata_3, index_rdata_4; 
reg		[3:0]	index_rdata_5, index_rdata_6, index_rdata_7, index_rdata_8;
reg		[3:0]	index_rdata_9, index_rdata_10, index_rdata_11, index_rdata_12; 
reg		[3:0]	index_rdata_13, index_rdata_14, index_rdata_15, index_rdata_16;

wire [55:0]	ifmap_i_1_2, ifmap_o_1_1, 
			ifmap_i_1_3, ifmap_o_1_2, 
			ifmap_i_1_4, ifmap_o_1_3, 
			ifmap_i_2_2, ifmap_o_2_1, 
			ifmap_i_2_3, ifmap_o_2_2, 
			ifmap_i_2_4, ifmap_o_2_3, 
			ifmap_i_3_2, ifmap_o_3_1, 
			ifmap_i_3_3, ifmap_o_3_2, 
			ifmap_i_3_4, ifmap_o_3_3, 
			ifmap_i_4_2, ifmap_o_4_1, 
			ifmap_i_4_3, ifmap_o_4_2, 
			ifmap_i_4_4, ifmap_o_4_3;

wire [23:0]	filter_i_2_1, filter_o_1_1, 
			filter_i_3_1, filter_o_2_1, 
			filter_i_4_1, filter_o_3_1, 
			filter_i_2_2, filter_o_1_2, 
			filter_i_3_2, filter_o_2_2, 
			filter_i_4_2, filter_o_3_2, 
			filter_i_2_3, filter_o_1_3, 
			filter_i_3_3, filter_o_2_3, 
			filter_i_4_3, filter_o_3_3, 
			filter_i_2_4, filter_o_1_4, 
			filter_i_3_4, filter_o_2_4, 
			filter_i_4_4, filter_o_3_4;

wire [3:0]	index_i_2_1, index_o_1_1, 
			index_i_3_1, index_o_2_1, 
			index_i_4_1, index_o_3_1, 
			index_i_2_2, index_o_1_2, 
			index_i_3_2, index_o_2_2, 
			index_i_4_2, index_o_3_2, 
			index_i_2_3, index_o_1_3, 
			index_i_3_3, index_o_2_3, 
			index_i_4_3, index_o_3_3, 
			index_i_2_4, index_o_1_4, 
			index_i_3_4, index_o_2_4, 
			index_i_4_4, index_o_3_4;

//ifmap buffer
always @(posedge clk)
begin
	if(ifmap_wen)
	begin
		ifmap_buffer[ifmap_waddr] <= ifmap_wdata;
	end
	else
	begin
		ifmap_buffer[ifmap_waddr] <= ifmap_buffer[ifmap_waddr];
	end
end
always @(*)
begin
	if(ifmap_ren_1)
	begin
		if(fully_connect)
		begin
			ifmap_rdata_1[7:0] = ifmap_buffer[ifmap_raddr_1][7:0];
			ifmap_rdata_1[23:8] = 16'd0;
			ifmap_rdata_1[31:24] = ifmap_buffer[ifmap_raddr_1][15:8];
			ifmap_rdata_1[39:32] = ifmap_buffer[ifmap_raddr_1][23:16];
			ifmap_rdata_1[55:40] = 16'd0;
		end
		else
		begin
			ifmap_rdata_1[7:0] = ifmap_buffer[ifmap_raddr_1][7:0];
			ifmap_rdata_1[15:8] = ifmap_buffer[ifmap_raddr_1+8'd1][7:0];
			ifmap_rdata_1[23:16] = ifmap_buffer[ifmap_raddr_1+8'd2][7:0];
			ifmap_rdata_1[31:24] = ifmap_buffer[ifmap_raddr_1+8'd1][15:8];
			ifmap_rdata_1[39:32] = ifmap_buffer[ifmap_raddr_1][23:16];
			ifmap_rdata_1[47:40] = ifmap_buffer[ifmap_raddr_1+8'd1][23:16];
			ifmap_rdata_1[55:48] = ifmap_buffer[ifmap_raddr_1+8'd2][23:16];
		end
	end
	else
	begin
		ifmap_rdata_1 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_5)
	begin
		if(fully_connect)
		begin
			ifmap_rdata_5[7:0] = ifmap_buffer[ifmap_raddr_5][7:0];
			ifmap_rdata_5[23:8] = 16'd0;
			ifmap_rdata_5[31:24] = ifmap_buffer[ifmap_raddr_5][15:8];
			ifmap_rdata_5[39:32] = ifmap_buffer[ifmap_raddr_5][23:16];
			ifmap_rdata_5[55:40] = 16'd0;
		end
		else
		begin
			ifmap_rdata_5[7:0] = ifmap_buffer[ifmap_raddr_5][7:0];
			ifmap_rdata_5[15:8] = ifmap_buffer[ifmap_raddr_5+8'd1][7:0];
			ifmap_rdata_5[23:16] = ifmap_buffer[ifmap_raddr_5+8'd2][7:0];
			ifmap_rdata_5[31:24] = ifmap_buffer[ifmap_raddr_5+8'd1][15:8];
			ifmap_rdata_5[39:32] = ifmap_buffer[ifmap_raddr_5][23:16];
			ifmap_rdata_5[47:40] = ifmap_buffer[ifmap_raddr_5+8'd1][23:16];
			ifmap_rdata_5[55:48] = ifmap_buffer[ifmap_raddr_5+8'd2][23:16];
		end
	end
	else
	begin
		ifmap_rdata_5 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_9)
	begin
		if(fully_connect)
		begin
			ifmap_rdata_9[7:0] = ifmap_buffer[ifmap_raddr_9][7:0];
			ifmap_rdata_9[23:8] = 16'd0;
			ifmap_rdata_9[31:24] = ifmap_buffer[ifmap_raddr_9][15:8];
			ifmap_rdata_9[39:32] = ifmap_buffer[ifmap_raddr_9][23:16];
			ifmap_rdata_9[55:40] = 16'd0;
		end
		else
		begin
			ifmap_rdata_9[7:0] = ifmap_buffer[ifmap_raddr_9][7:0];
			ifmap_rdata_9[15:8] = ifmap_buffer[ifmap_raddr_9+8'd1][7:0];
			ifmap_rdata_9[23:16] = ifmap_buffer[ifmap_raddr_9+8'd2][7:0];
			ifmap_rdata_9[31:24] = ifmap_buffer[ifmap_raddr_9+8'd1][15:8];
			ifmap_rdata_9[39:32] = ifmap_buffer[ifmap_raddr_9][23:16];
			ifmap_rdata_9[47:40] = ifmap_buffer[ifmap_raddr_9+8'd1][23:16];
			ifmap_rdata_9[55:48] = ifmap_buffer[ifmap_raddr_9+8'd2][23:16];
		end
	end
	else
	begin
		ifmap_rdata_9 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_13)
	begin
		if(fully_connect)
		begin
			ifmap_rdata_13[7:0] = ifmap_buffer[ifmap_raddr_13][7:0];
			ifmap_rdata_13[23:8] = 16'd0;
			ifmap_rdata_13[31:24] = ifmap_buffer[ifmap_raddr_13][15:8];
			ifmap_rdata_13[39:32] = ifmap_buffer[ifmap_raddr_13][23:16];
			ifmap_rdata_13[55:40] = 16'd0;
		end
		else
		begin
			ifmap_rdata_13[7:0] = ifmap_buffer[ifmap_raddr_13][7:0];
			ifmap_rdata_13[15:8] = ifmap_buffer[ifmap_raddr_13+8'd1][7:0];
			ifmap_rdata_13[23:16] = ifmap_buffer[ifmap_raddr_13+8'd2][7:0];
			ifmap_rdata_13[31:24] = ifmap_buffer[ifmap_raddr_13+8'd1][15:8];
			ifmap_rdata_13[39:32] = ifmap_buffer[ifmap_raddr_13][23:16];
			ifmap_rdata_13[47:40] = ifmap_buffer[ifmap_raddr_13+8'd1][23:16];
			ifmap_rdata_13[55:48] = ifmap_buffer[ifmap_raddr_13+8'd2][23:16];
		end
	end
	else
	begin
		ifmap_rdata_13 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_2)
	begin
		ifmap_rdata_2[7:0] = ifmap_buffer[ifmap_raddr_2][7:0];
		ifmap_rdata_2[23:8] = 16'd0;
		ifmap_rdata_2[31:24] = ifmap_buffer[ifmap_raddr_2][15:8];
		ifmap_rdata_2[39:32] = ifmap_buffer[ifmap_raddr_2][23:16];
		ifmap_rdata_2[55:40] = 16'd0;
	end
	else
	begin
		ifmap_rdata_2 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_3)
	begin
		ifmap_rdata_3[7:0] = ifmap_buffer[ifmap_raddr_3][7:0];
		ifmap_rdata_3[23:8] = 16'd0;
		ifmap_rdata_3[31:24] = ifmap_buffer[ifmap_raddr_3][15:8];
		ifmap_rdata_3[39:32] = ifmap_buffer[ifmap_raddr_3][23:16];
		ifmap_rdata_3[55:40] = 16'd0;
	end
	else
	begin
		ifmap_rdata_3 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_4)
	begin
		ifmap_rdata_4[7:0] = ifmap_buffer[ifmap_raddr_4][7:0];
		ifmap_rdata_4[23:8] = 16'd0;
		ifmap_rdata_4[31:24] = ifmap_buffer[ifmap_raddr_4][15:8];
		ifmap_rdata_4[39:32] = ifmap_buffer[ifmap_raddr_4][23:16];
		ifmap_rdata_4[55:40] = 16'd0;
	end
	else
	begin
		ifmap_rdata_4 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_6)
	begin
		ifmap_rdata_6[7:0] = ifmap_buffer[ifmap_raddr_6][7:0];
		ifmap_rdata_6[23:8] = 16'd0;
		ifmap_rdata_6[31:24] = ifmap_buffer[ifmap_raddr_6][15:8];
		ifmap_rdata_6[39:32] = ifmap_buffer[ifmap_raddr_6][23:16];
		ifmap_rdata_6[55:40] = 16'd0;
	end
	else
	begin
		ifmap_rdata_6 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_7)
	begin
		ifmap_rdata_7[7:0] = ifmap_buffer[ifmap_raddr_7][7:0];
		ifmap_rdata_7[23:8] = 16'd0;
		ifmap_rdata_7[31:24] = ifmap_buffer[ifmap_raddr_7][15:8];
		ifmap_rdata_7[39:32] = ifmap_buffer[ifmap_raddr_7][23:16];
		ifmap_rdata_7[55:40] = 16'd0;
	end
	else
	begin
		ifmap_rdata_7 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_8)
	begin
		ifmap_rdata_8[7:0] = ifmap_buffer[ifmap_raddr_8][7:0];
		ifmap_rdata_8[23:8] = 16'd0;
		ifmap_rdata_8[31:24] = ifmap_buffer[ifmap_raddr_8][15:8];
		ifmap_rdata_8[39:32] = ifmap_buffer[ifmap_raddr_8][23:16];
		ifmap_rdata_8[55:40] = 16'd0;
	end
	else
	begin
		ifmap_rdata_8 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_10)
	begin
		ifmap_rdata_10[7:0] = ifmap_buffer[ifmap_raddr_10][7:0];
		ifmap_rdata_10[23:8] = 16'd0;
		ifmap_rdata_10[31:24] = ifmap_buffer[ifmap_raddr_10][15:8];
		ifmap_rdata_10[39:32] = ifmap_buffer[ifmap_raddr_10][23:16];
		ifmap_rdata_10[55:40] = 16'd0;
	end
	else
	begin
		ifmap_rdata_10 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_11)
	begin
		ifmap_rdata_11[7:0] = ifmap_buffer[ifmap_raddr_11][7:0];
		ifmap_rdata_11[23:8] = 16'd0;
		ifmap_rdata_11[31:24] = ifmap_buffer[ifmap_raddr_11][15:8];
		ifmap_rdata_11[39:32] = ifmap_buffer[ifmap_raddr_11][23:16];
		ifmap_rdata_11[55:40] = 16'd0;
	end
	else
	begin
		ifmap_rdata_11 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_12)
	begin
		ifmap_rdata_12[7:0] = ifmap_buffer[ifmap_raddr_12][7:0];
		ifmap_rdata_12[23:8] = 16'd0;
		ifmap_rdata_12[31:24] = ifmap_buffer[ifmap_raddr_12][15:8];
		ifmap_rdata_12[39:32] = ifmap_buffer[ifmap_raddr_12][23:16];
		ifmap_rdata_12[55:40] = 16'd0;
	end
	else
	begin
		ifmap_rdata_12 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_14)
	begin
		ifmap_rdata_14[7:0] = ifmap_buffer[ifmap_raddr_14][7:0];
		ifmap_rdata_14[23:8] = 16'd0;
		ifmap_rdata_14[31:24] = ifmap_buffer[ifmap_raddr_14][15:8];
		ifmap_rdata_14[39:32] = ifmap_buffer[ifmap_raddr_14][23:16];
		ifmap_rdata_14[55:40] = 16'd0;
	end
	else
	begin
		ifmap_rdata_14 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_15)
	begin
		ifmap_rdata_15[7:0] = ifmap_buffer[ifmap_raddr_15][7:0];
		ifmap_rdata_15[23:8] = 16'd0;
		ifmap_rdata_15[31:24] = ifmap_buffer[ifmap_raddr_15][15:8];
		ifmap_rdata_15[39:32] = ifmap_buffer[ifmap_raddr_15][23:16];
		ifmap_rdata_15[55:40] = 16'd0;
	end
	else
	begin
		ifmap_rdata_15 = 55'd0;
	end
end
always @(*)
begin
	if(ifmap_ren_16)
	begin
		ifmap_rdata_16[7:0] = ifmap_buffer[ifmap_raddr_16][7:0];
		ifmap_rdata_16[23:8] = 16'd0;
		ifmap_rdata_16[31:24] = ifmap_buffer[ifmap_raddr_16][15:8];
		ifmap_rdata_16[39:32] = ifmap_buffer[ifmap_raddr_16][23:16];
		ifmap_rdata_16[55:40] = 16'd0;
	end
	else
	begin
		ifmap_rdata_16 = 55'd0;
	end
end

//filter buffer
always @(posedge clk)
begin
	if(filter_wen)
	begin
		filter_buffer[filter_waddr] <= filter_wdata;
	end
	else
	begin
		filter_buffer[filter_waddr] <= filter_buffer[filter_waddr];
	end
end
always @(*)
begin
	if(filter_ren_1)	filter_rdata_1 = filter_buffer[filter_raddr_1];
	else				filter_rdata_1 = 24'd0;
end
always @(*)
begin
	if(filter_ren_2)	filter_rdata_2 = filter_buffer[filter_raddr_2];
	else				filter_rdata_2 = 24'd0;
end
always @(*)
begin
	if(filter_ren_3)	filter_rdata_3 = filter_buffer[filter_raddr_3];
	else				filter_rdata_3 = 24'd0;
end
always @(*)
begin
	if(filter_ren_4)	filter_rdata_4 = filter_buffer[filter_raddr_4];
	else				filter_rdata_4 = 24'd0;
end
always @(*)
begin
	if(filter_ren_5)	filter_rdata_5 = filter_buffer[filter_raddr_5];
	else				filter_rdata_5 = 24'd0;
end
always @(*)
begin
	if(filter_ren_6)	filter_rdata_6 = filter_buffer[filter_raddr_6];
	else				filter_rdata_6 = 24'd0;
end
always @(*)
begin
	if(filter_ren_7)	filter_rdata_7 = filter_buffer[filter_raddr_7];
	else				filter_rdata_7 = 24'd0;
end
always @(*)
begin
	if(filter_ren_8)	filter_rdata_8 = filter_buffer[filter_raddr_8];
	else				filter_rdata_8 = 24'd0;
end
always @(*)
begin
	if(filter_ren_9)	filter_rdata_9 = filter_buffer[filter_raddr_9];
	else				filter_rdata_9 = 24'd0;
end
always @(*)
begin
	if(filter_ren_10)	filter_rdata_10 = filter_buffer[filter_raddr_10];
	else				filter_rdata_10 = 24'd0;
end
always @(*)
begin
	if(filter_ren_11)	filter_rdata_11 = filter_buffer[filter_raddr_11];
	else				filter_rdata_11 = 24'd0;
end
always @(*)
begin
	if(filter_ren_12)	filter_rdata_12 = filter_buffer[filter_raddr_12];
	else				filter_rdata_12 = 24'd0;
end
always @(*)
begin
	if(filter_ren_13)	filter_rdata_13 = filter_buffer[filter_raddr_13];
	else				filter_rdata_13 = 24'd0;
end
always @(*)
begin
	if(filter_ren_14)	filter_rdata_14 = filter_buffer[filter_raddr_14];
	else				filter_rdata_14 = 24'd0;
end
always @(*)
begin
	if(filter_ren_15)	filter_rdata_15 = filter_buffer[filter_raddr_15];
	else				filter_rdata_15 = 24'd0;
end
always @(*)
begin
	if(filter_ren_16)	filter_rdata_16 = filter_buffer[filter_raddr_16];
	else				filter_rdata_16 = 24'd0;
end

//index buffer
always @(posedge clk)
begin
	if(index_wen)
	begin
		index_buffer[index_waddr] <= index_wdata;
	end
	else
	begin
		index_buffer[index_waddr] <= index_buffer[index_waddr];
	end
end
always @(*)
begin
	if((index_ren_1==1'b1)&&(fully_connect==1'b0))	index_rdata_1 = index_buffer[index_raddr_1];
	else											index_rdata_1 = 4'd0;
end
always @(*)
begin
	if((index_ren_2==1'b1)&&(fully_connect==1'b0))	index_rdata_2 = index_buffer[index_raddr_2];
	else											index_rdata_2 = 4'd0;
end
always @(*)
begin
	if((index_ren_3==1'b1)&&(fully_connect==1'b0))	index_rdata_3 = index_buffer[index_raddr_3];
	else											index_rdata_3 = 4'd0;
end
always @(*)
begin
	if((index_ren_4==1'b1)&&(fully_connect==1'b0))	index_rdata_4 = index_buffer[index_raddr_4];
	else											index_rdata_4 = 4'd0;
end
always @(*)
begin
	index_rdata_5 = 4'd0;
	index_rdata_6 = 4'd0;
	index_rdata_7 = 4'd0;
	index_rdata_8 = 4'd0;
	index_rdata_9 = 4'd0;
	index_rdata_10 = 4'd0;
	index_rdata_11 = 4'd0;
	index_rdata_12 = 4'd0;
	index_rdata_13 = 4'd0;
	index_rdata_14 = 4'd0;
	index_rdata_15 = 4'd0;
	index_rdata_16 = 4'd0;
end

//ifmap mux
Mux_2_56b	ifmap_mux_1_1(.clk(clk), .rst(rst), .sel(ifmap_sel_1_1), .pe_output(ifmap_o_1_1), .buffer_output(ifmap_rdata_2), .output_data(ifmap_i_1_2));
Mux_2_56b	ifmap_mux_1_2(.clk(clk), .rst(rst), .sel(ifmap_sel_1_2), .pe_output(ifmap_o_1_2), .buffer_output(ifmap_rdata_3), .output_data(ifmap_i_1_3));
Mux_2_56b	ifmap_mux_1_3(.clk(clk), .rst(rst), .sel(ifmap_sel_1_3), .pe_output(ifmap_o_1_3), .buffer_output(ifmap_rdata_4), .output_data(ifmap_i_1_4));
Mux_2_56b	ifmap_mux_2_1(.clk(clk), .rst(rst), .sel(ifmap_sel_2_1), .pe_output(ifmap_o_2_1), .buffer_output(ifmap_rdata_6), .output_data(ifmap_i_2_2));
Mux_2_56b	ifmap_mux_2_2(.clk(clk), .rst(rst), .sel(ifmap_sel_2_2), .pe_output(ifmap_o_2_2), .buffer_output(ifmap_rdata_7), .output_data(ifmap_i_2_3));
Mux_2_56b	ifmap_mux_2_3(.clk(clk), .rst(rst), .sel(ifmap_sel_2_3), .pe_output(ifmap_o_2_3), .buffer_output(ifmap_rdata_8), .output_data(ifmap_i_2_4));
Mux_2_56b	ifmap_mux_3_1(.clk(clk), .rst(rst), .sel(ifmap_sel_3_1), .pe_output(ifmap_o_3_1), .buffer_output(ifmap_rdata_10), .output_data(ifmap_i_3_2));
Mux_2_56b	ifmap_mux_3_2(.clk(clk), .rst(rst), .sel(ifmap_sel_3_2), .pe_output(ifmap_o_3_2), .buffer_output(ifmap_rdata_11), .output_data(ifmap_i_3_3));
Mux_2_56b	ifmap_mux_3_3(.clk(clk), .rst(rst), .sel(ifmap_sel_3_3), .pe_output(ifmap_o_3_3), .buffer_output(ifmap_rdata_12), .output_data(ifmap_i_3_4));
Mux_2_56b	ifmap_mux_4_1(.clk(clk), .rst(rst), .sel(ifmap_sel_4_1), .pe_output(ifmap_o_4_1), .buffer_output(ifmap_rdata_14), .output_data(ifmap_i_4_2));
Mux_2_56b	ifmap_mux_4_2(.clk(clk), .rst(rst), .sel(ifmap_sel_4_2), .pe_output(ifmap_o_4_2), .buffer_output(ifmap_rdata_15), .output_data(ifmap_i_4_3));
Mux_2_56b	ifmap_mux_4_3(.clk(clk), .rst(rst), .sel(ifmap_sel_4_3), .pe_output(ifmap_o_4_3), .buffer_output(ifmap_rdata_16), .output_data(ifmap_i_4_4));
//filter mux
Mux_2_24b	filter_mux_1_1(.clk(clk), .rst(rst), .sel(filter_sel_1_1), .pe_output(filter_o_1_1), .buffer_output(filter_rdata_5), .output_data(filter_i_2_1));
Mux_2_24b	filter_mux_1_2(.clk(clk), .rst(rst), .sel(filter_sel_1_2), .pe_output(filter_o_1_2), .buffer_output(filter_rdata_6), .output_data(filter_i_2_2));
Mux_2_24b	filter_mux_1_3(.clk(clk), .rst(rst), .sel(filter_sel_1_3), .pe_output(filter_o_1_3), .buffer_output(filter_rdata_7), .output_data(filter_i_2_3));
Mux_2_24b	filter_mux_1_4(.clk(clk), .rst(rst), .sel(filter_sel_1_4), .pe_output(filter_o_1_4), .buffer_output(filter_rdata_8), .output_data(filter_i_2_4));
Mux_2_24b	filter_mux_2_1(.clk(clk), .rst(rst), .sel(filter_sel_2_1), .pe_output(filter_o_2_1), .buffer_output(filter_rdata_9), .output_data(filter_i_3_1));
Mux_2_24b	filter_mux_2_2(.clk(clk), .rst(rst), .sel(filter_sel_2_2), .pe_output(filter_o_2_2), .buffer_output(filter_rdata_10), .output_data(filter_i_3_2));
Mux_2_24b	filter_mux_2_3(.clk(clk), .rst(rst), .sel(filter_sel_2_3), .pe_output(filter_o_2_3), .buffer_output(filter_rdata_12), .output_data(filter_i_3_3));
Mux_2_24b	filter_mux_2_4(.clk(clk), .rst(rst), .sel(filter_sel_2_4), .pe_output(filter_o_2_4), .buffer_output(filter_rdata_11), .output_data(filter_i_3_4));
Mux_2_24b	filter_mux_3_1(.clk(clk), .rst(rst), .sel(filter_sel_3_1), .pe_output(filter_o_3_1), .buffer_output(filter_rdata_13), .output_data(filter_i_4_1));
Mux_2_24b	filter_mux_3_2(.clk(clk), .rst(rst), .sel(filter_sel_3_2), .pe_output(filter_o_3_2), .buffer_output(filter_rdata_14), .output_data(filter_i_4_2));
Mux_2_24b	filter_mux_3_3(.clk(clk), .rst(rst), .sel(filter_sel_3_3), .pe_output(filter_o_3_3), .buffer_output(filter_rdata_15), .output_data(filter_i_4_3));
Mux_2_24b	filter_mux_3_4(.clk(clk), .rst(rst), .sel(filter_sel_3_4), .pe_output(filter_o_3_4), .buffer_output(filter_rdata_16), .output_data(filter_i_4_4));
//index mux
Mux_2_4b	index_mux_1_1(.clk(clk), .rst(rst), .sel(index_sel_1_1), .pe_output(index_o_1_1), .buffer_output(index_rdata_5), .output_data(index_i_2_1));
Mux_2_4b	index_mux_1_2(.clk(clk), .rst(rst), .sel(index_sel_1_2), .pe_output(index_o_1_2), .buffer_output(index_rdata_6), .output_data(index_i_2_2));
Mux_2_4b	index_mux_1_3(.clk(clk), .rst(rst), .sel(index_sel_1_3), .pe_output(index_o_1_3), .buffer_output(index_rdata_7), .output_data(index_i_2_3));
Mux_2_4b	index_mux_1_4(.clk(clk), .rst(rst), .sel(index_sel_1_4), .pe_output(index_o_1_4), .buffer_output(index_rdata_8), .output_data(index_i_2_4));
Mux_2_4b	index_mux_2_1(.clk(clk), .rst(rst), .sel(index_sel_2_1), .pe_output(index_o_2_1), .buffer_output(index_rdata_9), .output_data(index_i_3_1));
Mux_2_4b	index_mux_2_2(.clk(clk), .rst(rst), .sel(index_sel_2_2), .pe_output(index_o_2_2), .buffer_output(index_rdata_10), .output_data(index_i_3_2));
Mux_2_4b	index_mux_2_3(.clk(clk), .rst(rst), .sel(index_sel_2_3), .pe_output(index_o_2_3), .buffer_output(index_rdata_11), .output_data(index_i_3_3));
Mux_2_4b	index_mux_2_4(.clk(clk), .rst(rst), .sel(index_sel_2_4), .pe_output(index_o_2_4), .buffer_output(index_rdata_12), .output_data(index_i_3_4));
Mux_2_4b	index_mux_3_1(.clk(clk), .rst(rst), .sel(index_sel_3_1), .pe_output(index_o_3_1), .buffer_output(index_rdata_13), .output_data(index_i_4_1));
Mux_2_4b	index_mux_3_2(.clk(clk), .rst(rst), .sel(index_sel_3_2), .pe_output(index_o_3_2), .buffer_output(index_rdata_14), .output_data(index_i_4_2));
Mux_2_4b	index_mux_3_3(.clk(clk), .rst(rst), .sel(index_sel_3_3), .pe_output(index_o_3_3), .buffer_output(index_rdata_15), .output_data(index_i_4_3));
Mux_2_4b	index_mux_3_4(.clk(clk), .rst(rst), .sel(index_sel_3_4), .pe_output(index_o_3_4), .buffer_output(index_rdata_16), .output_data(index_i_4_4));


PE	PE_1_1( .ifmap_i(ifmap_rdata_1), .filter_i(filter_rdata_1), .index_i(index_rdata_1), 
			.ifmap_o(ifmap_o_1_1), .filter_o(filter_o_1_1), .index_o(index_o_1_1), .psum(psum_1));
PE	PE_1_2( .ifmap_i(ifmap_i_1_2), .filter_i(filter_rdata_2), .index_i(index_rdata_2), 
			.ifmap_o(ifmap_o_1_2), .filter_o(filter_o_1_2), .index_o(index_o_1_2), .psum(psum_2));
PE	PE_1_3( .ifmap_i(ifmap_i_1_3), .filter_i(filter_rdata_3), .index_i(index_rdata_3), 
			.ifmap_o(ifmap_o_1_3), .filter_o(filter_o_1_3), .index_o(index_o_1_3), .psum(psum_3));
PE	PE_1_4( .ifmap_i(ifmap_i_1_4), .filter_i(filter_rdata_4), .index_i(index_rdata_4), 
			.ifmap_o(), .filter_o(filter_o_1_4), .index_o(index_o_1_4), .psum(psum_4));
PE	PE_2_1( .ifmap_i(ifmap_rdata_5), .filter_i(filter_i_2_1), .index_i(index_i_2_1), 
			.ifmap_o(ifmap_o_2_1), .filter_o(filter_o_2_1), .index_o(index_o_2_1), .psum(psum_5));
PE	PE_2_2( .ifmap_i(ifmap_i_2_2), .filter_i(filter_i_2_2), .index_i(index_i_2_2), 
			.ifmap_o(ifmap_o_2_2), .filter_o(filter_o_2_2), .index_o(index_o_2_2), .psum(psum_6));
PE	PE_2_3( .ifmap_i(ifmap_i_2_3), .filter_i(filter_i_2_3), .index_i(index_i_2_3), 
			.ifmap_o(ifmap_o_2_3), .filter_o(filter_o_2_3), .index_o(index_o_2_3), .psum(psum_7));
PE	PE_2_4( .ifmap_i(ifmap_i_2_4), .filter_i(filter_i_2_3), .index_i(index_i_2_4), 
			.ifmap_o(), .filter_o(filter_o_2_4), .index_o(index_o_2_4), .psum(psum_8));
PE	PE_3_1( .ifmap_i(ifmap_rdata_9), .filter_i(filter_i_3_1), .index_i(index_i_3_1), 
			.ifmap_o(ifmap_o_3_1), .filter_o(filter_o_3_1), .index_o(index_o_3_1), .psum(psum_9));
PE	PE_3_2( .ifmap_i(ifmap_i_3_2), .filter_i(filter_i_3_2), .index_i(index_i_3_2), 
			.ifmap_o(ifmap_o_3_2), .filter_o(filter_o_3_2), .index_o(index_o_3_2), .psum(psum_10));
PE	PE_3_3( .ifmap_i(ifmap_i_3_3), .filter_i(filter_i_3_3), .index_i(index_i_3_3), 
			.ifmap_o(ifmap_o_3_3), .filter_o(filter_o_3_3), .index_o(index_o_3_3), .psum(psum_11));
PE	PE_3_4( .ifmap_i(ifmap_i_3_4), .filter_i(filter_i_3_4), .index_i(index_i_3_4), 
			.ifmap_o(), .filter_o(filter_o_3_4), .index_o(index_o_3_4), .psum(psum_12));
PE	PE_4_1( .ifmap_i(ifmap_rdata_13), .filter_i(filter_i_4_1), .index_i(index_i_4_1), 
			.ifmap_o(ifmap_o_4_1), .filter_o(), .index_o(), .psum(psum_13));
PE	PE_4_2( .ifmap_i(ifmap_i_4_2), .filter_i(filter_i_4_2), .index_i(index_i_4_2), 
			.ifmap_o(ifmap_o_4_2), .filter_o(), .index_o(), .psum(psum_14));
PE	PE_4_3( .ifmap_i(ifmap_i_4_3), .filter_i(filter_i_4_3), .index_i(index_i_4_3), 
			.ifmap_o(ifmap_o_4_3), .filter_o(), .index_o(), .psum(psum_15));
PE	PE_4_4( .ifmap_i(ifmap_i_4_4), .filter_i(filter_i_4_4), .index_i(index_i_4_4), 
			.ifmap_o(), .filter_o(), .index_o(), .psum(psum_15));
endmodule