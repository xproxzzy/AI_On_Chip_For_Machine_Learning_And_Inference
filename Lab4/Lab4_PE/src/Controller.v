module Controller(
	input clk,
	input rst,
	//Layer setting 
	input set_info,
	input [2:0] Ch_size,
	input [5:0] ifmap_column,
	input [5:0] ofmap_column,
	input [3:0] ifmap_Quant_size,
	input [3:0] filter_Quant_size,
	output reg [3:0] ifmap_Quant_size_store,
	output reg [3:0] filter_Quant_size_store,
	//data to PE.sv
	input filter_enable,
	input ifmap_enable,
	input ipsum_enable,
	input opsum_ready,
	//data from PE.sv
	output reg filter_ready,
	output reg ifmap_ready,
	output reg ipsum_ready,
	output reg opsum_enable,

	output reg [3:0] ifmap_spad_addr,
	output reg ifmap_spad_wen,
	output reg ifmap_spad_ren,
	output reg shift,

	output reg [3:0] filter_spad_addr,
	output reg filter_spad_wen,
	output reg filter_spad_ren,

	output reg psum_spad_wen,
	output reg psum_spad_ren,

	output reg buffer_wen,
	output reg buffer_ren,
	output reg buffer_sel
); 

//parameter [2:0] S0=3'b000, S1=3'b001, S2=3'b010, S3=3'b011, S4=3'b100, S5=3'b101, S6=3'b110, S7=3'b111;
//reg [2:0]	current_state, next_state;
enum logic [2:0]{
	IDLE,
	Get_ifmap,
	Get_filter,
	Read_caculate,
	Store_output,
	Stay
}current_state;
reg [2:0]	next_state;
reg [2:0]	Ch_size_store;
reg [5:0]	ifmap_column_store;
reg [5:0]	ofmap_column_store;
reg [3:0]	ifmap_counter;
reg [3:0]	filter_counter;
reg [5:0]	ifmap_window_counter;
always @ (posedge clk or posedge rst)
begin
	if(rst)
	begin
		Ch_size_store <= 3'd0;
		ifmap_column_store <= 6'd0;
		ofmap_column_store <= 6'd0;
		ifmap_Quant_size_store <= 4'd0;
		filter_Quant_size_store <= 4'd0;
		filter_counter <= 4'd0;
		ifmap_window_counter <= 6'd0;
		current_state <= IDLE;
	end
	else
	begin
		if(set_info)
		begin
			Ch_size_store <= Ch_size;
			ifmap_column_store <= ifmap_column;
			ofmap_column_store <= ofmap_column;
			ifmap_Quant_size_store <= ifmap_Quant_size;
			filter_Quant_size_store <= filter_Quant_size;
		end
		if(current_state==Store_output)
		begin
			if(filter_counter == Ch_size_store*3)
			begin
				filter_counter <= 4'd0;
				if(ifmap_window_counter == (ofmap_column_store - 1'd1))	ifmap_window_counter <= 6'd0;
				else	ifmap_window_counter <= ifmap_window_counter + 6'd1;
			end
			else
			begin
				filter_counter <= filter_counter + 4'd1;
			end
		end
		current_state <= next_state;
	end
end
always @ (*)
begin
    case(current_state)
		IDLE://idle
		begin
			ifmap_ready = 1'b0;
			ifmap_spad_addr = 4'd0;
			ifmap_spad_wen = 1'b0;
			ifmap_spad_ren = 1'b0;
			shift = 1'b0;

			filter_ready = 1'b0;
			filter_spad_addr = 4'd0;
			filter_spad_wen = 1'b0;
			filter_spad_ren = 1'b0;

			ipsum_ready = 1'b0;

			psum_spad_wen = 1'b0;
			psum_spad_ren = 1'b0;

			buffer_wen = 1'b0;
			buffer_ren = 1'b0;
			buffer_sel = 1'b0;

			opsum_enable = 1'b0;

			if(set_info)	next_state = Stay;
			else			next_state = IDLE;
		end
		Get_ifmap://get ifmap
		begin
			if((ifmap_window_counter == 6'd0)&&(filter_counter == 4'd0))
			begin
				ifmap_ready = 1'b1;
				ifmap_spad_addr = 4'd0;
				ifmap_spad_wen = 1'b1;
				ifmap_spad_ren = 1'b0;
			end
			else if((ifmap_window_counter == 6'd0)&&(filter_counter == 4'd1))
			begin
				ifmap_ready = 1'b1;
				ifmap_spad_addr = 4'd4;
				ifmap_spad_wen = 1'b1;
				ifmap_spad_ren = 1'b0;
			end
			else if((ifmap_window_counter == 6'd0)&&(filter_counter == 4'd2))
			begin
				ifmap_ready = 1'b1;
				ifmap_spad_addr = 4'd8;
				ifmap_spad_wen = 1'b1;
				ifmap_spad_ren = 1'b0;
			end
			else if((ifmap_window_counter != 6'd0)&&(filter_counter == 4'd0))
			begin
				ifmap_ready = 1'b1;
				ifmap_spad_addr = 4'd8;
				ifmap_spad_wen = 1'b1;
				ifmap_spad_ren = 1'b0;
			end
			else
			begin
				ifmap_ready = 1'b0;
				ifmap_spad_addr = 4'd0;
				ifmap_spad_wen = 1'b0;
				ifmap_spad_ren = 1'b0;
			end
			shift = 1'b0;

			filter_ready = 1'b0;
			filter_spad_addr = 4'd0;
			filter_spad_wen = 1'b0;
			filter_spad_ren = 1'b0;

			ipsum_ready = 1'b0;

			psum_spad_wen = 1'b0;
			psum_spad_ren = 1'b0;

			buffer_wen = 1'b0;
			buffer_ren = 1'b0;
			buffer_sel = 1'b0;

			opsum_enable = 1'b0;
			
			if(ifmap_ready==1'b0)	next_state = Get_filter;
			else
			begin
				if(ifmap_enable==1'b1)	next_state = Get_filter;
				else					next_state = Get_ifmap;
			end
		end
		Get_filter://get filter
		begin
			ifmap_ready = 1'b0;
			ifmap_spad_addr = 4'd0;
			ifmap_spad_wen = 1'b0;
			ifmap_spad_ren = 1'b0;
			shift = 1'b0;

			if((ifmap_window_counter == 1'b0)&&(filter_counter < Ch_size_store*3))
			begin
				filter_ready = 1'b1;
				filter_spad_addr = filter_counter;
				filter_spad_wen = 1'b1;
				filter_spad_ren = 1'b0;
			end
			else
			begin
				filter_ready = 1'b0;
				filter_spad_addr = 4'd0;
				filter_spad_wen = 1'b0;
				filter_spad_ren = 1'b0;
			end

			ipsum_ready = 1'b0;

			psum_spad_wen = 1'b0;
			psum_spad_ren = 1'b0;

			buffer_wen = 1'b0;
			buffer_ren = 1'b1;
			buffer_sel = 1'b0;

			opsum_enable = 1'b0;

			if(filter_ready==1'b0)	next_state = Read_caculate;
			else
			begin
				if(filter_enable==1'b1)	next_state = Read_caculate;
				else					next_state = Get_filter;
			end
		end
		Read_caculate://read add buffer
		begin
			if(filter_counter == Ch_size_store*3)
			begin
				ifmap_ready = 1'b0;
				ifmap_spad_addr = 4'd0;
				ifmap_spad_wen = 1'b0;
				ifmap_spad_ren = 1'b0;

				filter_ready = 1'b0;
				filter_spad_addr = 4'd0;
				filter_spad_wen = 1'b0;
				filter_spad_ren = 1'b0;

				ipsum_ready = 1'b1;
			end
			else
			begin
				ifmap_ready = 1'b0;
				if(Ch_size_store == 3'd3)
				begin
					case(filter_counter)
					4'd0:		ifmap_spad_addr = 4'd0;
					4'd1:		ifmap_spad_addr = 4'd1;
					4'd2:		ifmap_spad_addr = 4'd2;
					4'd3:		ifmap_spad_addr = 4'd4;
					4'd4:		ifmap_spad_addr = 4'd5;
					4'd5:		ifmap_spad_addr = 4'd6;
					4'd6:		ifmap_spad_addr = 4'd8;
					4'd7:		ifmap_spad_addr = 4'd9;
					4'd8:		ifmap_spad_addr = 4'd10;
					default:	ifmap_spad_addr = filter_counter;
					endcase
				end
				else	ifmap_spad_addr = filter_counter;
				ifmap_spad_wen = 1'b0;
				ifmap_spad_ren = 1'b1;

				filter_ready = 1'b0;
				filter_spad_addr = filter_counter;
				filter_spad_wen = 1'b0;
				filter_spad_ren = 1'b1;

				ipsum_ready = 1'b0;
			end
			shift = 1'b0;

			psum_spad_wen = 1'b0;
			if(filter_counter == 4'd0)	psum_spad_ren = 1'b0;
			else						psum_spad_ren = 1'b1;

			if(filter_counter == Ch_size_store*3)
			begin
				if(ipsum_enable==1'b1)	buffer_wen = 1'b1;
				else					buffer_wen = 1'b0;
			end
			else	buffer_wen = 1'b1;

			buffer_ren = 1'b0;
			buffer_sel = 1'b0;

			opsum_enable = 1'b0;

			if(filter_counter == Ch_size_store*3)
			begin
				if(ipsum_enable==1'b1)	next_state = Store_output;
				else					next_state = Read_caculate;
			end
			else	next_state = Store_output;
		end
		Store_output://store output
		begin
			ifmap_ready = 1'b0;
			ifmap_spad_addr = 4'd0;
			ifmap_spad_wen = 1'b0;
			ifmap_spad_ren = 1'b0;
			if(filter_counter == Ch_size_store*3)	shift = 1'b1;
			else									shift = 1'b0;

			filter_ready = 1'b0;
			filter_spad_addr = 4'd0;
			filter_spad_wen = 1'b0;
			filter_spad_ren = 1'b0;

			ipsum_ready = 1'b0;

			if(filter_counter == Ch_size_store*3)	psum_spad_wen = 1'b0;
			else									psum_spad_wen = 1'b1;
			psum_spad_ren = 1'b0;

			buffer_wen = 1'b0;
			buffer_ren = 1'b1;
			if(filter_counter == Ch_size_store*3)	buffer_sel = 1'b1;
			else									buffer_sel = 1'b0;

			if(filter_counter == Ch_size_store*3)	opsum_enable = 1'b1;
			else									opsum_enable = 1'b0;

			if(filter_counter == Ch_size_store*3)
			begin
				if(opsum_ready==1'b1)	next_state = Stay;
				else					next_state = Store_output;
			end
			else	next_state = Stay;
		end
		Stay:
		begin
			ifmap_ready = 1'b0;
			ifmap_spad_addr = 4'd0;
			ifmap_spad_wen = 1'b0;
			ifmap_spad_ren = 1'b0;
			shift = 1'b0;

			filter_ready = 1'b0;
			filter_spad_addr = 4'd0;
			filter_spad_wen = 1'b0;
			filter_spad_ren = 1'b0;

			ipsum_ready = 1'b0;

			psum_spad_wen = 1'b0;
			psum_spad_ren = 1'b0;

			buffer_wen = 1'b0;
			buffer_ren = 1'b0;
			buffer_sel = 1'b0;

			opsum_enable = 1'b0;

			next_state = Get_ifmap;
		end
		default:
		begin
			ifmap_ready = 1'b0;
			ifmap_spad_addr = 4'd0;
			ifmap_spad_wen = 1'b0;
			ifmap_spad_ren = 1'b0;

			filter_ready = 1'b0;
			filter_spad_addr = 4'd0;
			filter_spad_wen = 1'b0;
			filter_spad_ren = 1'b0;

			ipsum_ready = 1'b0;

			psum_spad_wen = 1'b0;
			psum_spad_ren = 1'b0;

			buffer_wen = 1'b0;
			buffer_ren = 1'b0;
			buffer_sel = 1'b0;

			opsum_enable = 1'b0;

			next_state = IDLE;
		end
	endcase
end
endmodule