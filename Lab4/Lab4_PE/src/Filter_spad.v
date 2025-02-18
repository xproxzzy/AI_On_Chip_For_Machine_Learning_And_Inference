module Filter_spad(
	input				clk,
	input				rst,
	input	[3:0]		addr,
	input				wen,
	input	[7:0]		wdata,
	input				ren,
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
			Register[addr] <= wdata;
		end
	end
end
always @(*)
begin
	if(ren)	rdata = Register[addr];
	else	rdata = 8'd0;
end
endmodule