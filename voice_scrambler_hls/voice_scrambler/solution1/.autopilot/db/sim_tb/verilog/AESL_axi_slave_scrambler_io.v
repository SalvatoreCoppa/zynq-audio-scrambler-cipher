// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2021.2 (64-bit)
// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps

module AESL_axi_slave_scrambler_io (
    clk,
    reset,
    TRAN_s_axi_scrambler_io_AWADDR,
    TRAN_s_axi_scrambler_io_AWVALID,
    TRAN_s_axi_scrambler_io_AWREADY,
    TRAN_s_axi_scrambler_io_WVALID,
    TRAN_s_axi_scrambler_io_WREADY,
    TRAN_s_axi_scrambler_io_WDATA,
    TRAN_s_axi_scrambler_io_WSTRB,
    TRAN_s_axi_scrambler_io_ARADDR,
    TRAN_s_axi_scrambler_io_ARVALID,
    TRAN_s_axi_scrambler_io_ARREADY,
    TRAN_s_axi_scrambler_io_RVALID,
    TRAN_s_axi_scrambler_io_RREADY,
    TRAN_s_axi_scrambler_io_RDATA,
    TRAN_s_axi_scrambler_io_RRESP,
    TRAN_s_axi_scrambler_io_BVALID,
    TRAN_s_axi_scrambler_io_BREADY,
    TRAN_s_axi_scrambler_io_BRESP,
    TRAN_scrambler_io_write_data_finish,
    TRAN_scrambler_io_read_data_finish,
    TRAN_scrambler_io_start_in,
    TRAN_scrambler_io_idle_out,
    TRAN_scrambler_io_ready_out,
    TRAN_scrambler_io_ready_in,
    TRAN_scrambler_io_done_out,
    TRAN_scrambler_io_write_start_in   ,
    TRAN_scrambler_io_write_start_finish,
    TRAN_scrambler_io_interrupt,
    TRAN_scrambler_io_transaction_done_in
    );

//------------------------Parameter----------------------
`define TV_OUT_y "./rtl.scrambler.autotvout_y.dat"
`define TV_IN_x "./c.scrambler.autotvin_x.dat"
`define TV_IN_seed "./c.scrambler.autotvin_seed.dat"
`define TV_IN_load_seed "./c.scrambler.autotvin_load_seed.dat"
parameter ADDR_WIDTH = 6;
parameter DATA_WIDTH = 32;
parameter y_DEPTH = 1;
reg [31 : 0] y_OPERATE_DEPTH = 0;
parameter y_c_bitwidth = 16;
parameter x_DEPTH = 1;
reg [31 : 0] x_OPERATE_DEPTH = 0;
parameter x_c_bitwidth = 16;
parameter seed_DEPTH = 1;
reg [31 : 0] seed_OPERATE_DEPTH = 0;
parameter seed_c_bitwidth = 16;
parameter load_seed_DEPTH = 1;
reg [31 : 0] load_seed_OPERATE_DEPTH = 0;
parameter load_seed_c_bitwidth = 1;
parameter START_ADDR = 0;
parameter scrambler_continue_addr = 0;
parameter scrambler_auto_start_addr = 0;
parameter x_data_in_addr = 32;
parameter seed_data_in_addr = 40;
parameter load_seed_data_in_addr = 48;
parameter y_data_out_addr = 16;
parameter y_valid_out_addr = 20;
parameter ap_local_deadlock_data_out_addr = 0;
parameter STATUS_ADDR = 0;

output [ADDR_WIDTH - 1 : 0] TRAN_s_axi_scrambler_io_AWADDR;
output  TRAN_s_axi_scrambler_io_AWVALID;
input  TRAN_s_axi_scrambler_io_AWREADY;
output  TRAN_s_axi_scrambler_io_WVALID;
input  TRAN_s_axi_scrambler_io_WREADY;
output [DATA_WIDTH - 1 : 0] TRAN_s_axi_scrambler_io_WDATA;
output [DATA_WIDTH/8 - 1 : 0] TRAN_s_axi_scrambler_io_WSTRB;
output [ADDR_WIDTH - 1 : 0] TRAN_s_axi_scrambler_io_ARADDR;
output  TRAN_s_axi_scrambler_io_ARVALID;
input  TRAN_s_axi_scrambler_io_ARREADY;
input  TRAN_s_axi_scrambler_io_RVALID;
output  TRAN_s_axi_scrambler_io_RREADY;
input [DATA_WIDTH - 1 : 0] TRAN_s_axi_scrambler_io_RDATA;
input [2 - 1 : 0] TRAN_s_axi_scrambler_io_RRESP;
input  TRAN_s_axi_scrambler_io_BVALID;
output  TRAN_s_axi_scrambler_io_BREADY;
input [2 - 1 : 0] TRAN_s_axi_scrambler_io_BRESP;
output TRAN_scrambler_io_write_data_finish;
output TRAN_scrambler_io_read_data_finish;
input     clk;
input     reset;
input     TRAN_scrambler_io_start_in;
output    TRAN_scrambler_io_done_out;
output    TRAN_scrambler_io_ready_out;
input     TRAN_scrambler_io_ready_in;
output    TRAN_scrambler_io_idle_out;
input  TRAN_scrambler_io_write_start_in   ;
output TRAN_scrambler_io_write_start_finish;
input     TRAN_scrambler_io_interrupt;
input     TRAN_scrambler_io_transaction_done_in;

