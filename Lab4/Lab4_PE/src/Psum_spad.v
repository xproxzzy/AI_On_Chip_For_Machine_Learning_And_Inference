module Psum_spad(
	input				clk,
	input				rst,
	input				wen,
	input	[23:0]		wdata,
	input				ren,
	output	reg	[23:0]	rdata
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
			Register <= wdata;
		end
	end
end
always @(*)
begin
	if(ren)	rdata = Register;
	else	rdata = 24'd0;
end
endmodule