module Accumulator(
	input		clk,
	input		rst,
	input		[17:0]	psum,
	output	reg	[31:0]	result
);
always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
		result <= 32'd0;
	end
	else
	begin
		result <= result + {14'd0, psum};
	end
end
endmodule