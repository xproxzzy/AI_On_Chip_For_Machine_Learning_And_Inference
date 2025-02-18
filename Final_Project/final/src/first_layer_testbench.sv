`timescale 1ns/10ps
`define CYCLE_TIME 10.0
`define MAX_CYCLE  1000000

`include "Top_PE.v"   //design file name

`define first_ifmap_txt "first_layer_input_flatten.txt"
`define first_filter_txt "update_first_layer_weight_flatten.txt"
`define first_filter_index_txt "update_first_layer_weight_index_flatten.txt"

`define first_output_txt "modified_first_layer_output_flatten_all_pos.txt"


`define FIRST
//`define LAST
//`define FC_LAYER


`define ifmap_channel 10'd3	  
`define ifmap_col 10'd34  //padding  32+2  
`define ifmap_row 10'd34  //padding  32+2  
`define filter_row 10'd3	
`define filter_col 10'd3
`define filter_channel 10'd3		
`define filter_number 7'd64	
`define alu_type 1'd0


// `ifdef LAST	 
//    `define input_image     "  "  change to your path
//    `define weight     "  "  change to your path
//    `define golden     "  "  change to your path
// 	`define ifmap_channel 10'd512	  
// 	`define ifmap_col 10'd4  //padding  2+2  
//     `define ifmap_row 10'd4  //padding  2+2  
// 	`define filter_row 10'd3	
//     `define filter_col 10'd3
//     `define filter_channel 10'd3		
//     `define filter_number 7'd64	
//     `define alu_type 1'd0
// `endif


/*
`ifdef FC_LAYER

    `define alu_type 1'd1
`endif 

*/


module testbench ();

integer fd1,fd2,fd3,fd4;


//parameter part 
reg 			clk ;
reg 			rst ;
reg             start ;
reg             config_alu_type;

//config part
/*
reg      [7:0]  config_ifmap_W;
reg      [7:0]  config_ifmap_H;
reg      [10:0] config_ifmap_Ci;
reg      [10:0] config_weight_Co;
*/
reg     [9:0]config_port;

//data part
reg      [23:0] ifmap_data;
reg      [23:0] weight_data;
reg      [3:0]  weight_index;

reg      [5:0] ofmap_col_for_post_unit;


wire           ifmap_rd;
wire           weight_rd;
wire           weight_index__rd;
wire    [16:0] ifmap_address;
wire    [16:0] weight_address;
wire    [16:0] weight_index_address;

wire           write_en;
wire           update;
wire    [31:0] output_data;
wire    [21:0] output_address;
wire           total_done;

logic [31:0] total_cycle ;

// modify there
Top_PE Top_PE(
    .clk(clk),
    .rst(rst),
    .start(start),
    .confi(config_port),
    .ifmap_data(ifmap_data),
    .weight_data(weight_data),
    .index_data(weight_index),
    .ifmap_sram_ren(ifmap_rd),
    .weight_sram_ren(weight_rd),
    .index_sram_ren(weight_index__rd),
    .ifmap_sram_addr(ifmap_address),
    .weight_sram_addr(weight_address),
    .index_sram_addr(weight_index_address),
    .post_unit_wen(write_en),
    .update(updata),
    .data_out(output_data),
    .address(output_address),
    .total_done(total_done)
); 




always  #(`CYCLE_TIME/2) clk = ~clk;   //clk

parameter ST_RESET = 3'd0, ST_SEND_CONFIG = 3'd1, ST_RUN = 3'd2 ,ST_FINISH = 3'd3;
logic [2:0]state ;
logic unsigned [1:0] rst_count;
logic unsigned [4:0] config_counter;
logic [31:0]golden[0:65536];
logic wrong_flag;
logic [16:0]error_number;





initial begin
    state = ST_RESET;
    rst_count = 0;
    clk = 1;
    config_counter = 0;
    error_number = 0;
    total_cycle = 0;
    $timeformat(-9,2," ns",20);
end

