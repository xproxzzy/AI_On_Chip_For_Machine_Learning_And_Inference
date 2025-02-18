  module Controller(
    input           clk,
    input   		rst,
    input           start,
	input 	[9:0]	confi,
    output  reg         fully_connect,
    //sram	
	output	reg	[16:0]	ifmap_sram_addr,
	output	reg	[16:0]	filter_sram_addr,
	output	reg	[16:0]	index_sram_addr,
	output	reg			ifmap_sram_ren,
	output	reg			filter_sram_ren,
	output	reg			index_sram_ren,
	output	reg			post_unit_wen,
    output  reg			update, //call SRAM to renew data
    output  reg	[9:0]  Co, // to post unit
    output	reg	[5:0]  W, // to post unit 
	output	reg	[3:0]	result_sel,
    //buffer
    output	reg	[7:0]	ifmap_buffer_waddr,
    output	reg			ifmap_buffer_wen,
	output	reg	[6:0]	filter_buffer_waddr,
    output	reg			filter_buffer_wen,
	output	reg	[6:0]	index_buffer_waddr,
    output	reg			index_buffer_wen,
    output	reg [7:0]	ifmap_raddr_1, ifmap_raddr_2, ifmap_raddr_3, ifmap_raddr_4,
	output	reg [7:0]	ifmap_raddr_5, ifmap_raddr_6, ifmap_raddr_7, ifmap_raddr_8,
	output	reg [7:0]	ifmap_raddr_9, ifmap_raddr_10, ifmap_raddr_11, ifmap_raddr_12,
	output	reg [7:0]	ifmap_raddr_13, ifmap_raddr_14, ifmap_raddr_15, ifmap_raddr_16,
	output	reg     	ifmap_ren_1, ifmap_ren_2, ifmap_ren_3, ifmap_ren_4,
	output	reg			ifmap_ren_5, ifmap_ren_6, ifmap_ren_7, ifmap_ren_8,
	output	reg		    ifmap_ren_9, ifmap_ren_10, ifmap_ren_11, ifmap_ren_12,
	output	reg			ifmap_ren_13, ifmap_ren_14, ifmap_ren_15, ifmap_ren_16,
	output	reg			ifmap_sel_1_1, ifmap_sel_1_2, ifmap_sel_1_3,
	output	reg			ifmap_sel_2_1, ifmap_sel_2_2, ifmap_sel_2_3,
	output	reg			ifmap_sel_3_1, ifmap_sel_3_2, ifmap_sel_3_3,
	output	reg			ifmap_sel_4_1, ifmap_sel_4_2, ifmap_sel_4_3,
    output  reg [6:0]	filter_raddr_1, filter_raddr_2, filter_raddr_3, filter_raddr_4,
	output	reg	[6:0]	filter_raddr_5, filter_raddr_6, filter_raddr_7, filter_raddr_8,
	output	reg	[6:0]	filter_raddr_9, filter_raddr_10, filter_raddr_11, filter_raddr_12,
	output	reg	[6:0]	filter_raddr_13, filter_raddr_14, filter_raddr_15, filter_raddr_16,
	output	reg			filter_ren_1, filter_ren_2, filter_ren_3, filter_ren_4,
	output	reg			filter_ren_5, filter_ren_6, filter_ren_7, filter_ren_8,
	output	reg			filter_ren_9, filter_ren_10, filter_ren_11, filter_ren_12,
	output	reg 		filter_ren_13, filter_ren_14, filter_ren_15, filter_ren_16,
	output	reg			filter_sel_1_1, filter_sel_1_2, filter_sel_1_3, filter_sel_1_4,
	output	reg			filter_sel_2_1, filter_sel_2_2, filter_sel_2_3, filter_sel_2_4,
	output	reg			filter_sel_3_1, filter_sel_3_2, filter_sel_3_3, filter_sel_3_4,
    output	reg	[6:0]	index_raddr_1, index_raddr_2, index_raddr_3, index_raddr_4,
	output	reg			index_ren_1, index_ren_2, index_ren_3, index_ren_4,
	output	reg			index_sel_1_1, index_sel_1_2, index_sel_1_3, index_sel_1_4,
	output	reg			index_sel_2_1, index_sel_2_2, index_sel_2_3, index_sel_2_4,
	output	reg			index_sel_3_1, index_sel_3_2, index_sel_3_3, index_sel_3_4
    
);

