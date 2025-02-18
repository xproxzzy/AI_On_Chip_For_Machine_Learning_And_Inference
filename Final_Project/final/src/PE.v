module PE(
	input		[55:0]	ifmap_i,
	input		[23:0]	filter_i,
	input		[3:0]	index_i,
	output	reg	[55:0]	ifmap_o,
	output	reg	[23:0]	filter_o,
	output	reg	[3:0]	index_o,
	output	reg	[17:0]	psum
);
reg	[16:0]	product0;
reg	[16:0]	product1;
reg	[16:0]	product2;
always @(*)
begin
	ifmap_o = ifmap_i;
	filter_o = filter_i;
	index_o = index_i;
end
always @(*)
begin
	case(index_i[1:0])
		2'b00:
		begin
			product0 = $signed({1'b0, ifmap_i[7:0]}) * $signed(filter_i[7:0]);
		end
		2'b01:
		begin
			product0 = $signed({1'b0, ifmap_i[15:8]}) * $signed(filter_i[7:0]);
		end
		2'b10:
		begin
			product0 = $signed({1'b0, ifmap_i[23:16]}) * $signed(filter_i[7:0]);
		end
		default:
		begin
			product0 = 16'd0;
		end
	endcase
end
always @(*)
begin
	product1 = $signed({1'b0, ifmap_i[31:24]}) * $signed(filter_i[15:8]);
end
always @(*)
begin
	case(index_i[3:2])
		2'b00:
		begin
			product2 = $signed({1'b0, ifmap_i[39:32]}) * $signed(filter_i[23:16]);
		end
		2'b01:
		begin
			product2 = $signed({1'b0, ifmap_i[47:40]}) * $signed(filter_i[23:16]);
		end
		2'b10:
		begin
			product2 = $signed({1'b0, ifmap_i[55:48]}) * $signed(filter_i[23:16]);
		end
		default:
		begin
			product2 = 16'd0;
		end
	endcase
end
always @(*)
begin
	psum = product0 + product1 + product2;
end
endmodule