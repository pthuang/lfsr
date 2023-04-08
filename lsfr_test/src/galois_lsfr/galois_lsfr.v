//=============================================================================
// File_name    : galois_lsfr.v
// Project_name : project_name.xpr
// Author       : weitao_cn@163.com
// Function     : Galois lsfr(many-to-one)
//             
// Primitive polynomial is from xilinx document:
// http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
// 
// version: 1.0 
// version: 2.0 Support BIT_WIDTH only include: 3-->20,32,64,128.
// 
// 
// log:    2021.09.02 create file v1.0 
// log:    2023.03.19 modify file v2.0             [Editing At home on weekends]
// 
// 
//=============================================================================
module galois_lsfr #
(
    parameter BIT_WIDTH = 8 // 
)
(
    input                       clk         ,
    input                       rst         , // Optional reset valid high. 
    input                       enable      , 
    input                       load_evt    , // Optional seed load
    input     [BIT_WIDTH-1:00]  seed_data   , // Optional seed load
    output reg                  lsfr_vld    ,
    output reg                  lsfr_done   , 
    output    [BIT_WIDTH-1:00]  lsfr_data   
);

//==================< Internal Declaration >============================
    localparam DEFAULT_SEED = 1; // default seed value: x'b0...01 

    reg [BIT_WIDTH-1:00]    seed_latch = DEFAULT_SEED;
    reg [BIT_WIDTH  :01]    x_lsfr     = DEFAULT_SEED;
    reg [BIT_WIDTH-1:00]    fb_vec;
    reg                     seed_load_flag = 0;

    assign lsfr_data = x_lsfr[BIT_WIDTH:1];
//=======================< Debug Logic >================================



//=======================< Main Logic >=================================
always @(posedge clk or posedge rst) begin
    if (rst) begin
        seed_latch <= DEFAULT_SEED;
    end else begin
        if (enable & load_evt) begin
            seed_latch <= seed_data;
        end 
    end
end 

always @(posedge clk or posedge rst) begin
    if (rst)
        lsfr_vld <= 'b0;
    else
        lsfr_vld <= enable;
end

always@(*) begin
    if (lsfr_vld & x_lsfr == seed_latch) begin
        lsfr_done = 1;
    end else begin
        lsfr_done = 0;
    end
end 

always@(posedge clk  or posedge rst) begin
    if(rst) begin
        seed_load_flag <= 0;
    end else begin
        if (enable) begin
            if(load_evt) 
                seed_load_flag<= 1;
            else if(~lsfr_vld & ~seed_load_flag) 
                seed_load_flag<= 1;
            else 
                seed_load_flag<= seed_load_flag; 
        end
    end
end

//=========================================================================
// LSFR grnerate
//=========================================================================
integer i;
always@(posedge clk  or posedge rst) begin
    if(rst) begin
        x_lsfr <= DEFAULT_SEED;
    end else begin
        if (enable) begin
            if(load_evt) begin
                x_lsfr <= seed_data;
            end else if(~lsfr_vld & ~seed_load_flag) begin
                x_lsfr <= DEFAULT_SEED;
            end else begin
                x_lsfr[1] <= x_lsfr[BIT_WIDTH] ^ fb_vec[0];
                for (i=2;i<=BIT_WIDTH;i=i+1) begin: x_lsfr_gen
                    x_lsfr[i] <= x_lsfr[i-1] ^ fb_vec[i-1];
                end 
            end
        end
    end
end



