module post_unit (clk,rst,alu_type,data_in,enable,data_out,address,col_size,channel_size,total_done);
input [31:0]data_in;
input clk,rst,enable,alu_type;
input [5:0]col_size;
input [9:0]channel_size;  // connect how many filters
output logic [31:0]data_out;
output logic [21:0]address;
output logic total_done;

//assume ofmap channel finish once for channel



logic [5:0]col_size_no_padding;
logic [7:0]channel_round;
logic [3:0]row_round;

logic [4:0]once_output_counter;
logic [5:0]col_counter;
logic [3:0]row_round_counter;
logic [5:0]col_round;
logic [7:0]channel_counter;   //  total / 4
logic [21:0]address_channel_temp_base;
logic [21:0]address_col_temp_base;

assign col_round = col_size_no_padding;
assign col_size_no_padding = col_size - 2;
assign row_round = col_size_no_padding[5:2];
assign channel_round = channel_size[9:2];


assign data_out = (data_in[31]) ? (32'd0) : (data_in);  //relu

// output once part  16 element
always @(posedge clk or posedge rst) begin
    if(rst)
        once_output_counter <= 5'd0;
    else  begin
        if(alu_type == 1'd0)  begin    //conv
            if(col_size_no_padding < 4)  begin
                if(once_output_counter == ((col_size_no_padding * 4) - 1))
                    once_output_counter <= 5'd0;
                else  begin
                    if(enable)
                        once_output_counter <= once_output_counter + 5'd1;
                    else
                        once_output_counter <= 5'd0;
                end
            end
            else  begin
                if(once_output_counter == 5'd15)
                    once_output_counter <= 5'd0;
                else  begin
                    if(enable)
                        once_output_counter <= once_output_counter + 5'd1;
                    else
                        once_output_counter <= 5'd0; 
                end    
            end
            
        end
        else  begin   //fc layer
            
        end
    end
end

//output row record part
always @(posedge clk or posedge rst) begin
    if(rst)
        row_round_counter <= 4'd0;
    else  begin
        if(alu_type == 1'd0)  begin  //conv
            if(col_size_no_padding < 4)  begin
                row_round_counter <= 4'd0;
            end
            else  begin
                if(once_output_counter == 5'd15)  begin
                    if(row_round_counter == (row_round - 1))
                        row_round_counter <= 4'd0;
                    else
                        row_round_counter <= row_round_counter + 4'd1;
                end
                else  begin
                    row_round_counter <= row_round_counter;
                end    
            end
        end
        else  begin  //fc layer
            
        end
    end    
end

//output col record part 
always @(posedge clk or posedge rst) begin
    if(rst)
        col_counter <= 6'd0;
    else  begin
        if(alu_type == 1'd0)  begin  //conv
            if(col_size_no_padding < 4)  begin
                if(once_output_counter == ((col_size_no_padding * 4)-1))  begin
                    if(col_counter == (col_size_no_padding - 1))
                        col_counter <= 6'd0;
                    else
                        col_counter <= col_counter + 6'd1;
                end
                else
                    col_counter <= col_counter;
            end
            else  begin
                if((once_output_counter == 5'd15)&&(row_round_counter == (row_round - 1)))  begin
                    if(col_counter == (col_round - 1))
                        col_counter <= 6'd0;
                    else
                        col_counter <= col_counter + 6'd1;
                end
                else  begin
                    col_counter <= col_counter;
                end    
            end
        end
        else  begin  //fc layer   
        end
    end
end

always @(posedge clk or posedge rst) begin
    if(rst)
        channel_counter <= 8'd0;
    else  begin
        if(alu_type == 1'd0)  begin   //conv
            if(col_size_no_padding < 4)  begin
                if((once_output_counter == ((col_size_no_padding * 4) - 1))&&(col_counter == (col_round-1)))  begin
                    channel_counter <= channel_counter + 8'd1;
                end
                else  begin
                    channel_counter <= channel_counter;
                end   
            end
            else  begin
                if((once_output_counter == 5'd15)&&(row_round_counter == (row_round-1))&&(col_counter == (col_round-1)))  begin
                    channel_counter <= channel_counter + 8'd1;
                end
                else  begin
                    channel_counter <= channel_counter;
                end    
            end
            
        end
        else  begin   //fc layer

        end
    end
end

always @(*) begin
    if(alu_type == 1'd0)  begin  //conv
        if(col_size_no_padding < 4)  begin
            if((once_output_counter == ((col_size_no_padding * 4) - 1)) && (col_counter == (col_round - 1)) && (channel_counter == (channel_round - 1)))
                total_done = 1'd1;
            else
                total_done = 1'd0; 
        end
        else  begin
                if((once_output_counter == 5'd15)&&(row_round_counter == row_round)&&(col_counter == col_round)&&(channel_counter == channel_round - 1))
                    total_done = 1'd1;
                else
                    total_done = 1'd0;        
        end
    
    end
    else  begin  //fc layer
        
    end
end

assign address_channel_temp_base = channel_counter * col_size_no_padding * col_size_no_padding;
assign address_col_temp_base = col_counter * col_size_no_padding;

// always_comb begin
//     if(col_size_no_padding < 4)  begin  //in ofmap first finish upper ofmap ,then finish lower ,and then go in channel
//         address = address_channel_temp_base + address_col_temp_base + once_output_counter[1:0] * col_size_no_padding * col_size_no_padding + once_output_counter[3:2] ;
//     end
//     else  begin
//         address = address_channel_temp_base + address_col_temp_base + once_output_counter[1:0] * col_size_no_padding * col_size_no_padding + once_output_counter[3:2] ;
//     end
// end

assign address = address_channel_temp_base + address_col_temp_base + once_output_counter[1:0] * col_size_no_padding * col_size_no_padding + once_output_counter[3:2] ;

endmodule