reg [ADDR_WIDTH - 1 : 0] AWADDR_reg = 0;
reg  AWVALID_reg = 0;
reg  WVALID_reg = 0;
reg [DATA_WIDTH - 1 : 0] WDATA_reg = 0;
reg [DATA_WIDTH/8 - 1 : 0] WSTRB_reg = 0;
reg [ADDR_WIDTH - 1 : 0] ARADDR_reg = 0;
reg  ARVALID_reg = 0;
reg  RREADY_reg = 0;
reg [DATA_WIDTH - 1 : 0] RDATA_reg = 0;
reg  BREADY_reg = 0;
reg [DATA_WIDTH - 1 : 0] mem_y [y_DEPTH - 1 : 0] = '{default : 'h0};
reg [DATA_WIDTH-1 : 0] image_mem_y [ (y_c_bitwidth+DATA_WIDTH-1)/DATA_WIDTH * y_DEPTH -1 : 0] = '{default : 'hz};
reg y_read_data_finish;
reg [DATA_WIDTH - 1 : 0] mem_x [x_DEPTH - 1 : 0] = '{default : 'h0};
reg [DATA_WIDTH-1 : 0] image_mem_x [ (x_c_bitwidth+DATA_WIDTH-1)/DATA_WIDTH * x_DEPTH -1 : 0] = '{default : 'hz};
reg x_write_data_finish;
reg [DATA_WIDTH - 1 : 0] mem_seed [seed_DEPTH - 1 : 0] = '{default : 'h0};
reg [DATA_WIDTH-1 : 0] image_mem_seed [ (seed_c_bitwidth+DATA_WIDTH-1)/DATA_WIDTH * seed_DEPTH -1 : 0] = '{default : 'hz};
reg seed_write_data_finish;
reg [DATA_WIDTH - 1 : 0] mem_load_seed [load_seed_DEPTH - 1 : 0] = '{default : 'h0};
reg [DATA_WIDTH-1 : 0] image_mem_load_seed [ (load_seed_c_bitwidth+DATA_WIDTH-1)/DATA_WIDTH * load_seed_DEPTH -1 : 0] = '{default : 'hz};
reg load_seed_write_data_finish;
reg AESL_ready_out_index_reg = 0;
reg AESL_write_start_finish = 0;
reg AESL_ready_reg;
reg ready_initial;
reg AESL_done_index_reg = 0;
reg AESL_idle_index_reg = 0;
reg AESL_auto_restart_index_reg;
reg process_0_finish = 0;
reg process_1_finish = 0;
reg process_2_finish = 0;
reg process_3_finish = 0;
reg process_4_finish = 0;
reg process_5_finish = 0;
//write x reg
reg [31 : 0] write_x_count = 0;
reg write_x_run_flag = 0;
reg write_one_x_data_done = 0;
//write seed reg
reg [31 : 0] write_seed_count = 0;
reg write_seed_run_flag = 0;
reg write_one_seed_data_done = 0;
//write load_seed reg
reg [31 : 0] write_load_seed_count = 0;
reg write_load_seed_run_flag = 0;
reg write_one_load_seed_data_done = 0;
//read y reg
reg [31 : 0] read_y_count = 0;
reg read_y_run_flag = 0;
reg read_one_y_data_done = 0;
reg [31 : 0] write_start_count = 0;
reg write_start_run_flag = 0;

//===================process control=================
reg [31 : 0] ongoing_process_number = 0;
//process number depends on how much processes needed.
reg process_busy = 0;

//=================== signal connection ==============
assign TRAN_s_axi_scrambler_io_AWADDR = AWADDR_reg;
assign TRAN_s_axi_scrambler_io_AWVALID = AWVALID_reg;
assign TRAN_s_axi_scrambler_io_WVALID = WVALID_reg;
assign TRAN_s_axi_scrambler_io_WDATA = WDATA_reg;
assign TRAN_s_axi_scrambler_io_WSTRB = WSTRB_reg;
assign TRAN_s_axi_scrambler_io_ARADDR = ARADDR_reg;
assign TRAN_s_axi_scrambler_io_ARVALID = ARVALID_reg;
assign TRAN_s_axi_scrambler_io_RREADY = RREADY_reg;
assign TRAN_s_axi_scrambler_io_BREADY = BREADY_reg;
assign TRAN_scrambler_io_write_start_finish = AESL_write_start_finish;
assign TRAN_scrambler_io_done_out = AESL_done_index_reg;
assign TRAN_scrambler_io_ready_out = AESL_ready_out_index_reg;
assign TRAN_scrambler_io_idle_out = AESL_idle_index_reg;
assign TRAN_scrambler_io_read_data_finish = 1 & y_read_data_finish;
assign TRAN_scrambler_io_write_data_finish = 1 & x_write_data_finish & seed_write_data_finish & load_seed_write_data_finish;
always @(TRAN_scrambler_io_ready_in or ready_initial) 
begin
    AESL_ready_reg <= TRAN_scrambler_io_ready_in | ready_initial;
end

always @(reset or process_0_finish or process_1_finish or process_2_finish or process_3_finish or process_4_finish or process_5_finish ) begin
    if (reset == 0) begin
        ongoing_process_number <= 0;
    end
    else if (ongoing_process_number == 0 && process_0_finish == 1) begin
            ongoing_process_number <= ongoing_process_number + 1;
    end
    else if (ongoing_process_number == 1 && process_1_finish == 1) begin
            ongoing_process_number <= ongoing_process_number + 1;
    end
    else if (ongoing_process_number == 2 && process_2_finish == 1) begin
            ongoing_process_number <= ongoing_process_number + 1;
    end
    else if (ongoing_process_number == 3 && process_3_finish == 1) begin
            ongoing_process_number <= ongoing_process_number + 1;
    end
    else if (ongoing_process_number == 4 && process_4_finish == 1) begin
            ongoing_process_number <= ongoing_process_number + 1;
    end
    else if (ongoing_process_number == 5 && process_5_finish == 1) begin
            ongoing_process_number <= 0;
    end
