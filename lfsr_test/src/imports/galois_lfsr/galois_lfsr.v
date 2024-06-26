`timescale 1ns / 1ps
//=============================================================================
// File_name    : galois_lfsr.v
// Project_name : project_name.xpr
// Author       : https://github.com/pthuang/
// Function     : Galois lsfr(many-to-one)
//             
// Primitive polynomial is from xilinx document:
// http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
// 
// version: 1.0 
// version: 2.0 Support BIT_WIDTH only include: 3-->20,32,64,128.
// version: 3.0 Support BIT_WIDTH: 3-->168; 
//              Coding style modify to use verilog "for" syntax.
// 
// 
// log:    2021.09.02 create file v1.0 
// log:    2023.03.19 modify file v2.0             [Editing At home on weekends]
// log:    2023.04.08 modify file v3.0             [Editing At home on weekends]
// 
// 
//=============================================================================
module galois_lfsr #
(
    parameter BIT_WIDTH = 8 // 
)
(
    input                       clk         , // 
    input                       rst         , // Optional reset valid high. 
    input                       enable      , // 
    input                       load_evt    , // Optional seed load
    input     [BIT_WIDTH-1:00]  seed_data   , // Optional seed load
    output reg                  lfsr_vld    , // 
    output reg                  lfsr_done   , // 
    output    [BIT_WIDTH-1:00]  lfsr_data     // 
);

//==================< Internal Declaration >============================
    localparam DEFAULT_SEED = 1; // default seed value: x'b0...01 

    reg [BIT_WIDTH-1:00]    seed_latch = DEFAULT_SEED;
    reg [BIT_WIDTH  :01]    x_lfsr     = DEFAULT_SEED;
    reg [BIT_WIDTH-1:00]    fb_vec;
    reg                     seed_load_flag = 0;

    assign lfsr_data = x_lfsr[BIT_WIDTH:1];
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
        lfsr_vld <= 'b0;
    else
        lfsr_vld <= enable;
end

always@(*) begin
    if (lfsr_vld & x_lfsr == seed_latch) begin
        lfsr_done = 1;
    end else begin
        lfsr_done = 0;
    end
end 

always@(posedge clk  or posedge rst) begin
    if(rst) begin
        seed_load_flag <= 0;
    end else begin
        if (enable) begin
            if(load_evt) 
                seed_load_flag<= 1;
            else if(~lfsr_vld & ~seed_load_flag) 
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
always@(posedge clk or posedge rst) begin
    if(rst) begin
        x_lfsr <= DEFAULT_SEED;
    end else begin
        if (enable) begin
            if(load_evt) begin
                x_lfsr <= seed_data;
            end else if(~lfsr_vld & ~seed_load_flag) begin
                x_lfsr <= DEFAULT_SEED;
            end else begin
                x_lfsr[1] <= x_lfsr[BIT_WIDTH] ^ fb_vec[0];
                for (i=2;i<=BIT_WIDTH;i=i+1) begin: x_lfsr_gen
                    x_lfsr[i] <= x_lfsr[i-1] ^ fb_vec[i-1];
                end 
            end
        end
    end
end

//=========================================================================
// tap list grnerate
//=========================================================================
generate
    case(BIT_WIDTH)
    003     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],2'h0}; end end 
    004     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],3'h0}; end end 
    005     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],3'h0}; end end 
    006     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],5'h0}; end end 
    007     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],6'h0}; end end 
    008     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],4'h0}; end end 
    009     : begin always@(*) begin fb_vec = {3'h0,x_lfsr[BIT_WIDTH],5'h0}; end end 
    010     : begin always@(*) begin fb_vec = {2'h0,x_lfsr[BIT_WIDTH],7'h0}; end end 
    011     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],9'h0}; end end 
    012     : begin always@(*) begin fb_vec = {5'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],2'h0,x_lfsr[BIT_WIDTH],1'h0}; end end 
    013     : begin always@(*) begin fb_vec = {8'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],1'h0}; end end 
    014     : begin always@(*) begin fb_vec = {8'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],1'h0}; end end 
    015     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],14'h0}; end end 
    016     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],8'h0,x_lfsr[BIT_WIDTH],4'h0}; end end 
    017     : begin always@(*) begin fb_vec = {2'h0,x_lfsr[BIT_WIDTH],14'h0}; end end 
    018     : begin always@(*) begin fb_vec = {6'h0,x_lfsr[BIT_WIDTH],11'h0}; end end 
    019     : begin always@(*) begin fb_vec = {12'h0,x_lfsr[BIT_WIDTH],3'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],1'h0}; end end 
    020     : begin always@(*) begin fb_vec = {2'h0,x_lfsr[BIT_WIDTH],17'h0}; end end 
    021     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],19'h0}; end end 
    022     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],21'h0}; end end 
    023     : begin always@(*) begin fb_vec = {4'h0,x_lfsr[BIT_WIDTH],18'h0}; end end 
    024     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],4'h0,x_lfsr[BIT_WIDTH],17'h0}; end end 
    025     : begin always@(*) begin fb_vec = {2'h0,x_lfsr[BIT_WIDTH],22'h0}; end end 
    026     : begin always@(*) begin fb_vec = {19'h0,x_lfsr[BIT_WIDTH],3'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],1'h0}; end end 
    027     : begin always@(*) begin fb_vec = {21'h0,x_lfsr[BIT_WIDTH],2'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],1'h0}; end end 
    028     : begin always@(*) begin fb_vec = {2'h0,x_lfsr[BIT_WIDTH],25'h0}; end end 
    029     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],27'h0}; end end 
    030     : begin always@(*) begin fb_vec = {23'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],2'h0,x_lfsr[BIT_WIDTH],1'h0}; end end 
    031     : begin always@(*) begin fb_vec = {2'h0,x_lfsr[BIT_WIDTH],28'h0}; end end 
    032     : begin always@(*) begin fb_vec = {9'h0,x_lfsr[BIT_WIDTH],19'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],1'h0}; end end 
    033     : begin always@(*) begin fb_vec = {12'h0,x_lfsr[BIT_WIDTH],20'h0}; end end 
    034     : begin always@(*) begin fb_vec = {6'h0,x_lfsr[BIT_WIDTH],24'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],1'h0}; end end 
    035     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],33'h0}; end end 
    036     : begin always@(*) begin fb_vec = {10'h0,x_lfsr[BIT_WIDTH],25'h0}; end end 
    037     : begin always@(*) begin fb_vec = {31'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],1'h0}; end end 
    038     : begin always@(*) begin fb_vec = {31'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],3'h0,x_lfsr[BIT_WIDTH],1'h0}; end end 
    039     : begin always@(*) begin fb_vec = {3'h0,x_lfsr[BIT_WIDTH],35'h0}; end end 
    040     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],16'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],19'h0}; end end 
    041     : begin always@(*) begin fb_vec = {2'h0,x_lfsr[BIT_WIDTH],38'h0}; end end 
    042     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],20'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],19'h0}; end end 
    043     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],3'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],37'h0}; end end 
    044     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],24'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],17'h0}; end end 
    045     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],41'h0}; end end 
    046     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],18'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],25'h0}; end end 
    047     : begin always@(*) begin fb_vec = {4'h0,x_lfsr[BIT_WIDTH],42'h0}; end end 
    048     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],25'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],20'h0}; end end 
    049     : begin always@(*) begin fb_vec = {8'h0,x_lfsr[BIT_WIDTH],40'h0}; end end 
    050     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],24'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],23'h0}; end end 
    051     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],13'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],35'h0}; end end 
    052     : begin always@(*) begin fb_vec = {2'h0,x_lfsr[BIT_WIDTH],49'h0}; end end 
    053     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],13'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],37'h0}; end end 
    054     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],34'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],17'h0}; end end 
    055     : begin always@(*) begin fb_vec = {23'h0,x_lfsr[BIT_WIDTH],31'h0}; end end 
    056     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],19'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],34'h0}; end end 
    057     : begin always@(*) begin fb_vec = {6'h0,x_lfsr[BIT_WIDTH],50'h0}; end end 
    058     : begin always@(*) begin fb_vec = {18'h0,x_lfsr[BIT_WIDTH],39'h0}; end end 
    059     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],19'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],37'h0}; end end 
    060     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],59'h0}; end end 
    061     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],13'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],45'h0}; end end 
    062     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],54'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],5'h0}; end end 
    063     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],62'h0}; end end 
    064     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],60'h0}; end end 
    065     : begin always@(*) begin fb_vec = {17'h0,x_lfsr[BIT_WIDTH],47'h0}; end end 
    066     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],7'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],56'h0}; end end 
    067     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],7'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],57'h0}; end end 
    068     : begin always@(*) begin fb_vec = {8'h0,x_lfsr[BIT_WIDTH],59'h0}; end end 
    069     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],24'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],40'h0}; end end 
    070     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],13'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],54'h0}; end end 
    071     : begin always@(*) begin fb_vec = {71'h0}; end end 
    072     : begin always@(*) begin fb_vec = {5'h0,x_lfsr[BIT_WIDTH],40'h0,x_lfsr[BIT_WIDTH],5'h0,x_lfsr[BIT_WIDTH],19'h0}; end end 
    073     : begin always@(*) begin fb_vec = {24'h0,x_lfsr[BIT_WIDTH],48'h0}; end end 
    074     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],13'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],58'h0}; end end 
    075     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],8'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],64'h0}; end end 
    076     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],33'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],40'h0}; end end 
    077     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],28'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],46'h0}; end end 
    078     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],17'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],58'h0}; end end 
    079     : begin always@(*) begin fb_vec = {8'h0,x_lfsr[BIT_WIDTH],70'h0}; end end 
    080     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],35'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],42'h0}; end end 
    081     : begin always@(*) begin fb_vec = {3'h0,x_lfsr[BIT_WIDTH],77'h0}; end end 
    082     : begin always@(*) begin fb_vec = {2'h0,x_lfsr[BIT_WIDTH],31'h0,x_lfsr[BIT_WIDTH],2'h0,x_lfsr[BIT_WIDTH],44'h0}; end end 
    083     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],43'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],37'h0}; end end 
    084     : begin always@(*) begin fb_vec = {12'h0,x_lfsr[BIT_WIDTH],71'h0}; end end 
    085     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],25'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],57'h0}; end end 
    086     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],10'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],73'h0}; end end 
    087     : begin always@(*) begin fb_vec = {12'h0,x_lfsr[BIT_WIDTH],74'h0}; end end 
    088     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],69'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],16'h0}; end end 
    089     : begin always@(*) begin fb_vec = {37'h0,x_lfsr[BIT_WIDTH],51'h0}; end end 
    090     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],16'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],71'h0}; end end 
    091     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],81'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],7'h0}; end end 
    092     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],10'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],79'h0}; end end 
    093     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],91'h0}; end end 
    094     : begin always@(*) begin fb_vec = {20'h0,x_lfsr[BIT_WIDTH],73'h0}; end end 
    095     : begin always@(*) begin fb_vec = {10'h0,x_lfsr[BIT_WIDTH],84'h0}; end end 
    096     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],44'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],47'h0}; end end 
    097     : begin always@(*) begin fb_vec = {5'h0,x_lfsr[BIT_WIDTH],91'h0}; end end 
    098     : begin always@(*) begin fb_vec = {10'h0,x_lfsr[BIT_WIDTH],87'h0}; end end 
    099     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],42'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],52'h0}; end end 
    100     : begin always@(*) begin fb_vec = {36'h0,x_lfsr[BIT_WIDTH],63'h0}; end end 
    101     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],4'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],94'h0}; end end 
    102     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],64'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],35'h0}; end end 
    103     : begin always@(*) begin fb_vec = {8'h0,x_lfsr[BIT_WIDTH],94'h0}; end end 
    104     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],8'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],93'h0}; end end 
    105     : begin always@(*) begin fb_vec = {15'h0,x_lfsr[BIT_WIDTH],89'h0}; end end 
    106     : begin always@(*) begin fb_vec = {14'h0,x_lfsr[BIT_WIDTH],91'h0}; end end 
    107     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],60'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],42'h0}; end end 
    108     : begin always@(*) begin fb_vec = {30'h0,x_lfsr[BIT_WIDTH],77'h0}; end end 
    109     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],4'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],102'h0}; end end 
    110     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],10'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],97'h0}; end end 
    111     : begin always@(*) begin fb_vec = {9'h0,x_lfsr[BIT_WIDTH],101'h0}; end end 
    112     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],40'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],67'h0}; end end 
    113     : begin always@(*) begin fb_vec = {8'h0,x_lfsr[BIT_WIDTH],104'h0}; end end 
    114     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],79'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],32'h0}; end end 
    115     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],12'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],100'h0}; end end 
    116     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],68'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],45'h0}; end end 
    117     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],15'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],97'h0}; end end 
    118     : begin always@(*) begin fb_vec = {32'h0,x_lfsr[BIT_WIDTH],85'h0}; end end 
    119     : begin always@(*) begin fb_vec = {7'h0,x_lfsr[BIT_WIDTH],111'h0}; end end 
    120     : begin always@(*) begin fb_vec = {6'h0,x_lfsr[BIT_WIDTH],103'h0,x_lfsr[BIT_WIDTH],6'h0,x_lfsr[BIT_WIDTH],2'h0}; end end 
    121     : begin always@(*) begin fb_vec = {17'h0,x_lfsr[BIT_WIDTH],103'h0}; end end 
    122     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],57'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],62'h0}; end end 
    123     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],121'h0}; end end 
    124     : begin always@(*) begin fb_vec = {36'h0,x_lfsr[BIT_WIDTH],87'h0}; end end 
    125     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],105'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],17'h0}; end end 
    126     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],34'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],89'h0}; end end 
    127     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],126'h0}; end end 
    128     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],24'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],99'h0}; end end 
    129     : begin always@(*) begin fb_vec = {4'h0,x_lfsr[BIT_WIDTH],124'h0}; end end 
    130     : begin always@(*) begin fb_vec = {2'h0,x_lfsr[BIT_WIDTH],127'h0}; end end 
    131     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],45'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],83'h0}; end end 
    132     : begin always@(*) begin fb_vec = {28'h0,x_lfsr[BIT_WIDTH],103'h0}; end end 
    133     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],49'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],81'h0}; end end 
    134     : begin always@(*) begin fb_vec = {56'h0,x_lfsr[BIT_WIDTH],77'h0}; end end 
    135     : begin always@(*) begin fb_vec = {10'h0,x_lfsr[BIT_WIDTH],124'h0}; end end 
    136     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],123'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],10'h0}; end end 
    137     : begin always@(*) begin fb_vec = {20'h0,x_lfsr[BIT_WIDTH],116'h0}; end end 
    138     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],5'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],130'h0}; end end 
    139     : begin always@(*) begin fb_vec = {2'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],2'h0,x_lfsr[BIT_WIDTH],131'h0}; end end 
    140     : begin always@(*) begin fb_vec = {28'h0,x_lfsr[BIT_WIDTH],111'h0}; end end 
    141     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],140'h0}; end end 
    142     : begin always@(*) begin fb_vec = {20'h0,x_lfsr[BIT_WIDTH],121'h0}; end end 
    143     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],18'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],122'h0}; end end 
    144     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],67'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],74'h0}; end end 
    145     : begin always@(*) begin fb_vec = {51'h0,x_lfsr[BIT_WIDTH],93'h0}; end end 
    146     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],57'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],86'h0}; end end 
    147     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],35'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],109'h0}; end end 
    148     : begin always@(*) begin fb_vec = {26'h0,x_lfsr[BIT_WIDTH],121'h0}; end end 
    149     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],107'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],39'h0}; end end 
    150     : begin always@(*) begin fb_vec = {52'h0,x_lfsr[BIT_WIDTH],97'h0}; end end 
    151     : begin always@(*) begin fb_vec = {2'h0,x_lfsr[BIT_WIDTH],148'h0}; end end 
    152     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],63'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],86'h0}; end end 
    153     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],152'h0}; end end 
    154     : begin always@(*) begin fb_vec = {126'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],25'h0}; end end 
    155     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],29'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],123'h0}; end end 
    156     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],113'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],40'h0}; end end 
    157     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],24'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],130'h0}; end end 
    158     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],24'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],131'h0}; end end 
    159     : begin always@(*) begin fb_vec = {30'h0,x_lfsr[BIT_WIDTH],128'h0}; end end 
    160     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],16'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],141'h0}; end end 
    161     : begin always@(*) begin fb_vec = {17'h0,x_lfsr[BIT_WIDTH],143'h0}; end end 
    162     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],85'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],74'h0}; end end 
    163     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],57'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],103'h0}; end end 
    164     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],11'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],150'h0}; end end 
    165     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],28'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],134'h0}; end end 
    166     : begin always@(*) begin fb_vec = {x_lfsr[BIT_WIDTH],36'h0,x_lfsr[BIT_WIDTH],x_lfsr[BIT_WIDTH],127'h0}; end end 
    167     : begin always@(*) begin fb_vec = {5'h0,x_lfsr[BIT_WIDTH],161'h0}; end end 
    168     : begin always@(*) begin fb_vec = {1'h0,x_lfsr[BIT_WIDTH],12'h0,x_lfsr[BIT_WIDTH],1'h0,x_lfsr[BIT_WIDTH],151'h0}; end end 
    default : begin always@(*) begin fb_vec = 0; end end
    endcase
endgenerate




//=================< Submodule Instantiation >==========================





endmodule
