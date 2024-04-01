`timescale 1ns / 1ps
/***********************************************************
simulation time consumed: xx ms
Tools:  Modelsim se-64 2019.2
***********************************************************/
module tb_galois_lfsr ();
 
    parameter BIT_WIDTH = 8;

    reg                 clk = 1'b0;
    reg                 rst = 1'b0;
    reg [15:00]         cnt_temp = 0;
    reg                 seed_done = 0;
    reg                 enable_r = 0;

    reg                 enable = 0;
    reg                 i_load_evt;
    reg [BIT_WIDTH-1:0] i_seed_data = {BIT_WIDTH{1'b1}};

    wire                w_lfsr_vld;
    wire[BIT_WIDTH-1:0] w_lfsr_data;
    wire                w_lfsr_done;

    wire                o_lfsr_vld;
    wire[BIT_WIDTH-1:0] o_lfsr_data;
    wire                o_lfsr_done;
    
    reg                 w_lfsr_vld_r  = 0;
    reg [BIT_WIDTH-1:0] w_lfsr_data_r = 0;
    reg                 w_lfsr_done_r = 0; 

    reg                 err_flag = 0;
  
    always @(*) #10 clk <= ~clk; 

    // Seed Genarate ---------------------------------------------
    always @(posedge clk) begin 
        if (cnt_temp == 16'd63) begin
            cnt_temp <= 0;
        end else begin
            cnt_temp <= cnt_temp + 1;
        end
    end

    always @(posedge clk) begin 
        if (cnt_temp == 16'd15) begin 
            enable <= 1;
        end else if(cnt_temp == 16'd63) begin
            enable <= 0;
        end else begin
            enable <= enable;
        end
        enable_r <= enable;
    end

    
    always @(posedge clk) begin
        i_load_evt  <= 0;
        if (enable & ~enable_r & ~seed_done) begin
            i_load_evt <= 1;
            i_seed_data <= {1'b0, $random};
            seed_done  <= 1;
        end
    end

//=================< Submodule Instantiation >==========================
    galois_lfsr # ( .BIT_WIDTH(BIT_WIDTH) ) lfsr_gen (
        .clk        ( clk           ),
        .rst        ( rst           ),
        .enable     ( enable_r      ),
        .load_evt   ( i_load_evt    ),
        .seed_data  ( i_seed_data   ), 
        .lfsr_vld   ( w_lfsr_vld    ),
        .lfsr_data  ( w_lfsr_data   ),
        .lfsr_done  ( w_lfsr_done   )
    );

    galois_lfsr # ( .BIT_WIDTH(BIT_WIDTH) ) lfsr_check (
        .clk        ( clk           ),
        .rst        ( rst           ),
        .enable     ( w_lfsr_vld    ),
        .load_evt   ( w_lfsr_done   ),
        .seed_data  ( w_lfsr_data   ), 
        .lfsr_vld   ( o_lfsr_vld    ),
        .lfsr_data  ( o_lfsr_data   ),
        .lfsr_done  ( o_lfsr_done   )
    ); 

    // Lsfr data check ---------------------------------------------
    always @(posedge clk) begin
        w_lfsr_vld_r  <= w_lfsr_vld ;
        w_lfsr_data_r <= w_lfsr_data;
        w_lfsr_done_r <= w_lfsr_done;
    end

    // error check
    always @(posedge clk) begin
        if (w_lfsr_vld_r & o_lfsr_vld) begin
            if (o_lfsr_data != w_lfsr_data_r) begin
                err_flag <= 1;
            end 
        end 
    end 

    // stop simulation
    reg         stop_sim = 0;
    reg [15:00] stop_sim_dly = 0;
    always@(posedge err_flag) begin
        stop_sim <= 1;
        $monitor($time);
    end 

    always@(posedge clk) begin 
        if(stop_sim)
        begin
            stop_sim_dly <= stop_sim_dly + 1;
            if(stop_sim_dly == 16'h0fFF)
            begin
                stop_sim_dly <= 0;
                stop_sim     <= 0;
                $monitor($time);
                $stop;
            end
        end
    end 

   
endmodule // lsfr_tb