//State     
parameter   IDLE=5'd0, GET_H=5'd1, GET_W=5'd2, GET_Ci=5'd3, GET_Co=5'd4, GET_N = 5'd5;
parameter   GET_fully_connect=5'd6, GET_SRAM=5'd7,  PE_WORK=5'd8, OUTPUT=5'd9;

reg [4:0]   State, NextState;

//reg for config
reg [15:0]  H, Ci, N;

//reg for SENT_ADDRESS state
reg			is_buffer_fix_channel;
reg			is_width_smaller_than_6;
reg [2:0]	ifmap_counter_6;
reg [8:0]	ifmap_ch;
reg [8:0]	ifmap_col;
reg [8:0]	ifmap_row;
reg 		ifmap_buffer_full;
reg [1:0]	filter_counter_4;
reg [8:0]	filter_ch;
reg [8:0]	filter_num;
reg 		filter_buffer_full;
reg			filter_buffer_fix_channel;


reg         abc;


//reg for PE_WORK state
reg [8:0]	PE1_ch_count,PE2_ch_count,PE3_ch_count,PE4_ch_count,PE_ch_count; //count PE done ch
reg [2:0] 	clk_count; //for dataflow
reg [3:0]   buffer_store_n, buffer_store_n_next;
reg [3:0]   output_n;

//reg for OUTPUT state
reg [3:0]   output_counter;


//rst test
always @(posedge clk or posedge rst)  begin
    if(rst)
        abc <= 1'd1;
    else
        abc <= 1'd0;
end

