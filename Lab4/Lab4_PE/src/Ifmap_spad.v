module Ifmap_spad(
	input				clk,
	input				rst,
	input	[3:0]		addr,
	input				wen,
	input	[31:0]		wdata,
	input				ren,
	input				shift,
	output	reg	[7:0]	rdata
);
reg	[7:0] Register [11:0];
always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
		Register[0] <= 8'd0;
		Register[1] <= 8'd0;
		Register[2] <= 8'd0;
		Register[3] <= 8'd0;
		Register[4] <= 8'd0;
		Register[5] <= 8'd0;
		Register[6] <= 8'd0;
		Register[7] <= 8'd0;
		Register[8] <= 8'd0;
		Register[9] <= 8'd0;
		Register[10] <= 8'd0;
		Register[11] <= 8'd0;
	end
	else
	begin
		if(wen)
		begin
			Register[addr] <= wdata[7:0];
			Register[addr + 3'd1] <= wdata[15:8];
			Register[addr + 3'd2] <= wdata[23:16];
			Register[addr + 3'd3] <= wdata[31:24];
		end
		else if(shift)
		begin
			Register[0] <= Register[4];
			Register[1] <= Register[5];
			Register[2] <= Register[6];
			Register[3] <= Register[7];
			Register[4] <= Register[8];
			Register[5] <= Register[9];
			Register[6] <= Register[10];
			Register[7] <= Register[11];
			Register[8] <= 8'd0;
			Register[9] <= 8'd0;
			Register[10] <= 8'd0;
			Register[11] <= 8'd0;
		end
	end
end
always @(*)
begin
	if(ren)	rdata = Register[addr];
	else	rdata = 8'd0;
end
endmodule