end

task count_c_data_four_byte_num_by_bitwidth;
input  integer bitwidth;
output integer num;
integer factor;
integer i;
begin
    factor = 32;
    for (i = 1; i <= 32; i = i + 1) begin
        if (bitwidth <= factor && bitwidth > factor - 32) begin
            num = i;
        end
        factor = factor + 32;
    end
end    
endtask

task count_seperate_factor_by_bitwidth;
input  integer bitwidth;
output integer factor;
begin
    if (bitwidth <= 8) begin
        factor=4;
    end
    if (bitwidth <= 16 & bitwidth > 8 ) begin
        factor=2;
    end
    if (bitwidth <= 32 & bitwidth > 16 ) begin
        factor=1;
    end
    if (bitwidth <= 1024 & bitwidth > 32 ) begin
        factor=1;
    end
end    
endtask

task count_operate_depth_by_bitwidth_and_depth;
input  integer bitwidth;
input  integer depth;
output integer operate_depth;
integer factor;
integer remain;
begin
    count_seperate_factor_by_bitwidth (bitwidth , factor);
    operate_depth = depth / factor;
    remain = depth % factor;
    if (remain > 0) begin
        operate_depth = operate_depth + 1;
    end
end    
endtask

task write; /*{{{*/
    input  reg [ADDR_WIDTH - 1:0] waddr;   // write address
    input  reg [DATA_WIDTH - 1:0] wdata;   // write data
    output reg wresp;
    reg aw_flag;
    reg w_flag;
    reg [DATA_WIDTH/8 - 1:0] wstrb_reg;
    integer i;
begin 
    wresp = 0;
    aw_flag = 0;
    w_flag = 0;