always @ (posedge clk or posedge rst)  begin
    if(rst) begin
        State <= IDLE;
        ifmap_counter_6 <= 3'd0;
        ifmap_ch <= 9'd0;
        ifmap_col <= 9'd0;
        ifmap_row <= 9'd0;
        ifmap_buffer_waddr <= 8'd0;
        filter_counter_4 <= 2'd0;
        filter_ch <= 9'd0;
        filter_num <= 9'd0;
        filter_buffer_waddr <= 8'd0;
        output_counter <=8'd0;
        ifmap_ren_1<=1'b0;
        ifmap_ren_5<=1'b0;
        ifmap_ren_9<=1'b0;
        ifmap_ren_13<=1'b0;
        clk_count <= 2'd0;
        index_raddr_1 <= 0;
        index_raddr_2 <= 0;
        index_raddr_3 <= 0;
        index_raddr_4 <= 0;
        filter_raddr_1 <= 0;
        filter_raddr_2 <= 0;
        filter_raddr_3 <= 0;
        filter_raddr_4 <= 0;
        PE1_ch_count <= 0;
        PE2_ch_count <=0;
        PE3_ch_count <=0;
        PE4_ch_count <=0;
        output_n <=0;
        buffer_store_n <= 0;
    end
    else
    begin
        State <= NextState;
        buffer_store_n <= buffer_store_n_next;
		case(State)
			GET_H:	H <= confi;
			GET_W:	W <= confi;
			GET_Ci:	Ci <= confi;
			GET_Co:	Co <= confi;
			GET_N:	N <= confi;
			GET_fully_connect:	fully_connect <= confi;
			GET_SRAM:
			begin
				if(fully_connect==1'b0) //convolution
				begin
                    if(ifmap_sram_ren==1'b1)
                    begin
                        if(is_width_smaller_than_6==1'b1)
                        begin
                            if(ifmap_counter_6==(W-9'b1))
                            begin
                                ifmap_counter_6 <= 3'd0;
                                if(ifmap_ch==(Ci-1))
                                begin
                                    ifmap_ch <= 9'd0;
                                    if(ifmap_col>(W-9'd7))
                                    begin
                                        ifmap_col <= 9'd0;
                                        if(ifmap_row>(H-9'd2))
                                        begin
                                            ifmap_row <= 9'd0;
                                        end
                                        else
                                        begin
                                            ifmap_row <= ifmap_row + 9'd1;
                                        end
                                    end
                                    else
                                    begin
                                        buffer_store_n <= buffer_store_n + 4'b1;
                                        ifmap_col <= ifmap_col + 9'd4;
                                    end
                                end
                                else
                                begin
                                    ifmap_ch <= ifmap_ch + 9'd1;
                                end
                            end
                            else
                            begin
                                ifmap_counter_6 <= ifmap_counter_6 + 3'd1;
                            end
                            if(ifmap_buffer_full==1'b1)	ifmap_buffer_waddr <= 8'd0;
                            else
                            begin
                                if(ifmap_counter_6==(W-9'b1))	ifmap_buffer_waddr <= ifmap_buffer_waddr + (6-W);
                                else							ifmap_buffer_waddr <= ifmap_buffer_waddr + 8'd1;
                            end
                        end
                        else
                        begin
                            if(ifmap_counter_6==3'd5)
                            begin
                                ifmap_counter_6 <= 3'd0;
                                if(ifmap_ch==(Ci-1))
                                begin
                                    ifmap_ch <= 9'd0;
                                    if(ifmap_col>(W-9'd7))
                                    begin
                                        ifmap_col <= 9'd0;
                                        if(ifmap_row>(H-9'd2))
                                        begin
                                            ifmap_row <= 9'd0;
                                        end
                                        else
                                        begin
                                            ifmap_row <= ifmap_row + 9'd1;
                                        end
                                    end
                                    else
                                    begin
                                        buffer_store_n <= buffer_store_n + 4'b1;
                                        ifmap_col <= ifmap_col + 9'd4;
                                    end
                                end
                                else
                                begin
                                    ifmap_ch <= ifmap_ch + 9'd1;
                                end
                            end
                            else
                            begin
                                ifmap_counter_6 <= ifmap_counter_6 + 3'd1;
                            end
                            if(ifmap_buffer_full==1'b1)	ifmap_buffer_waddr <= 8'd0;
                            else						ifmap_buffer_waddr <= ifmap_buffer_waddr + 8'd1;
                        end
                    end

                    if(filter_sram_ren==1'b1)
                    begin
                        if(filter_counter_4==2'd3)
                        begin
                            filter_counter_4 = 2'd0;
                            if(filter_ch==(Ci-1))
                            begin
                                filter_ch <= 9'd0;
                                if(filter_num==Co)
                                begin
                                    filter_num <= 9'd0;
                                end
                                else
                                begin
                                    filter_num <= filter_num + 9'd4;
                                end
                            end
                            else
                            begin
                                filter_ch <= filter_ch + 9'd1;
                            end
                        end
                        else
                        begin
                            filter_counter_4 <= filter_counter_4 + 2'b1;
                        end
                        if(filter_buffer_full)	filter_buffer_waddr <= (ifmap_buffer_full)?8'd0:filter_buffer_waddr;
                        else							filter_buffer_waddr <= filter_buffer_waddr + 8'd1;
                    end
				end
				else //fully connect
				begin
					if(ifmap_buffer_full==1'b1)		ifmap_buffer_waddr <= 8'd0;
					else							ifmap_buffer_waddr <= ifmap_buffer_waddr + 8'd1;
					if(filter_buffer_full==1'b1)	filter_buffer_waddr <= 8'd0;
					else							filter_buffer_waddr <= filter_buffer_waddr + 8'd1;
				end
				ifmap_buffer_wen <= ifmap_sram_ren;
				filter_buffer_wen <= filter_sram_ren;
				index_buffer_wen <= index_sram_ren;
			end

            PE_WORK:begin
                //FC addr
                if(fully_connect)begin
                    //ifmap
                    if(ifmap_ren_1) ifmap_raddr_1 = PE_ch_count;
                    if(ifmap_ren_2) ifmap_raddr_2 = PE_ch_count;
                    if(ifmap_ren_3) ifmap_raddr_3 = PE_ch_count;
                    if(ifmap_ren_4) ifmap_raddr_4 = PE_ch_count;
                    if(ifmap_ren_5) ifmap_raddr_5 = PE_ch_count;
                    if(ifmap_ren_6) ifmap_raddr_6 = PE_ch_count;
                    if(ifmap_ren_7) ifmap_raddr_7 = PE_ch_count;
                    if(ifmap_ren_8) ifmap_raddr_8 = PE_ch_count;
                    if(ifmap_ren_9) ifmap_raddr_9 = PE_ch_count;
                    if(ifmap_ren_10) ifmap_raddr_10 = PE_ch_count;
                    if(ifmap_ren_11) ifmap_raddr_11 = PE_ch_count;
                    if(ifmap_ren_12) ifmap_raddr_12 = PE_ch_count;
                    if(ifmap_ren_13) ifmap_raddr_13 = PE_ch_count;
                    if(ifmap_ren_14) ifmap_raddr_14 = PE_ch_count;
                    if(ifmap_ren_15) ifmap_raddr_15 = PE_ch_count;
                    if(ifmap_ren_16) ifmap_raddr_16 = PE_ch_count;

                    //filter
                    if(filter_ren_1) filter_raddr_1 = Co*PE_ch_count + 8'd0;
                    if(filter_ren_2) filter_raddr_2 = Co*PE_ch_count + 8'd1;
                    if(filter_ren_3) filter_raddr_3 = Co*PE_ch_count + 8'd2;
                    if(filter_ren_4) filter_raddr_4 = Co*PE_ch_count + 8'd3;
                    if(filter_ren_5) filter_raddr_5 = Co*PE_ch_count + 8'd4;
                    if(filter_ren_6) filter_raddr_6 = Co*PE_ch_count + 8'd5;
                    if(filter_ren_7) filter_raddr_7 = Co*PE_ch_count + 8'd6;
                    if(filter_ren_8) filter_raddr_8 = Co*PE_ch_count + 8'd7;
                    if(filter_ren_9) filter_raddr_9 = Co*PE_ch_count + 8'd8;
                    if(filter_ren_10) filter_raddr_10 = Co*PE_ch_count + 8'd9;
                    if(filter_ren_11) filter_raddr_11 = Co*PE_ch_count + 8'd10;
                    if(filter_ren_12) filter_raddr_12 = Co*PE_ch_count + 8'd11;
                    if(filter_ren_13) filter_raddr_13 = Co*PE_ch_count + 8'd12;
                    if(filter_ren_14) filter_raddr_14 = Co*PE_ch_count + 8'd13;
                    if(filter_ren_15) filter_raddr_15 = Co*PE_ch_count + 8'd14;
                    if(filter_ren_16) filter_raddr_16 = Co*PE_ch_count + 8'd15;

                    PE_ch_count = PE_ch_count + 1;

                end

                //Conv
                else begin
                    if(ifmap_ren_1) ifmap_raddr_1 = output_n*6*Ci + 6*PE1_ch_count + 8'd0;
                    if(ifmap_ren_5) ifmap_raddr_5 = output_n*6*Ci + 6*PE2_ch_count + 8'd1;
                    if(ifmap_ren_9) ifmap_raddr_9 = output_n*6*Ci + 6*PE3_ch_count + 8'd2;
                    if(ifmap_ren_13) ifmap_raddr_13 = output_n*6*Ci + 6*PE4_ch_count + 8'd3;

                    if(filter_ren_1) filter_raddr_1 <= output_n*4*Ci + 4*PE1_ch_count + 8'd0;
                    if(filter_ren_2) filter_raddr_2 <= output_n*4*Ci + 4*PE2_ch_count + 8'd1;
                    if(filter_ren_3) filter_raddr_3 <= output_n*4*Ci + 4*PE3_ch_count + 8'd2;
                    if(filter_ren_4) filter_raddr_4 <= output_n*4*Ci + 4*PE4_ch_count + 8'd3;

                    if(index_ren_1) index_raddr_1 <= output_n*4*Ci + 4*PE1_ch_count + 8'd0;
                    if(index_ren_2) index_raddr_2 <= output_n*4*Ci + 4*PE2_ch_count + 8'd1;
                    if(index_ren_3) index_raddr_3 <= output_n*4*Ci + 4*PE3_ch_count + 8'd2;
                    if(index_ren_4) index_raddr_4 <= output_n*4*Ci + 4*PE4_ch_count + 8'd3;

                    PE1_ch_count <= (ifmap_ren_1)? PE1_ch_count+1 : PE1_ch_count;
                    PE2_ch_count <= (ifmap_ren_5)? PE2_ch_count+1 : PE2_ch_count;
                    PE3_ch_count <= (ifmap_ren_9)? PE3_ch_count+1 : PE3_ch_count;
                    PE4_ch_count <= (ifmap_ren_13)? PE4_ch_count+1 : PE4_ch_count;

                    if(ifmap_ren_1==1'b0 && ifmap_ren_5==1'b0 && ifmap_ren_9==1'b0 && ifmap_ren_13==1'b0) output_n<=output_n+1;
                    clk_count = (clk_count == 2'd3)? 2'd3 : clk_count+1;
                end

            end

            OUTPUT: 
            begin
                output_counter = output_counter + 1;
                if(!fully_connect && output_counter == 4'd15 ) begin
                    ifmap_buffer_waddr <= 0;
                end

            end
			default:
            begin
            end
		endcase
    end
end
always @ (*)
begin
    case(State)
    GET_SRAM:
	begin
        post_unit_wen=1'b0;
		if(fully_connect==1'b0)
		begin
			if(Ci>32)							is_buffer_fix_channel = 1'b0;
			else								is_buffer_fix_channel = 1'b1;
			if(W<6)								is_width_smaller_than_6 = 1'b1;
			else								is_width_smaller_than_6 = 1'b0;
			if((191-ifmap_buffer_waddr)<(6*Ci))	ifmap_buffer_full = 1'b1;
			else								ifmap_buffer_full = 1'b0;
			ifmap_sram_ren = ~ifmap_buffer_full;
			if(((127-filter_buffer_waddr)<(4*Ci))&&(filter_ch==9'd0)&&(filter_counter_4==2'd0))	filter_buffer_full = 1'b1;
			else								filter_buffer_full = 1'b0;
			filter_sram_ren = ~filter_buffer_full;
			index_sram_ren = ~filter_buffer_full;
			ifmap_sram_addr = W*ifmap_row + ifmap_col + H*W*ifmap_ch + ifmap_counter_6;
			filter_sram_addr = Ci*filter_counter_4 + filter_ch + Ci*4*filter_num;
			index_sram_addr = Ci*filter_counter_4 + filter_ch + Ci*4*filter_num;
			index_buffer_waddr = filter_buffer_waddr;
		end
		else
		begin
			if(ifmap_buffer_waddr==191)		ifmap_buffer_full = 1'b1;
			else							ifmap_buffer_full = 1'b0;
			ifmap_sram_ren = ~ifmap_buffer_full;
			if(filter_buffer_waddr==127)	filter_buffer_full = 1'b1;
			else							filter_buffer_full = 1'b0;
			filter_sram_ren = ~filter_buffer_full;
			index_sram_ren = 1'b0;
			ifmap_sram_addr = ifmap_buffer_waddr*3;
			filter_sram_addr = filter_buffer_waddr*3;
			index_sram_addr = index_buffer_waddr*3;
			index_buffer_waddr = 7'd0;
		end
	end
    PE_WORK:
	begin
    post_unit_wen=1'b0;
    //FC
    if(fully_connect)begin
        //ifmap
        ifmap_ren_1 = (Co<9'd1)?1'b0 : 1'b1;
        ifmap_ren_2 = (Co<9'd2)?1'b0 : 1'b1;
        ifmap_ren_3 = (Co<9'd3)?1'b0 : 1'b1;
        ifmap_ren_4 = (Co<9'd4)?1'b0 : 1'b1;
        ifmap_ren_5 = (Co<9'd5)?1'b0 : 1'b1;
        ifmap_ren_6 = (Co<9'd6)?1'b0 : 1'b1;
        ifmap_ren_7 = (Co<9'd7)?1'b0 : 1'b1;
        ifmap_ren_8 = (Co<9'd8)?1'b0 : 1'b1;
        ifmap_ren_9 = (Co<9'd9)?1'b0 : 1'b1;
        ifmap_ren_10 = (Co<9'd10)?1'b0 : 1'b1;
        ifmap_ren_11 = (Co<9'd11)?1'b0 : 1'b1;
        ifmap_ren_12 = (Co<9'd12)?1'b0 : 1'b1;
        ifmap_ren_13 = (Co<9'd13)?1'b0 : 1'b1;
        ifmap_ren_14 = (Co<9'd14)?1'b0 : 1'b1;
        ifmap_ren_15 = (Co<9'd15)?1'b0 : 1'b1;
        ifmap_ren_16 = (Co<9'd16)?1'b0 : 1'b1;

        ifmap_sel_1_1 = 1'b0;
        ifmap_sel_1_2 = 1'b0;
        ifmap_sel_1_3 = 1'b0;
        ifmap_sel_2_1 = 1'b0;
        ifmap_sel_2_2 = 1'b0;
        ifmap_sel_2_3 = 1'b0;
        ifmap_sel_3_1 = 1'b0;
        ifmap_sel_3_2 = 1'b0;
        ifmap_sel_3_3 = 1'b0;
        ifmap_sel_4_1 = 1'b0;
        ifmap_sel_4_2 = 1'b0;
        ifmap_sel_4_3 = 1'b0;

        //filter
        filter_ren_1 = (Co<9'd1)?1'b0 : 1'b1;
        filter_ren_2 = (Co<9'd2)?1'b0 : 1'b1;
        filter_ren_3 = (Co<9'd3)?1'b0 : 1'b1;
        filter_ren_4 = (Co<9'd4)?1'b0 : 1'b1;
        filter_ren_5 = (Co<9'd5)?1'b0 : 1'b1;
        filter_ren_6 = (Co<9'd6)?1'b0 : 1'b1;
        filter_ren_7 = (Co<9'd7)?1'b0 : 1'b1;
        filter_ren_8 = (Co<9'd8)?1'b0 : 1'b1;
        filter_ren_9 = (Co<9'd9)?1'b0 : 1'b1;
        filter_ren_10 = (Co<9'd10)?1'b0 : 1'b1;
        filter_ren_11 = (Co<9'd11)?1'b0 : 1'b1;
        filter_ren_12 = (Co<9'd12)?1'b0 : 1'b1;
        filter_ren_13 = (Co<9'd13)?1'b0 : 1'b1;
        filter_ren_14 = (Co<9'd14)?1'b0 : 1'b1;
        filter_ren_15 = (Co<9'd15)?1'b0 : 1'b1;
        filter_ren_16 = (Co<9'd16)?1'b0 : 1'b1;

        filter_sel_1_1 = 1'b0;
        filter_sel_1_2 = 1'b0;
        filter_sel_1_3 = 1'b0;
        filter_sel_1_4 = 1'b0;
        filter_sel_2_1 = 1'b0;
        filter_sel_2_2 = 1'b0;
        filter_sel_2_3 = 1'b0;
        filter_sel_2_4 = 1'b0;
        filter_sel_3_1 = 1'b0;
        filter_sel_3_2 = 1'b0;
        filter_sel_3_3 = 1'b0;
        filter_sel_3_4 = 1'b0;

        //index
        index_ren_1 = filter_ren_1;
        index_ren_2 = filter_ren_2;
        index_ren_3 = filter_ren_3;
        index_ren_4 = filter_ren_4;

        index_sel_1_1 = 1'b0;
        index_sel_1_2 = 1'b0;
        index_sel_1_3 = 1'b0;
        index_sel_1_4 = 1'b0;
        index_sel_2_1 = 1'b0;
        index_sel_2_2 = 1'b0;
        index_sel_2_3 = 1'b0;
        index_sel_2_4 = 1'b0;
        index_sel_3_1 = 1'b0;
        index_sel_3_2 = 1'b0;
        index_sel_3_3 = 1'b0;
        index_sel_3_4 = 1'b0;

    end

    //Conv
    else begin
    //ifmap   
        ifmap_ren_2 = 1'b0;
        ifmap_ren_3 = 1'b0;
        ifmap_ren_4 = 1'b0;
        ifmap_ren_6 = 1'b0;
        ifmap_ren_7 = 1'b0;
        ifmap_ren_8 = 1'b0;
        ifmap_ren_10 = 1'b0;
        ifmap_ren_11 = 1'b0;
        ifmap_ren_12 = 1'b0;
        ifmap_ren_14 = 1'b0;
        ifmap_ren_15 = 1'b0;
        ifmap_ren_16 = 1'b0;

        ifmap_sel_1_1 = 1'b1;
        ifmap_sel_1_2 = 1'b1;
        ifmap_sel_1_3 = 1'b1;
        ifmap_sel_2_1 = 1'b1;
        ifmap_sel_2_2 = 1'b1;
        ifmap_sel_2_3 = 1'b1;
        ifmap_sel_3_1 = 1'b1;
        ifmap_sel_3_2 = 1'b1;
        ifmap_sel_3_3 = 1'b1;
        ifmap_sel_4_1 = 1'b1;
        ifmap_sel_4_2 = 1'b1;
        ifmap_sel_4_3 = 1'b1;

    //filter 
        filter_ren_5 = 1'b0;
        filter_ren_6 = 1'b0;
        filter_ren_7 = 1'b0;
        filter_ren_8 = 1'b0;
        filter_ren_9 = 1'b0;
        filter_ren_10 = 1'b0;
        filter_ren_11 = 1'b0;
        filter_ren_12 = 1'b0;
        filter_ren_13 = 1'b0;
        filter_ren_14 = 1'b0;
        filter_ren_15 = 1'b0;
        filter_ren_16 = 1'b0;

        filter_sel_1_1 = 1'b1;
        filter_sel_1_2 = 1'b1;
        filter_sel_1_3 = 1'b1;
        filter_sel_1_4 = 1'b1;
        filter_sel_2_1 = 1'b1;
        filter_sel_2_2 = 1'b1;
        filter_sel_2_3 = 1'b1;
        filter_sel_2_4 = 1'b1;
        filter_sel_3_1 = 1'b1;
        filter_sel_3_2 = 1'b1;
        filter_sel_3_3 = 1'b1;
        filter_sel_3_4 = 1'b1;
    //index
        index_ren_1 = filter_ren_1;
        index_ren_2 = filter_ren_2;
        index_ren_3 = filter_ren_3;
        index_ren_4 = filter_ren_4;

        index_sel_1_1 = 1'b1;
        index_sel_1_2 = 1'b1;
        index_sel_1_3 = 1'b1;
        index_sel_1_4 = 1'b1;
        index_sel_2_1 = 1'b1;
        index_sel_2_2 = 1'b1;
        index_sel_2_3 = 1'b1;
        index_sel_2_4 = 1'b1;
        index_sel_3_1 = 1'b1;
        index_sel_3_2 = 1'b1;
        index_sel_3_3 = 1'b1;
        index_sel_3_4 = 1'b1;
    //dataflow 
		case (clk_count)
			2'd0: 
			begin
                ifmap_ren_1 = 1'b1;
                ifmap_ren_5 = 1'b0;
                ifmap_ren_9 = 1'b0;
                ifmap_ren_13 = 1'b0;

                filter_ren_1 = 1'b1;
                filter_ren_2 = 1'b0;
                filter_ren_3 = 1'b0;
                filter_ren_4 = 1'b0;

			end
			2'd1:
			begin
                ifmap_ren_1 = (PE1_ch_count == Ci)?1'b0:1'b1;
                ifmap_ren_5 = 1'b1;
                ifmap_ren_9 = 1'b0;
                ifmap_ren_13 = 1'b0;

                filter_ren_1 = (PE1_ch_count == Ci)?1'b0:1'b1;
                filter_ren_2 = 1'b1;
                filter_ren_3 = 1'b0;
                filter_ren_4 = 1'b0;
			end
			2'd2:
			begin
                ifmap_ren_1 = (PE1_ch_count == Ci)?1'b0:1'b1;
                ifmap_ren_5 = (PE2_ch_count == Ci)?1'b0:1'b1;
                ifmap_ren_9 = 1'b1;
                ifmap_ren_13 = 1'b0;

                filter_ren_1 = (PE1_ch_count == Ci)?1'b0:1'b1;
                filter_ren_2 = (PE2_ch_count == Ci)?1'b0:1'b1;
                filter_ren_3 = 1'b1;
                filter_ren_4 = 1'b0;
			end
			2'd3:
			begin
                ifmap_ren_1 = (PE1_ch_count == Ci)?1'b0:1'b1;
                ifmap_ren_5 = (PE2_ch_count == Ci)?1'b0:1'b1;
                ifmap_ren_9 = (PE3_ch_count == Ci)?1'b0:1'b1;
                ifmap_ren_13 =(PE4_ch_count == Ci)?1'b0:1'b1;

                filter_ren_1 = (PE1_ch_count == Ci)?1'b0:1'b1;
                filter_ren_2 = (PE2_ch_count == Ci)?1'b0:1'b1;
                filter_ren_3 = (PE3_ch_count == Ci)?1'b0:1'b1;
                filter_ren_4 = (PE4_ch_count == Ci)?1'b0:1'b1;
            end
			default:
            begin
            end
		endcase
    end
    end
    OUTPUT: 
    begin
        result_sel = output_counter;
        post_unit_wen=1'b1;
        clk_count=2'd0;
        PE1_ch_count=0;
        PE2_ch_count=0;
        PE3_ch_count=0;
        PE4_ch_count=0;
        
    end


    endcase


end
always @ (*) 
begin
    buffer_store_n_next = buffer_store_n;
    case (State)
    IDLE:
	begin
    	if(start)	NextState = GET_H;
    	else		NextState = IDLE;
    end
    GET_H:
	begin
        NextState = GET_W;
    end
    GET_W:
	begin
        NextState = GET_Ci;
    end
    GET_Ci:
	begin
        NextState = GET_Co;
    end
    GET_Co:
	begin
        NextState = GET_N;
    end
    GET_N:
	begin
        NextState = GET_fully_connect;
    end
    GET_fully_connect:
	begin
        NextState = GET_SRAM;
    end
    GET_SRAM:
	begin
        if((ifmap_sram_ren==0)&&(filter_sram_ren==0))	NextState = PE_WORK;
        else									NextState = GET_SRAM;
    end
    PE_WORK:
    begin
        if(fully_connect)begin
           if(PE_ch_count == ifmap_ch)begin
                if(ifmap_ch == Ci)NextState=OUTPUT;
                else
                begin
                    buffer_store_n_next = 4'd0;
                    NextState=GET_SRAM;
                end
           end
           else                              NextState=PE_WORK;
        end
        else begin
            if(ifmap_ren_1==1'b0 && ifmap_ren_5==1'b0 && ifmap_ren_9==1'b0 && ifmap_ren_13==1'b0 && clk_count==2'd3) NextState = OUTPUT;
            else                                                                                NextState = PE_WORK;
        end
    end
    OUTPUT:
	begin
        
            if(fully_connect)begin
                if(output_counter == Co)begin
                    if(ifmap_ch == Ci)NextState = IDLE;
                    else     begin                
                        NextState = GET_SRAM;
                        buffer_store_n_next = 4'd0;  
                    end
                end
                else NextState=OUTPUT;
            end
            else begin
                if(output_counter == 4'd15 )begin
                    if(output_n == buffer_store_n) begin 
                        NextState = GET_SRAM;
                        buffer_store_n_next = 4'd0;
                    end
                    else                           NextState = PE_WORK;
                end
                else  NextState=OUTPUT;
            end

    end
    endcase
end
endmodule