generate
    case(BIT_WIDTH)
    003: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[02]                      } = x_lsfr[BIT_WIDTH]     ; {fb_vec[01:00]                                    } = 0; end end end // [3,2]
    004: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[03]                      } = x_lsfr[BIT_WIDTH]     ; {fb_vec[02:00]                                    } = 0; end end end // [4,3]
    005: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[03]                      } = x_lsfr[BIT_WIDTH]     ; {fb_vec[04   ],fb_vec[02:00]                      } = 0; end end end // [5,3]
    006: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[05]                      } = x_lsfr[BIT_WIDTH]     ; {fb_vec[04:00]                                    } = 0; end end end // [6,5]
    007: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[06]                      } = x_lsfr[BIT_WIDTH]     ; {fb_vec[05:00]                                    } = 0; end end end // [7,6]
    008: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[06:04]                   } = {3{x_lsfr[BIT_WIDTH]}}; {fb_vec[07   ],fb_vec[03:00]                      } = 0; end end end // [8,6,5,4]
    009: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[05]                      } = x_lsfr[BIT_WIDTH]     ; {fb_vec[08:06],fb_vec[04:00]                      } = 0; end end end // [9,5]
    010: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[07]                      } = x_lsfr[BIT_WIDTH]     ; {fb_vec[09:08],fb_vec[06:00]                      } = 0; end end end // [10,7]
    011: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[09]                      } = x_lsfr[BIT_WIDTH]     ; {fb_vec[10   ],fb_vec[08:00]                      } = 0; end end end // [11,9]
    012: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[06],fb_vec[04],fb_vec[01]} = {3{x_lsfr[BIT_WIDTH]}}; {fb_vec[11:07],fb_vec[05],fb_vec[03:02],fb_vec[00]} = 0; end end end // [12,6.4.1]
    013: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[04],fb_vec[03],fb_vec[01]} = {3{x_lsfr[BIT_WIDTH]}}; {fb_vec[12:05],fb_vec[02],fb_vec[00]              } = 0; end end end // [13,4.3.1]
    014: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[05],fb_vec[03],fb_vec[01]} = {3{x_lsfr[BIT_WIDTH]}}; {fb_vec[13:06],fb_vec[04],fb_vec[02],fb_vec[00]   } = 0; end end end // [14,5.3.1]
    015: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[14]                      } = x_lsfr[BIT_WIDTH]     ; {fb_vec[13:00]                                    } = 0; end end end // [15,14]
    016: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[15],fb_vec[13],fb_vec[04]} = {3{x_lsfr[BIT_WIDTH]}}; {fb_vec[14],fb_vec[12:05],fb_vec[03:00]           } = 0; end end end // [16,15,13,4]
    017: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[14]                      } = x_lsfr[BIT_WIDTH]     ; {fb_vec[16:15],fb_vec[13:00]                      } = 0; end end end // [17,14]
    018: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[11]                      } = x_lsfr[BIT_WIDTH]     ; {fb_vec[17:12],fb_vec[10:00]                      } = 0; end end end // [18,11]
    019: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[06],fb_vec[02],fb_vec[01]} = {3{x_lsfr[BIT_WIDTH]}}; {fb_vec[18:07],fb_vec[05:03],fb_vec[00]           } = 0; end end end // [19,6,2,1]
    020: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[17]                      } = x_lsfr[BIT_WIDTH]     ; {fb_vec[19:18],fb_vec[16:00]                      } = 0; end end end // [20,17]
    // ......
    032: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[22],fb_vec[02],fb_vec[01]} = {3{x_lsfr[BIT_WIDTH]}}; {fb_vec[31:23],fb_vec[21:03],fb_vec[00]           } = 0; end end end // [32,22,2,1]
    // ......
    064: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[63],fb_vec[61],fb_vec[60]} = {3{x_lsfr[BIT_WIDTH]}}; {fb_vec[62],fb_vec[59:00]                         } = 0; end end end // [64,63,61,60]
    // ......
    128: begin: fb_vec_gen always@(*) begin if(enable) begin {fb_vec[126],fb_vec[101],fb_vec[99]} = {3{x_lsfr[BIT_WIDTH]}}; {fb_vec[127],fb_vec[125:102],fb_vec[100],fb_vec[98:00]} = 0; end end end // [128,126,101,99]
    // ......
    endcase
endgenerate





//=================< Submodule Instantiation >==========================





endmodule