//=======================one single write operate======================
    AWADDR_reg <= waddr;
    AWVALID_reg <= 1;
    WDATA_reg <= wdata;
    WVALID_reg <= 1;
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
        wstrb_reg [i] = 1;
    end    
    WSTRB_reg <= wstrb_reg;
    while (!(aw_flag && w_flag)) begin
        @(posedge clk);
        if (aw_flag != 1)
            aw_flag = TRAN_s_axi_scrambler_io_AWREADY & AWVALID_reg;
        if (w_flag != 1)
            w_flag = TRAN_s_axi_scrambler_io_WREADY & WVALID_reg;
        AWVALID_reg <= !aw_flag;
        WVALID_reg <= !w_flag;
    end

    BREADY_reg <= 1;
    while (TRAN_s_axi_scrambler_io_BVALID != 1) begin
        //wait for response 
        @(posedge clk);
    end
    @(posedge clk);
    BREADY_reg <= 0;
    if (TRAN_s_axi_scrambler_io_BRESP === 2'b00) begin
        wresp = 1;
        //input success. in fact BRESP is always 2'b00
    end   
//=======================one single write operate======================

end
endtask/*}}}*/

task read (/*{{{*/
    input  [ADDR_WIDTH - 1:0] raddr ,   // write address
    output [DATA_WIDTH - 1:0] RDATA_result ,
    output rresp
);
begin 
    rresp = 0;
//=======================one single read operate======================
    ARADDR_reg <= raddr;
    ARVALID_reg <= 1;
    while (TRAN_s_axi_scrambler_io_ARREADY !== 1) begin
        @(posedge clk);
    end
    @(posedge clk);
    ARVALID_reg <= 0;
    RREADY_reg <= 1;
    while (TRAN_s_axi_scrambler_io_RVALID !== 1) begin
        //wait for response 
        @(posedge clk);
    end
    @(posedge clk);
    RDATA_result  <= TRAN_s_axi_scrambler_io_RDATA;
    RREADY_reg <= 0;
    if (TRAN_s_axi_scrambler_io_RRESP === 2'b00 ) begin
        rresp <= 1;
        //output success. in fact RRESP is always 2'b00
    end  
    @(posedge clk);

//=======================one single read operate end======================

end
endtask/*}}}*/

initial begin : ready_initial_process
    ready_initial = 0;
    wait(reset === 1);
    @(posedge clk);
    ready_initial = 1;
    @(posedge clk);
    ready_initial = 0;
end

initial begin : update_status
    integer process_num ;
    integer read_status_resp;
    wait(reset === 1);
    @(posedge clk);
    process_num = 0;
    while (1) begin
        process_0_finish = 0;
        AESL_done_index_reg         <= 0;
        AESL_ready_out_index_reg        <= 0;
        if (ongoing_process_number === process_num && process_busy === 0) begin
            process_busy = 1;
            read (STATUS_ADDR, RDATA_reg, read_status_resp);
                AESL_done_index_reg         <= RDATA_reg[1 : 1];
                AESL_ready_out_index_reg    <= RDATA_reg[1 : 1];
                AESL_idle_index_reg         <= RDATA_reg[2 : 2];
            process_0_finish = 1;
            process_busy = 0;
        end 
        @(posedge clk);
    end
end

always @(reset or posedge clk) begin
    if (reset == 0) begin
        x_write_data_finish <= 0;
        write_x_run_flag <= 0; 
        write_x_count = 0;
        count_operate_depth_by_bitwidth_and_depth (x_c_bitwidth, x_DEPTH, x_OPERATE_DEPTH);
    end
    else begin
        if (TRAN_scrambler_io_start_in === 1) begin
            x_write_data_finish <= 0;
        end
        if (AESL_ready_reg === 1) begin
            write_x_run_flag <= 1; 
            write_x_count = 0;
        end
        if (write_one_x_data_done === 1) begin
            write_x_count = write_x_count + 1;
            if (write_x_count == x_OPERATE_DEPTH) begin
                write_x_run_flag <= 0; 
                x_write_data_finish <= 1;
            end
        end
    end
end

initial begin : write_x
    integer write_x_resp;
    integer process_num ;
    integer get_ack;
    integer four_byte_num;
    integer c_bitwidth;
    integer i;
    integer j;
    reg [31 : 0] x_data_tmp_reg;
    wait(reset === 1);
    @(posedge clk);
    c_bitwidth = x_c_bitwidth;
    process_num = 1;
    count_c_data_four_byte_num_by_bitwidth (c_bitwidth , four_byte_num) ;
    while (1) begin
        process_1_finish <= 0;

        if (ongoing_process_number === process_num && process_busy === 0 ) begin
            get_ack = 1;
            if (write_x_run_flag === 1 && get_ack === 1) begin
                process_busy = 1;
                //write x data 
                for (i = 0 ; i < four_byte_num ; i = i+1) begin
                    if (x_c_bitwidth < 32) begin
                        x_data_tmp_reg = mem_x[write_x_count];
                    end
                    else begin
                        for (j=0 ; j<32 ; j = j + 1) begin
                            if (i*32 + j < x_c_bitwidth) begin
                                x_data_tmp_reg[j] = mem_x[write_x_count][i*32 + j];
                            end
                            else begin
                                x_data_tmp_reg[j] = 0;
                            end
                        end
                    end
                    if(image_mem_x[write_x_count * four_byte_num  + i]!==x_data_tmp_reg) begin
                    write (x_data_in_addr + write_x_count * four_byte_num * 4 + i * 4, x_data_tmp_reg, write_x_resp);
                    image_mem_x[write_x_count * four_byte_num + i]=x_data_tmp_reg;
                    end
                end
                process_busy = 0;
                write_one_x_data_done <= 1;
                @(posedge clk);
                write_one_x_data_done <= 0;
            end   
            process_1_finish <= 1;
        end
        @(posedge clk);
    end    
end
always @(reset or posedge clk) begin
    if (reset == 0) begin
        seed_write_data_finish <= 0;
        write_seed_run_flag <= 0; 
        write_seed_count = 0;
        count_operate_depth_by_bitwidth_and_depth (seed_c_bitwidth, seed_DEPTH, seed_OPERATE_DEPTH);
    end
    else begin
        if (TRAN_scrambler_io_start_in === 1) begin
            seed_write_data_finish <= 0;
        end
        if (AESL_ready_reg === 1) begin
            write_seed_run_flag <= 1; 
            write_seed_count = 0;
        end
        if (write_one_seed_data_done === 1) begin
            write_seed_count = write_seed_count + 1;
            if (write_seed_count == seed_OPERATE_DEPTH) begin
                write_seed_run_flag <= 0; 
                seed_write_data_finish <= 1;
            end
        end
    end
end

initial begin : write_seed
    integer write_seed_resp;
    integer process_num ;
    integer get_ack;
    integer four_byte_num;
    integer c_bitwidth;
    integer i;
    integer j;
    reg [31 : 0] seed_data_tmp_reg;
    wait(reset === 1);
    @(posedge clk);
    c_bitwidth = seed_c_bitwidth;
    process_num = 2;
    count_c_data_four_byte_num_by_bitwidth (c_bitwidth , four_byte_num) ;
    while (1) begin
        process_2_finish <= 0;

        if (ongoing_process_number === process_num && process_busy === 0 ) begin
            get_ack = 1;
            if (write_seed_run_flag === 1 && get_ack === 1) begin
                process_busy = 1;
                //write seed data 
                for (i = 0 ; i < four_byte_num ; i = i+1) begin
                    if (seed_c_bitwidth < 32) begin
                        seed_data_tmp_reg = mem_seed[write_seed_count];
                    end
                    else begin
                        for (j=0 ; j<32 ; j = j + 1) begin
                            if (i*32 + j < seed_c_bitwidth) begin
                                seed_data_tmp_reg[j] = mem_seed[write_seed_count][i*32 + j];
                            end
                            else begin
                                seed_data_tmp_reg[j] = 0;
                            end
                        end
                    end
                    if(image_mem_seed[write_seed_count * four_byte_num  + i]!==seed_data_tmp_reg) begin
                    write (seed_data_in_addr + write_seed_count * four_byte_num * 4 + i * 4, seed_data_tmp_reg, write_seed_resp);
                    image_mem_seed[write_seed_count * four_byte_num + i]=seed_data_tmp_reg;
                    end
                end
                process_busy = 0;
                write_one_seed_data_done <= 1;
                @(posedge clk);
                write_one_seed_data_done <= 0;
            end   
            process_2_finish <= 1;
        end
        @(posedge clk);
    end    
end
always @(reset or posedge clk) begin
    if (reset == 0) begin
        load_seed_write_data_finish <= 0;
        write_load_seed_run_flag <= 0; 
        write_load_seed_count = 0;
        count_operate_depth_by_bitwidth_and_depth (load_seed_c_bitwidth, load_seed_DEPTH, load_seed_OPERATE_DEPTH);
    end
    else begin
        if (TRAN_scrambler_io_start_in === 1) begin
            load_seed_write_data_finish <= 0;
        end
        if (AESL_ready_reg === 1) begin
            write_load_seed_run_flag <= 1; 
            write_load_seed_count = 0;
        end
        if (write_one_load_seed_data_done === 1) begin
            write_load_seed_count = write_load_seed_count + 1;
            if (write_load_seed_count == load_seed_OPERATE_DEPTH) begin
                write_load_seed_run_flag <= 0; 
                load_seed_write_data_finish <= 1;
            end
        end
    end
end

initial begin : write_load_seed
    integer write_load_seed_resp;
    integer process_num ;
    integer get_ack;
    integer four_byte_num;
    integer c_bitwidth;
    integer i;
    integer j;
    reg [31 : 0] load_seed_data_tmp_reg;
    wait(reset === 1);
    @(posedge clk);
    c_bitwidth = load_seed_c_bitwidth;
    process_num = 3;
    count_c_data_four_byte_num_by_bitwidth (c_bitwidth , four_byte_num) ;
    while (1) begin
        process_3_finish <= 0;

        if (ongoing_process_number === process_num && process_busy === 0 ) begin
            get_ack = 1;
            if (write_load_seed_run_flag === 1 && get_ack === 1) begin
                process_busy = 1;
                //write load_seed data 
                for (i = 0 ; i < four_byte_num ; i = i+1) begin
                    if (load_seed_c_bitwidth < 32) begin
                        load_seed_data_tmp_reg = mem_load_seed[write_load_seed_count];
                    end
                    else begin
                        for (j=0 ; j<32 ; j = j + 1) begin
                            if (i*32 + j < load_seed_c_bitwidth) begin
                                load_seed_data_tmp_reg[j] = mem_load_seed[write_load_seed_count][i*32 + j];
                            end
                            else begin
                                load_seed_data_tmp_reg[j] = 0;
                            end
                        end
                    end
                    if(image_mem_load_seed[write_load_seed_count * four_byte_num  + i]!==load_seed_data_tmp_reg) begin
                    write (load_seed_data_in_addr + write_load_seed_count * four_byte_num * 4 + i * 4, load_seed_data_tmp_reg, write_load_seed_resp);
                    image_mem_load_seed[write_load_seed_count * four_byte_num + i]=load_seed_data_tmp_reg;
                    end
                end
                process_busy = 0;
                write_one_load_seed_data_done <= 1;
                @(posedge clk);
                write_one_load_seed_data_done <= 0;
            end   
            process_3_finish <= 1;
        end
        @(posedge clk);
    end    
end

always @(reset or posedge clk) begin
    if (reset == 0) begin
        write_start_run_flag <= 0; 
        write_start_count <= 0;
    end
    else begin
        if (write_start_count >= 22) begin
            write_start_run_flag <= 0; 
        end
        else if (TRAN_scrambler_io_write_start_in === 1) begin
            write_start_run_flag <= 1; 
        end
        if (AESL_write_start_finish === 1) begin
            write_start_count <= write_start_count + 1;
            write_start_run_flag <= 0; 
        end
    end
end

initial begin : write_start
    reg [DATA_WIDTH - 1 : 0] write_start_tmp;
    integer process_num;
    integer write_start_resp;
    wait(reset === 1);
    @(posedge clk);
    process_num = 4;
    while (1) begin
        process_4_finish = 0;
        if (ongoing_process_number === process_num && process_busy === 0 ) begin
            if (write_start_run_flag === 1) begin
                process_busy = 1;
                write_start_tmp=0;
                write_start_tmp[0 : 0] = 1;
                write (START_ADDR, write_start_tmp, write_start_resp);
                process_busy = 0;
                AESL_write_start_finish <= 1;
                @(posedge clk);
                AESL_write_start_finish <= 0;
            end
            process_4_finish <= 1;
        end 
        @(posedge clk);
    end
end

always @(reset or posedge clk) begin
    if (reset == 0) begin
        y_read_data_finish <= 0;
        read_y_run_flag <= 0; 
        read_y_count = 0;
        count_operate_depth_by_bitwidth_and_depth (y_c_bitwidth, y_DEPTH, y_OPERATE_DEPTH);
    end
    else begin
        if (AESL_done_index_reg === 1) begin
            read_y_run_flag = 1; 
        end
        if (TRAN_scrambler_io_transaction_done_in === 1) begin
            y_read_data_finish <= 0;
            read_y_count = 0; 
        end
        if (read_one_y_data_done === 1) begin
            read_y_count = read_y_count + 1;
            if (read_y_count == y_OPERATE_DEPTH) begin
                read_y_run_flag <= 0; 
                y_read_data_finish <= 1;
            end
        end
    end
end

initial begin : read_y
    integer read_y_resp;
    integer process_num;
    integer get_vld;
    integer four_byte_num;
    integer c_bitwidth;
    integer i;
    integer j;

    wait(reset === 1);
    @(posedge clk);
    c_bitwidth = y_c_bitwidth;
    process_num = 5;
    count_c_data_four_byte_num_by_bitwidth (c_bitwidth , four_byte_num) ;
    while (1) begin
        process_5_finish <= 0;
        if (ongoing_process_number === process_num && process_busy === 0 ) begin
            if (read_y_run_flag === 1) begin
                process_busy = 1;
                get_vld = 0;
                //read y vld
                read (y_valid_out_addr, RDATA_reg, read_y_resp);
                if (RDATA_reg[0 : 0] == 1) begin
                    get_vld = 1;
                end
                if (get_vld == 1) begin
                    //read y data 
                    for (i = 0 ; i < four_byte_num ; i = i+1) begin
                        read (y_data_out_addr + read_y_count * four_byte_num * 4 + i * 4, RDATA_reg, read_y_resp);
                        if (y_c_bitwidth < 32) begin
                            mem_y[read_y_count] <= RDATA_reg;
                        end
                        else begin
                            for (j=0 ; j < 32 ; j = j + 1) begin
                                if (i*32 + j < y_c_bitwidth) begin
                                    mem_y[read_y_count][i*32 + j] <= RDATA_reg[j];
                                end
                            end
                        end
                    end
                    
                    read_one_y_data_done <= 1;
                    @(posedge clk);
                    read_one_y_data_done <= 0;
                end    
                process_busy = 0;
            end    
            process_5_finish <= 1;
        end
        @(posedge clk);
    end    
end
//------------------------Task and function-------------- 
task read_token; 
    input integer fp; 
    output reg [127 : 0] token;
    integer ret;
    begin
        token = "";
        ret = 0;
        ret = $fscanf(fp,"%s",token);
    end 
endtask 
 
task write_binary_y;
    input integer fp;
    input reg[64-1:0] in;
    input integer in_bw;
    reg [63:0] tmp_long;
    reg[64-1:0] local_in;
    integer char_num;
    integer long_num;
    integer i;
    integer j;
    begin
        long_num = (in_bw + 63) / 64;
        char_num = ((in_bw - 1) % 64 + 7) / 8;
        for(i=long_num;i>0;i=i-1) begin
             local_in = in;
             tmp_long = local_in >> ((i-1)*64);
             for(j=0;j<64;j=j+1)
                 if (tmp_long[j] === 1'bx)
                     tmp_long[j] = 1'b0;
             if (i == long_num) begin
                 case(char_num)
                     1: $fwrite(fp,"%c",tmp_long[7:0]);
                     2: $fwrite(fp,"%c%c",tmp_long[15:8],tmp_long[7:0]);
                     3: $fwrite(fp,"%c%c%c",tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     4: $fwrite(fp,"%c%c%c%c",tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     5: $fwrite(fp,"%c%c%c%c%c",tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     6: $fwrite(fp,"%c%c%c%c%c%c",tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     7: $fwrite(fp,"%c%c%c%c%c%c%c",tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     8: $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     default: ;
                 endcase
             end
             else begin
                 $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
             end
        end
    end
endtask;
//------------------------Write file----------------------- 
 
// Write data to file 
 
initial begin : write_y_file_proc 
  integer fp; 
  integer factor; 
  integer transaction_idx; 
  reg [y_c_bitwidth - 1 : 0] tmp_cache_mem; 
  reg [ 100*8 : 1] str;
  reg [63:0] bin_data;
  integer i; 
  transaction_idx = 0; 
  count_seperate_factor_by_bitwidth (y_c_bitwidth , factor);
  while(1) begin 
      @(posedge clk);
      while (y_read_data_finish !== 1 || TRAN_scrambler_io_transaction_done_in === 1) begin
          @(posedge clk);
      end
      # 0.1;
      fp = $fopen(`TV_OUT_y, "a"); 
      if(fp == 0) begin       // Failed to open file 
          $display("Failed to open file \"%s\"!", `TV_OUT_y); 
          $finish; 
      end 
      $fdisplay(fp, "[[transaction]] %d", transaction_idx);
      for (i = 0; i < (y_DEPTH - y_DEPTH % factor); i = i + 1) begin
          if (factor == 4) begin
              if (i%factor == 0) begin
                  tmp_cache_mem = mem_y[i/factor][7:0];
              end
              if (i%factor == 1) begin
                  tmp_cache_mem = mem_y[i/factor][15:8];
              end
              if (i%factor == 2) begin
                  tmp_cache_mem = mem_y[i/factor][23:16];
              end
              if (i%factor == 3) begin
                  tmp_cache_mem = mem_y[i/factor][31:24];
              end
              $fdisplay(fp,"0x%x",tmp_cache_mem);
          end
          if (factor == 2) begin
              if (i%factor == 0) begin
                  tmp_cache_mem = mem_y[i/factor][15:0];
              end
              if (i%factor == 1) begin
                  tmp_cache_mem = mem_y[i/factor][31:16];
              end
              $fdisplay(fp,"0x%x",tmp_cache_mem);
          end
          if (factor == 1) begin
              $fdisplay(fp,"0x%x",mem_y[i]);
          end
      end 
      if (factor == 4) begin
          if ((y_DEPTH - 1) % factor == 2) begin
              $fdisplay(fp,"0x%x",mem_y[y_DEPTH / factor][7:0]);
              $fdisplay(fp,"0x%x",mem_y[y_DEPTH / factor][15:8]);
              $fdisplay(fp,"0x%x",mem_y[y_DEPTH / factor][23:16]);
          end
          if ((y_DEPTH - 1) % factor == 1) begin
              $fdisplay(fp,"0x%x",mem_y[y_DEPTH / factor][7:0]);
              $fdisplay(fp,"0x%x",mem_y[y_DEPTH / factor][15:8]);
          end
          if ((y_DEPTH - 1) % factor == 0) begin
              $fdisplay(fp,"0x%x",mem_y[y_DEPTH / factor][7:0]);
          end
      end
      if (factor == 2) begin
          if ((y_DEPTH - 1) % factor == 0) begin
              $fdisplay(fp,"0x%x",mem_y[y_DEPTH / factor][15:0]);
          end
      end
      $fdisplay(fp, "[[/transaction]]");
      transaction_idx = transaction_idx + 1;
      $fclose(fp); 
      while (TRAN_scrambler_io_start_in !== 1) begin
          @(posedge clk);
      end
  end 
end 
 
//------------------------Read file------------------------ 
 
// Read data from file 
initial begin : read_x_file_process 
  integer fp; 
  integer ret; 
  integer factor; 
  reg [127 : 0] token; 
  reg [127 : 0] token_tmp; 
  //reg [x_c_bitwidth - 1 : 0] token_tmp; 
  reg [DATA_WIDTH - 1 : 0] tmp_cache_mem; 
  reg [ 8*5 : 1] str;
    reg [63:0] trans_depth;
  integer transaction_idx; 
  integer i; 
  transaction_idx = 0; 
  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
  count_seperate_factor_by_bitwidth (x_c_bitwidth , factor);
  fp = $fopen(`TV_IN_x ,"r"); 
  if(fp == 0) begin                               // Failed to open file 
      $display("Failed to open file \"%s\"!", `TV_IN_x); 
      $finish; 
  end 
  read_token(fp, token); 
  if (token != "[[[runtime]]]") begin             // Illegal format 
      $display("ERROR: Simulation using HLS TB failed.");
      $finish; 
  end 
  read_token(fp, token); 
  while (token != "[[[/runtime]]]") begin 
      if (token != "[[transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token);                        // skip transaction number 
      @(posedge clk);
      # 0.2;
      while(AESL_ready_reg !== 1) begin
          @(posedge clk); 
          # 0.2;
      end
      for(i = 0; i < x_DEPTH; i = i + 1) begin 
          read_token(fp, token); 
          ret = $sscanf(token, "0x%x", token_tmp); 
          if (factor == 4) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [7 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [15 : 8] = token_tmp;
              end
              if (i%factor == 2) begin
                  tmp_cache_mem [23 : 16] = token_tmp;
              end
              if (i%factor == 3) begin
                  tmp_cache_mem [31 : 24] = token_tmp;
                  mem_x [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
              end
          end
          if (factor == 2) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [15 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [31 : 16] = token_tmp;
                  mem_x [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1: 0] = 0;
              end
          end
          if (factor == 1) begin
              mem_x [i] = token_tmp;
          end
      end 
      if (factor == 4) begin
          if (i%factor != 0) begin
              mem_x [i/factor] = tmp_cache_mem;
          end
      end
      if (factor == 2) begin
          if (i%factor != 0) begin
              mem_x [i/factor] = tmp_cache_mem;
          end
      end 
      read_token(fp, token); 
      if(token != "[[/transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token); 
      transaction_idx = transaction_idx + 1; 
  end 
  $fclose(fp); 
end 
 
task write_binary_x;
    input integer fp;
    input reg[64-1:0] in;
    input integer in_bw;
    reg [63:0] tmp_long;
    reg[64-1:0] local_in;
    integer char_num;
    integer long_num;
    integer i;
    integer j;
    begin
        long_num = (in_bw + 63) / 64;
        char_num = ((in_bw - 1) % 64 + 7) / 8;
        for(i=long_num;i>0;i=i-1) begin
             local_in = in;
             tmp_long = local_in >> ((i-1)*64);
             for(j=0;j<64;j=j+1)
                 if (tmp_long[j] === 1'bx)
                     tmp_long[j] = 1'b0;
             if (i == long_num) begin
                 case(char_num)
                     1: $fwrite(fp,"%c",tmp_long[7:0]);
                     2: $fwrite(fp,"%c%c",tmp_long[15:8],tmp_long[7:0]);
                     3: $fwrite(fp,"%c%c%c",tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     4: $fwrite(fp,"%c%c%c%c",tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     5: $fwrite(fp,"%c%c%c%c%c",tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     6: $fwrite(fp,"%c%c%c%c%c%c",tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     7: $fwrite(fp,"%c%c%c%c%c%c%c",tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     8: $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     default: ;
                 endcase
             end
             else begin
                 $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
             end
        end
    end
endtask;
//------------------------Read file------------------------ 
 
// Read data from file 
initial begin : read_seed_file_process 
  integer fp; 
  integer ret; 
  integer factor; 
  reg [127 : 0] token; 
  reg [127 : 0] token_tmp; 
  //reg [seed_c_bitwidth - 1 : 0] token_tmp; 
  reg [DATA_WIDTH - 1 : 0] tmp_cache_mem; 
  reg [ 8*5 : 1] str;
    reg [63:0] trans_depth;
  integer transaction_idx; 
  integer i; 
  transaction_idx = 0; 
  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
  count_seperate_factor_by_bitwidth (seed_c_bitwidth , factor);
  fp = $fopen(`TV_IN_seed ,"r"); 
  if(fp == 0) begin                               // Failed to open file 
      $display("Failed to open file \"%s\"!", `TV_IN_seed); 
      $finish; 
  end 
  read_token(fp, token); 
  if (token != "[[[runtime]]]") begin             // Illegal format 
      $display("ERROR: Simulation using HLS TB failed.");
      $finish; 
  end 
  read_token(fp, token); 
  while (token != "[[[/runtime]]]") begin 
      if (token != "[[transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token);                        // skip transaction number 
      @(posedge clk);
      # 0.2;
      while(AESL_ready_reg !== 1) begin
          @(posedge clk); 
          # 0.2;
      end
      for(i = 0; i < seed_DEPTH; i = i + 1) begin 
          read_token(fp, token); 
          ret = $sscanf(token, "0x%x", token_tmp); 
          if (factor == 4) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [7 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [15 : 8] = token_tmp;
              end
              if (i%factor == 2) begin
                  tmp_cache_mem [23 : 16] = token_tmp;
              end
              if (i%factor == 3) begin
                  tmp_cache_mem [31 : 24] = token_tmp;
                  mem_seed [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
              end
          end
          if (factor == 2) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [15 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [31 : 16] = token_tmp;
                  mem_seed [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1: 0] = 0;
              end
          end
          if (factor == 1) begin
              mem_seed [i] = token_tmp;
          end
      end 
      if (factor == 4) begin
          if (i%factor != 0) begin
              mem_seed [i/factor] = tmp_cache_mem;
          end
      end
      if (factor == 2) begin
          if (i%factor != 0) begin
              mem_seed [i/factor] = tmp_cache_mem;
          end
      end 
      read_token(fp, token); 
      if(token != "[[/transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token); 
      transaction_idx = transaction_idx + 1; 
  end 
  $fclose(fp); 
end 
 
task write_binary_seed;
    input integer fp;
    input reg[64-1:0] in;
    input integer in_bw;
    reg [63:0] tmp_long;
    reg[64-1:0] local_in;
    integer char_num;
    integer long_num;
    integer i;
    integer j;
    begin
        long_num = (in_bw + 63) / 64;
        char_num = ((in_bw - 1) % 64 + 7) / 8;
        for(i=long_num;i>0;i=i-1) begin
             local_in = in;
             tmp_long = local_in >> ((i-1)*64);
             for(j=0;j<64;j=j+1)
                 if (tmp_long[j] === 1'bx)
                     tmp_long[j] = 1'b0;
             if (i == long_num) begin
                 case(char_num)
                     1: $fwrite(fp,"%c",tmp_long[7:0]);
                     2: $fwrite(fp,"%c%c",tmp_long[15:8],tmp_long[7:0]);
                     3: $fwrite(fp,"%c%c%c",tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     4: $fwrite(fp,"%c%c%c%c",tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     5: $fwrite(fp,"%c%c%c%c%c",tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     6: $fwrite(fp,"%c%c%c%c%c%c",tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     7: $fwrite(fp,"%c%c%c%c%c%c%c",tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     8: $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     default: ;
                 endcase
             end
             else begin
                 $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
             end
        end
    end
endtask;
//------------------------Read file------------------------ 
 
// Read data from file 
initial begin : read_load_seed_file_process 
  integer fp; 
  integer ret; 
  integer factor; 
  reg [127 : 0] token; 
  reg [127 : 0] token_tmp; 
  //reg [load_seed_c_bitwidth - 1 : 0] token_tmp; 
  reg [DATA_WIDTH - 1 : 0] tmp_cache_mem; 
  reg [ 8*5 : 1] str;
    reg [63:0] trans_depth;
  integer transaction_idx; 
  integer i; 
  transaction_idx = 0; 
  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
  count_seperate_factor_by_bitwidth (load_seed_c_bitwidth , factor);
  fp = $fopen(`TV_IN_load_seed ,"r"); 
  if(fp == 0) begin                               // Failed to open file 
      $display("Failed to open file \"%s\"!", `TV_IN_load_seed); 
      $finish; 
  end 
  read_token(fp, token); 
  if (token != "[[[runtime]]]") begin             // Illegal format 
      $display("ERROR: Simulation using HLS TB failed.");
      $finish; 
  end 
  read_token(fp, token); 
  while (token != "[[[/runtime]]]") begin 
      if (token != "[[transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token);                        // skip transaction number 
      @(posedge clk);
      # 0.2;
      while(AESL_ready_reg !== 1) begin
          @(posedge clk); 
          # 0.2;
      end
      for(i = 0; i < load_seed_DEPTH; i = i + 1) begin 
          read_token(fp, token); 
          ret = $sscanf(token, "0x%x", token_tmp); 
          if (factor == 4) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [7 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [15 : 8] = token_tmp;
              end
              if (i%factor == 2) begin
                  tmp_cache_mem [23 : 16] = token_tmp;
              end
              if (i%factor == 3) begin
                  tmp_cache_mem [31 : 24] = token_tmp;
                  mem_load_seed [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1 : 0] = 0;
              end
          end
          if (factor == 2) begin
              if (i%factor == 0) begin
                  tmp_cache_mem [15 : 0] = token_tmp;
              end
              if (i%factor == 1) begin
                  tmp_cache_mem [31 : 16] = token_tmp;
                  mem_load_seed [i/factor] = tmp_cache_mem;
                  tmp_cache_mem [DATA_WIDTH - 1: 0] = 0;
              end
          end
          if (factor == 1) begin
              mem_load_seed [i] = token_tmp;
          end
      end 
      if (factor == 4) begin
          if (i%factor != 0) begin
              mem_load_seed [i/factor] = tmp_cache_mem;
          end
      end
      if (factor == 2) begin
          if (i%factor != 0) begin
              mem_load_seed [i/factor] = tmp_cache_mem;
          end
      end 
      read_token(fp, token); 
      if(token != "[[/transaction]]") begin 
          $display("ERROR: Simulation using HLS TB failed.");
          $finish; 
      end 
      read_token(fp, token); 
      transaction_idx = transaction_idx + 1; 
  end 
  $fclose(fp); 
end 
 
task write_binary_load_seed;
    input integer fp;
    input reg[64-1:0] in;
    input integer in_bw;
    reg [63:0] tmp_long;
    reg[64-1:0] local_in;
    integer char_num;
    integer long_num;
    integer i;
    integer j;
    begin
        long_num = (in_bw + 63) / 64;
        char_num = ((in_bw - 1) % 64 + 7) / 8;
        for(i=long_num;i>0;i=i-1) begin
             local_in = in;
             tmp_long = local_in >> ((i-1)*64);
             for(j=0;j<64;j=j+1)
                 if (tmp_long[j] === 1'bx)
                     tmp_long[j] = 1'b0;
             if (i == long_num) begin
                 case(char_num)
                     1: $fwrite(fp,"%c",tmp_long[7:0]);
                     2: $fwrite(fp,"%c%c",tmp_long[15:8],tmp_long[7:0]);
                     3: $fwrite(fp,"%c%c%c",tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     4: $fwrite(fp,"%c%c%c%c",tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     5: $fwrite(fp,"%c%c%c%c%c",tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     6: $fwrite(fp,"%c%c%c%c%c%c",tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     7: $fwrite(fp,"%c%c%c%c%c%c%c",tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     8: $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
                     default: ;
                 endcase
             end
             else begin
                 $fwrite(fp,"%c%c%c%c%c%c%c%c",tmp_long[63:56],tmp_long[55:48],tmp_long[47:40],tmp_long[39:32],tmp_long[31:24],tmp_long[23:16],tmp_long[15:8],tmp_long[7:0]);
             end
        end
    end
endtask;
endmodule
