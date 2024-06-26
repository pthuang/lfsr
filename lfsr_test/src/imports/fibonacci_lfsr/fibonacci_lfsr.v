`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// Description: 
// A lfsr or Linear Feedback Shift Register is a quick and easy way to generate
// pseudo-random data inside of an FPGA.  The lfsr can be used for things like
// counters, test patterns, scrambling of data, and others.  This module
// creates an lfsr whose width gets set by a parameter.  The lfsr_done will
// pulse once all combinations of the lfsr are complete.  The number of clock
// cycles that it takes lfsr_done to pulse is equal to 2^g_Num_Bits-1.  For
// example setting g_Num_Bits to 5 means that lfsr_done will pulse every
// 2^5-1 = 31 clock cycles.  lfsr_data will change on each clock cycle that
// the module is enabled, which can be used if desired.
//
// Parameters:
// BIT_WIDTH - Set to the integer number of bits wide to create your lfsr.
///////////////////////////////////////////////////////////////////////////////

//=============================================================================
// File_name    : fibonacci_lfsr.v
// Project_name : project_name.xpr
// Author       : https://github.com/pthuang/
// Function     : Fibonacci lfsr(many-to-one)
//                File modified on the LFSR.v from "https://www.nandland.com"
// 
// The first thing you need to know is that this is a Fibonacci LSFR. So it may
// have error bits when it runs in a very high frequencies, but it's safety in 
// low frequencies. 
// 
// Golais LSFR is more safely and effectively in high frequencies.
// 
// Primitive polynomial is from xilinx document:
// http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
// 
// version: 1.0 
// 
// 
// log:    2023.03.19 modify file v1.0           [Editing At home on weekends]
//             1. Add reset io signal;
//             2. Modify some signal name;
//             3. Add lfsr_vld signal for cascade and easy-to-use;
//             4. Extend BIT_WIDTH from 32 to 168;
//             5. modify r_xnor wire logic from [always(*)] to [generate case]
//                syntax to reduce resource overhead.    
// 
// 
//=============================================================================
module fibonacci_lfsr #
(
    parameter BIT_WIDTH  = 8                  // maximum: 168
)
(         
    input                       clk         , // 
    input                       rst         , // Optional reset valid high
    input                       enable      , // 
    input                       load_evt    , // Optional Seed Value
    input     [BIT_WIDTH-1:0]   seed_data   , // 
    output reg                  lfsr_vld    , // 
    output                      lfsr_done   , // 
    output    [BIT_WIDTH-1:0]   lfsr_data     // 
);   
    
    localparam DEFAULT_SEED = 1; // default seed value: x'b0...01 

    reg [BIT_WIDTH-1:0] seed_latch = DEFAULT_SEED; 
    reg [BIT_WIDTH  :1] r_lfsr     = DEFAULT_SEED;
    wire                r_xnor                   ;
    reg                 seed_load_flag = 0;

    assign lfsr_data = r_lfsr[BIT_WIDTH:1];
    assign lfsr_done = (lfsr_vld & r_lfsr[BIT_WIDTH:1] == seed_latch) ? 1'b1 : 1'b0;


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
        if (rst) begin
            lfsr_vld <= 0; 
        end else begin
            lfsr_vld <= enable;
        end
    end 

    // Purpose: Load up lfsr with Seed if load_evt pulse is detected.
    // Othewise just run lfsr when enabled.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_lfsr <= DEFAULT_SEED; 
            seed_load_flag <= 0;
        end else begin
            if (enable) begin
                if (load_evt == 1'b1) begin
                    r_lfsr <= seed_data;
                    seed_load_flag <= 1;
                end else if (~lfsr_vld & ~seed_load_flag) begin
                    r_lfsr <= DEFAULT_SEED;
                    seed_load_flag <= 1;
                end else begin
                    r_lfsr <= {r_lfsr[BIT_WIDTH-1:1], r_xnor};
                    seed_load_flag <= seed_load_flag;
                end
            end
        end 
    end

    // Create Feedback Polynomials.  Based on Application Note:
    // http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
    generate
        case(BIT_WIDTH)
        003     : assign r_xnor = r_lfsr[003] ^~ r_lfsr[002];
        004     : assign r_xnor = r_lfsr[004] ^~ r_lfsr[003];
        005     : assign r_xnor = r_lfsr[005] ^~ r_lfsr[003];
        006     : assign r_xnor = r_lfsr[006] ^~ r_lfsr[005];
        007     : assign r_xnor = r_lfsr[007] ^~ r_lfsr[006];
        008     : assign r_xnor = r_lfsr[008] ^~ r_lfsr[006] ^~ r_lfsr[005] ^~ r_lfsr[004];
        009     : assign r_xnor = r_lfsr[009] ^~ r_lfsr[005];
        010     : assign r_xnor = r_lfsr[010] ^~ r_lfsr[007];
        011     : assign r_xnor = r_lfsr[011] ^~ r_lfsr[009];
        012     : assign r_xnor = r_lfsr[012] ^~ r_lfsr[006] ^~ r_lfsr[004] ^~ r_lfsr[001];
        013     : assign r_xnor = r_lfsr[013] ^~ r_lfsr[004] ^~ r_lfsr[003] ^~ r_lfsr[001];
        014     : assign r_xnor = r_lfsr[014] ^~ r_lfsr[005] ^~ r_lfsr[003] ^~ r_lfsr[001];
        015     : assign r_xnor = r_lfsr[015] ^~ r_lfsr[014];
        016     : assign r_xnor = r_lfsr[016] ^~ r_lfsr[015] ^~ r_lfsr[013] ^~ r_lfsr[004];
        017     : assign r_xnor = r_lfsr[017] ^~ r_lfsr[014];
        018     : assign r_xnor = r_lfsr[018] ^~ r_lfsr[011];
        019     : assign r_xnor = r_lfsr[019] ^~ r_lfsr[006] ^~ r_lfsr[002] ^~ r_lfsr[001];
        020     : assign r_xnor = r_lfsr[020] ^~ r_lfsr[017];
        021     : assign r_xnor = r_lfsr[021] ^~ r_lfsr[019];
        022     : assign r_xnor = r_lfsr[022] ^~ r_lfsr[021];
        023     : assign r_xnor = r_lfsr[023] ^~ r_lfsr[018];
        024     : assign r_xnor = r_lfsr[024] ^~ r_lfsr[023] ^~ r_lfsr[022] ^~ r_lfsr[017];
        025     : assign r_xnor = r_lfsr[025] ^~ r_lfsr[022];
        026     : assign r_xnor = r_lfsr[026] ^~ r_lfsr[006] ^~ r_lfsr[002] ^~ r_lfsr[001];
        027     : assign r_xnor = r_lfsr[027] ^~ r_lfsr[005] ^~ r_lfsr[002] ^~ r_lfsr[001];
        028     : assign r_xnor = r_lfsr[028] ^~ r_lfsr[025];
        029     : assign r_xnor = r_lfsr[029] ^~ r_lfsr[027];
        030     : assign r_xnor = r_lfsr[030] ^~ r_lfsr[006] ^~ r_lfsr[004] ^~ r_lfsr[001];
        031     : assign r_xnor = r_lfsr[031] ^~ r_lfsr[028];
        032     : assign r_xnor = r_lfsr[032] ^~ r_lfsr[022] ^~ r_lfsr[002] ^~ r_lfsr[001];
        033     : assign r_xnor = r_lfsr[033] ^~ r_lfsr[020];
        034     : assign r_xnor = r_lfsr[034] ^~ r_lfsr[027] ^~ r_lfsr[002] ^~ r_lfsr[001];
        035     : assign r_xnor = r_lfsr[035] ^~ r_lfsr[033];
        036     : assign r_xnor = r_lfsr[036] ^~ r_lfsr[025];
        037     : assign r_xnor = r_lfsr[037] ^~ r_lfsr[005] ^~ r_lfsr[004] ^~ r_lfsr[003] ^~ r_lfsr[002] ^~ r_lfsr[001];
        038     : assign r_xnor = r_lfsr[038] ^~ r_lfsr[006] ^~ r_lfsr[005] ^~ r_lfsr[001];
        039     : assign r_xnor = r_lfsr[039] ^~ r_lfsr[035];
        040     : assign r_xnor = r_lfsr[040] ^~ r_lfsr[038] ^~ r_lfsr[021] ^~ r_lfsr[019];
        041     : assign r_xnor = r_lfsr[041] ^~ r_lfsr[038];
        042     : assign r_xnor = r_lfsr[042] ^~ r_lfsr[041] ^~ r_lfsr[020] ^~ r_lfsr[019];
        043     : assign r_xnor = r_lfsr[043] ^~ r_lfsr[042] ^~ r_lfsr[038] ^~ r_lfsr[037];
        044     : assign r_xnor = r_lfsr[044] ^~ r_lfsr[043] ^~ r_lfsr[018] ^~ r_lfsr[017];
        045     : assign r_xnor = r_lfsr[045] ^~ r_lfsr[044] ^~ r_lfsr[042] ^~ r_lfsr[041];
        046     : assign r_xnor = r_lfsr[046] ^~ r_lfsr[045] ^~ r_lfsr[026] ^~ r_lfsr[025];
        047     : assign r_xnor = r_lfsr[047] ^~ r_lfsr[042];
        048     : assign r_xnor = r_lfsr[048] ^~ r_lfsr[047] ^~ r_lfsr[021] ^~ r_lfsr[020];
        049     : assign r_xnor = r_lfsr[049] ^~ r_lfsr[040];
        050     : assign r_xnor = r_lfsr[050] ^~ r_lfsr[049] ^~ r_lfsr[024] ^~ r_lfsr[023];
        051     : assign r_xnor = r_lfsr[051] ^~ r_lfsr[050] ^~ r_lfsr[036] ^~ r_lfsr[035];
        052     : assign r_xnor = r_lfsr[052] ^~ r_lfsr[049];
        053     : assign r_xnor = r_lfsr[053] ^~ r_lfsr[052] ^~ r_lfsr[038] ^~ r_lfsr[037];
        054     : assign r_xnor = r_lfsr[054] ^~ r_lfsr[053] ^~ r_lfsr[018] ^~ r_lfsr[017];
        055     : assign r_xnor = r_lfsr[055] ^~ r_lfsr[031];
        056     : assign r_xnor = r_lfsr[056] ^~ r_lfsr[055] ^~ r_lfsr[035] ^~ r_lfsr[034];
        057     : assign r_xnor = r_lfsr[057] ^~ r_lfsr[050];
        058     : assign r_xnor = r_lfsr[058] ^~ r_lfsr[039];
        059     : assign r_xnor = r_lfsr[059] ^~ r_lfsr[058] ^~ r_lfsr[038] ^~ r_lfsr[037];
        060     : assign r_xnor = r_lfsr[060] ^~ r_lfsr[059];
        061     : assign r_xnor = r_lfsr[061] ^~ r_lfsr[060] ^~ r_lfsr[046] ^~ r_lfsr[045];
        062     : assign r_xnor = r_lfsr[062] ^~ r_lfsr[061] ^~ r_lfsr[006] ^~ r_lfsr[005];
        063     : assign r_xnor = r_lfsr[063] ^~ r_lfsr[062];
        064     : assign r_xnor = r_lfsr[064] ^~ r_lfsr[063] ^~ r_lfsr[061] ^~ r_lfsr[060];
        065     : assign r_xnor = r_lfsr[065] ^~ r_lfsr[047];
        066     : assign r_xnor = r_lfsr[066] ^~ r_lfsr[065] ^~ r_lfsr[057] ^~ r_lfsr[056];
        067     : assign r_xnor = r_lfsr[067] ^~ r_lfsr[066] ^~ r_lfsr[058] ^~ r_lfsr[057];
        068     : assign r_xnor = r_lfsr[068] ^~ r_lfsr[059];
        069     : assign r_xnor = r_lfsr[069] ^~ r_lfsr[067] ^~ r_lfsr[042] ^~ r_lfsr[040];
        070     : assign r_xnor = r_lfsr[070] ^~ r_lfsr[069] ^~ r_lfsr[055] ^~ r_lfsr[054];
        071     : assign r_xnor = r_lfsr[071];
        072     : assign r_xnor = r_lfsr[072] ^~ r_lfsr[066] ^~ r_lfsr[025] ^~ r_lfsr[019];
        073     : assign r_xnor = r_lfsr[073] ^~ r_lfsr[048];
        074     : assign r_xnor = r_lfsr[074] ^~ r_lfsr[073] ^~ r_lfsr[059] ^~ r_lfsr[058];
        075     : assign r_xnor = r_lfsr[075] ^~ r_lfsr[074] ^~ r_lfsr[065] ^~ r_lfsr[064];
        076     : assign r_xnor = r_lfsr[076] ^~ r_lfsr[075] ^~ r_lfsr[041] ^~ r_lfsr[040];
        077     : assign r_xnor = r_lfsr[077] ^~ r_lfsr[076] ^~ r_lfsr[047] ^~ r_lfsr[046];
        078     : assign r_xnor = r_lfsr[078] ^~ r_lfsr[077] ^~ r_lfsr[059] ^~ r_lfsr[058];
        079     : assign r_xnor = r_lfsr[079] ^~ r_lfsr[070];
        080     : assign r_xnor = r_lfsr[080] ^~ r_lfsr[079] ^~ r_lfsr[043] ^~ r_lfsr[042];
        081     : assign r_xnor = r_lfsr[081] ^~ r_lfsr[077];
        082     : assign r_xnor = r_lfsr[082] ^~ r_lfsr[079] ^~ r_lfsr[047] ^~ r_lfsr[044];
        083     : assign r_xnor = r_lfsr[083] ^~ r_lfsr[082] ^~ r_lfsr[038] ^~ r_lfsr[037];
        084     : assign r_xnor = r_lfsr[084] ^~ r_lfsr[071];
        085     : assign r_xnor = r_lfsr[085] ^~ r_lfsr[084] ^~ r_lfsr[058] ^~ r_lfsr[057];
        086     : assign r_xnor = r_lfsr[086] ^~ r_lfsr[085] ^~ r_lfsr[074] ^~ r_lfsr[073];
        087     : assign r_xnor = r_lfsr[087] ^~ r_lfsr[074];
        088     : assign r_xnor = r_lfsr[088] ^~ r_lfsr[087] ^~ r_lfsr[017] ^~ r_lfsr[016];
        089     : assign r_xnor = r_lfsr[089] ^~ r_lfsr[051];
        090     : assign r_xnor = r_lfsr[090] ^~ r_lfsr[089] ^~ r_lfsr[072] ^~ r_lfsr[071];
        091     : assign r_xnor = r_lfsr[091] ^~ r_lfsr[090] ^~ r_lfsr[008] ^~ r_lfsr[007];
        092     : assign r_xnor = r_lfsr[092] ^~ r_lfsr[091] ^~ r_lfsr[080] ^~ r_lfsr[079];
        093     : assign r_xnor = r_lfsr[093] ^~ r_lfsr[091];
        094     : assign r_xnor = r_lfsr[094] ^~ r_lfsr[073];
        095     : assign r_xnor = r_lfsr[095] ^~ r_lfsr[084];
        096     : assign r_xnor = r_lfsr[096] ^~ r_lfsr[094] ^~ r_lfsr[049] ^~ r_lfsr[047];
        097     : assign r_xnor = r_lfsr[097] ^~ r_lfsr[091];
        098     : assign r_xnor = r_lfsr[098] ^~ r_lfsr[087];
        099     : assign r_xnor = r_lfsr[099] ^~ r_lfsr[097] ^~ r_lfsr[054] ^~ r_lfsr[052];
        100     : assign r_xnor = r_lfsr[100] ^~ r_lfsr[063];
        101     : assign r_xnor = r_lfsr[101] ^~ r_lfsr[100] ^~ r_lfsr[095] ^~ r_lfsr[094];
        102     : assign r_xnor = r_lfsr[102] ^~ r_lfsr[101] ^~ r_lfsr[036] ^~ r_lfsr[035];
        103     : assign r_xnor = r_lfsr[103] ^~ r_lfsr[094];
        104     : assign r_xnor = r_lfsr[104] ^~ r_lfsr[103] ^~ r_lfsr[094] ^~ r_lfsr[093];
        105     : assign r_xnor = r_lfsr[105] ^~ r_lfsr[089];
        106     : assign r_xnor = r_lfsr[106] ^~ r_lfsr[091];
        107     : assign r_xnor = r_lfsr[107] ^~ r_lfsr[105] ^~ r_lfsr[044] ^~ r_lfsr[042];
        108     : assign r_xnor = r_lfsr[108] ^~ r_lfsr[077];
        109     : assign r_xnor = r_lfsr[109] ^~ r_lfsr[108] ^~ r_lfsr[103] ^~ r_lfsr[102];
        110     : assign r_xnor = r_lfsr[110] ^~ r_lfsr[109] ^~ r_lfsr[098] ^~ r_lfsr[097];
        111     : assign r_xnor = r_lfsr[111] ^~ r_lfsr[101];
        112     : assign r_xnor = r_lfsr[112] ^~ r_lfsr[110] ^~ r_lfsr[069] ^~ r_lfsr[067];
        113     : assign r_xnor = r_lfsr[113] ^~ r_lfsr[104];
        114     : assign r_xnor = r_lfsr[114] ^~ r_lfsr[113] ^~ r_lfsr[033] ^~ r_lfsr[032];
        115     : assign r_xnor = r_lfsr[115] ^~ r_lfsr[114] ^~ r_lfsr[101] ^~ r_lfsr[100];
        116     : assign r_xnor = r_lfsr[116] ^~ r_lfsr[115] ^~ r_lfsr[046] ^~ r_lfsr[045];
        117     : assign r_xnor = r_lfsr[117] ^~ r_lfsr[115] ^~ r_lfsr[099] ^~ r_lfsr[097];
        118     : assign r_xnor = r_lfsr[118] ^~ r_lfsr[085];
        119     : assign r_xnor = r_lfsr[119] ^~ r_lfsr[111];
        120     : assign r_xnor = r_lfsr[120] ^~ r_lfsr[113] ^~ r_lfsr[009] ^~ r_lfsr[002];
        121     : assign r_xnor = r_lfsr[121] ^~ r_lfsr[103];
        122     : assign r_xnor = r_lfsr[122] ^~ r_lfsr[121] ^~ r_lfsr[063] ^~ r_lfsr[062];
        123     : assign r_xnor = r_lfsr[123] ^~ r_lfsr[121];
        124     : assign r_xnor = r_lfsr[124] ^~ r_lfsr[087];
        125     : assign r_xnor = r_lfsr[125] ^~ r_lfsr[124] ^~ r_lfsr[018] ^~ r_lfsr[017];
        126     : assign r_xnor = r_lfsr[126] ^~ r_lfsr[125] ^~ r_lfsr[090] ^~ r_lfsr[089];
        127     : assign r_xnor = r_lfsr[127] ^~ r_lfsr[126];
        128     : assign r_xnor = r_lfsr[128] ^~ r_lfsr[126] ^~ r_lfsr[101] ^~ r_lfsr[099];
        129     : assign r_xnor = r_lfsr[129] ^~ r_lfsr[124];
        130     : assign r_xnor = r_lfsr[130] ^~ r_lfsr[127];
        131     : assign r_xnor = r_lfsr[131] ^~ r_lfsr[130] ^~ r_lfsr[084] ^~ r_lfsr[083];
        132     : assign r_xnor = r_lfsr[132] ^~ r_lfsr[103];
        133     : assign r_xnor = r_lfsr[133] ^~ r_lfsr[132] ^~ r_lfsr[082] ^~ r_lfsr[081];
        134     : assign r_xnor = r_lfsr[134] ^~ r_lfsr[077];
        135     : assign r_xnor = r_lfsr[135] ^~ r_lfsr[124];
        136     : assign r_xnor = r_lfsr[136] ^~ r_lfsr[135] ^~ r_lfsr[011] ^~ r_lfsr[010];
        137     : assign r_xnor = r_lfsr[137] ^~ r_lfsr[116];
        138     : assign r_xnor = r_lfsr[138] ^~ r_lfsr[137] ^~ r_lfsr[131] ^~ r_lfsr[130];
        139     : assign r_xnor = r_lfsr[139] ^~ r_lfsr[136] ^~ r_lfsr[134] ^~ r_lfsr[131];
        140     : assign r_xnor = r_lfsr[140] ^~ r_lfsr[111];
        141     : assign r_xnor = r_lfsr[141] ^~ r_lfsr[140];
        142     : assign r_xnor = r_lfsr[142] ^~ r_lfsr[121];
        143     : assign r_xnor = r_lfsr[143] ^~ r_lfsr[142] ^~ r_lfsr[123] ^~ r_lfsr[122];
        144     : assign r_xnor = r_lfsr[144] ^~ r_lfsr[143] ^~ r_lfsr[075] ^~ r_lfsr[074];
        145     : assign r_xnor = r_lfsr[145] ^~ r_lfsr[093];
        146     : assign r_xnor = r_lfsr[146] ^~ r_lfsr[145] ^~ r_lfsr[087] ^~ r_lfsr[086];
        147     : assign r_xnor = r_lfsr[147] ^~ r_lfsr[146] ^~ r_lfsr[110] ^~ r_lfsr[109];
        148     : assign r_xnor = r_lfsr[148] ^~ r_lfsr[121];
        149     : assign r_xnor = r_lfsr[149] ^~ r_lfsr[148] ^~ r_lfsr[040] ^~ r_lfsr[039];
        150     : assign r_xnor = r_lfsr[150] ^~ r_lfsr[097];
        151     : assign r_xnor = r_lfsr[151] ^~ r_lfsr[148];
        152     : assign r_xnor = r_lfsr[152] ^~ r_lfsr[151] ^~ r_lfsr[087] ^~ r_lfsr[086];
        153     : assign r_xnor = r_lfsr[153] ^~ r_lfsr[152];
        154     : assign r_xnor = r_lfsr[154] ^~ r_lfsr[027] ^~ r_lfsr[025];
        155     : assign r_xnor = r_lfsr[155] ^~ r_lfsr[154] ^~ r_lfsr[124] ^~ r_lfsr[123];
        156     : assign r_xnor = r_lfsr[156] ^~ r_lfsr[155] ^~ r_lfsr[041] ^~ r_lfsr[040];
        157     : assign r_xnor = r_lfsr[157] ^~ r_lfsr[156] ^~ r_lfsr[131] ^~ r_lfsr[130];
        158     : assign r_xnor = r_lfsr[158] ^~ r_lfsr[157] ^~ r_lfsr[132] ^~ r_lfsr[131];
        159     : assign r_xnor = r_lfsr[159] ^~ r_lfsr[128];
        160     : assign r_xnor = r_lfsr[160] ^~ r_lfsr[159] ^~ r_lfsr[142] ^~ r_lfsr[141];
        161     : assign r_xnor = r_lfsr[161] ^~ r_lfsr[143];
        162     : assign r_xnor = r_lfsr[162] ^~ r_lfsr[161] ^~ r_lfsr[075] ^~ r_lfsr[074];
        163     : assign r_xnor = r_lfsr[163] ^~ r_lfsr[162] ^~ r_lfsr[104] ^~ r_lfsr[103];
        164     : assign r_xnor = r_lfsr[164] ^~ r_lfsr[163] ^~ r_lfsr[151] ^~ r_lfsr[150];
        165     : assign r_xnor = r_lfsr[165] ^~ r_lfsr[164] ^~ r_lfsr[135] ^~ r_lfsr[134];
        166     : assign r_xnor = r_lfsr[166] ^~ r_lfsr[165] ^~ r_lfsr[128] ^~ r_lfsr[127];
        167     : assign r_xnor = r_lfsr[167] ^~ r_lfsr[161];
        168     : assign r_xnor = r_lfsr[168] ^~ r_lfsr[166] ^~ r_lfsr[153] ^~ r_lfsr[151];
        endcase
    endgenerate
    
 
endmodule // lfsr