ifmap_type_RAM #(.depth(131072)) ifmap_RAM(
  .CK(clk     ), 
  .A (ifmap_address), 
  .WE(1'd0), 
  .OE(ifmap_rd), 
  .D (8'd0 ), 
  .Q (ifmap_data)
);



weight_type_RAM #(.depth(131072)) weight_RAM(
  .CK(clk     ), 
  .A (weight_address), 
  .WE(1'd0), 
  .OE(weight_rd), 
  .D (8'd0 ), 
  .Q (weight_data)
);

weight_index_type_RAM #(.depth(131072)) weight_index_RAM(
  .CK(clk     ), 
  .A (weight_index_address), 
  .WE(1'd0), 
  .OE(weight_index__rd), 
  .D (8'd0 ), 
  .Q (weight_index)
);


initial begin
    fd1 = $fopen(`first_ifmap_txt,"r");
    fd2 = $fopen(`first_filter_txt,"r");
    fd3 = $fopen(`first_filter_index_txt,"r");
    fd4 = $fopen(`first_output_txt,"r");
    if ((fd1 == 0)||(fd2 == 0)||(fd3 == 0)||(fd4 == 0)) begin
            $display ("Failed open .txt");
            $finish;
        end
    else  begin
        $readmemb(`first_ifmap_txt, ifmap_RAM.memory);
        $readmemb(`first_filter_txt, weight_RAM.memory);
        $readmemb(`first_filter_index_txt, weight_index_RAM.memory);
        $readmemb(`first_output_txt, golden);
    end

    $fclose(fd1);
    $fclose(fd2);
    $fclose(fd3);
    $fclose(fd4);
end

always @(posedge clk) begin
  if(wrong_flag)
    error_number <= error_number + 17'd1;
  else
    error_number <= error_number;
end


// corresct ans part
always_comb begin
  if(write_en)  begin
    if(output_data == golden[output_address])  begin
      wrong_flag = 1'd0;
    end
    else  begin
      wrong_flag = 1'd1;
      $display("WRONG !!  address : %d   " , output_address , );
      $display("golden : %d" , $signed(golden[output_address]));
      $display("yours : %d" , $signed(output_data));
    end
  end
  else begin
    wrong_flag = 1'd0;
  end
end



// total clk
always @(posedge clk ) begin
    total_cycle <= total_cycle + 1;
end


always @(posedge clk ) begin
    case(state)
        ST_RESET: begin
            if (rst_count == 2) begin
                #1 rst <= 1'b0;
                rst_count <=0;
                state <=ST_SEND_CONFIG;
				start <= 1;
//$display("RESET");
            end 
            else begin
                #1 rst <= 1'b1;
                rst_count <= rst_count+1;
            end
        end
        ST_SEND_CONFIG:  begin         
            rst <= 1'b0;
            start <= 1'd0;
            case(config_counter)
                5'd0:  begin
                    config_port <= `ifmap_col;  
                end
                5'd1:  begin
                    config_port <= `ifmap_col;    
                end
                5'd2:
                    config_port <= `ifmap_channel;
                5'd3:
                    config_port <= `filter_number;
                5'd4:
                    config_port <= `alu_type;
                default: 
                    config_port <= 6;
            endcase
            if(config_counter == 5'd4)  begin
                state <= ST_RUN;        
            end
            else
                config_counter <= config_counter + 5'd1;
        end
        ST_RUN:  begin
            start <= 0;
            if(total_cycle < `MAX_CYCLE)  begin
              if(total_done)
                state <= ST_FINISH;
              else
                state <= ST_RUN;            
            end
            else
                state <= ST_FINISH; 
        end
        ST_FINISH:  begin
            // $display("-- Max cycle reached.");
            // $display("-- You can modify MAX_CYCLE in testbench if needed.");
            if(error_number == 17'd0)
              $display(" First layer Simulation Pass");
            else  begin
              $display("FAIL  error number : %d" , error_number);
            end
            $display("-- Simulation terminated");
            $display("total clock = %d",total_cycle);
            $finish;
        end
    endcase
end


initial begin
    $fsdbDumpfile("final.fsdb");
    $fsdbDumpvars();
    $fsdbDumpMDA(1, Top_PE);  
    // $fsdbDumpMDA(2,ifmap_RAM);
    // $fsdbDumpMDA(3,weight_RAM);
    // $fsdbDumpMDA(4,weight_index_RAM);
    //$fsdbDumpMDA(5,golden);
end



endmodule

module ifmap_type_RAM #(parameter depth=3468)(CK, A, WE, OE, D, Q);

  input                                  CK;
  input  [$clog2(depth)-1:0]              A;
  input                                  WE;
  input                                  OE;
  input  [7:0]                            D;
  output [23:0]                            Q;         

  reg    [23:0]                            Q;
  reg    [$clog2(depth)-1:0]      latched_A;
  reg    [$clog2(depth)-1:0]  latched_A_neg;
  reg    [7:0] memory           [0 : depth-1];

  always @(*) begin
    if (WE) begin
      memory[A] <= D;
    end
		latched_A <= A;
  end
  
  always@(negedge CK) begin
    latched_A_neg <= latched_A;
  end
  
  always @(*) begin
    if (OE) begin
      Q = {memory[latched_A_neg],memory[latched_A_neg+34],memory[latched_A_neg+68]};
    end
    else begin
      Q = 24'hzz;
    end
  end

endmodule

module weight_type_RAM #(parameter depth=576)(CK, A, WE, OE, D, Q);

  input                                  CK;
  input  [$clog2(depth)-1:0]              A;
  input                                  WE;
  input                                  OE;
  input  [7:0]                            D;
  output [23:0]                            Q;         

  reg    [23:0]                            Q;
  reg    [$clog2(depth)-1:0]      latched_A;
  reg    [$clog2(depth)-1:0]  latched_A_neg;
  reg    [7:0] memory           [0 : depth-1];

  always @(*) begin
    if (WE) begin
      memory[A] <= D;
    end
		latched_A <= A;
  end
  
  always@(negedge CK) begin
    latched_A_neg <= latched_A;
  end
  
  always @(*) begin
    if (OE) begin
      Q = {memory[latched_A_neg],memory[latched_A_neg+1],memory[latched_A_neg+2]};
    end
    else begin
      Q = 24'hzz;
    end
  end

endmodule

module weight_index_type_RAM #(parameter depth=576)(CK, A, WE, OE, D, Q);

  input                                  CK;
  input  [$clog2(depth)-1:0]              A;
  input                                  WE;
  input                                  OE;
  input  [7:0]                            D;
  output [3:0]                            Q;         

  reg    [3:0]                            Q;
  reg    [$clog2(depth)-1:0]      latched_A;
  reg    [$clog2(depth)-1:0]  latched_A_neg;
  reg    [1:0] memory           [0 : depth-1];

  always @(*) begin
    if (WE) begin
      memory[A] <= D;
    end
		latched_A <= A;
  end
  
  always@(negedge CK) begin
    latched_A_neg <= latched_A;
  end
  
  always @(*) begin
    if (OE) begin
      Q = {memory[latched_A_neg],memory[latched_A_neg+2]};
    end
    else begin
      Q = 4'hzz;
    end
  end

endmodule




