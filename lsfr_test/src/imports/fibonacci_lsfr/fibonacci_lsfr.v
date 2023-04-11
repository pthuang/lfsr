///////////////////////////////////////////////////////////////////////////////
// Description: 
// A lsfr or Linear Feedback Shift Register is a quick and easy way to generate
// pseudo-random data inside of an FPGA.  The lsfr can be used for things like
// counters, test patterns, scrambling of data, and others.  This module
// creates an lsfr whose width gets set by a parameter.  The lsfr_done will
// pulse once all combinations of the lsfr are complete.  The number of clock
// cycles that it takes lsfr_done to pulse is equal to 2^g_Num_Bits-1.  For
// example setting g_Num_Bits to 5 means that lsfr_done will pulse every
// 2^5-1 = 31 clock cycles.  lsfr_data will change on each clock cycle that
// the module is enabled, which can be used if desired.
//
// Parameters:
// BIT_WIDTH - Set to the integer number of bits wide to create your lsfr.
///////////////////////////////////////////////////////////////////////////////

//=============================================================================
// File_name    : fibonacci_lsfr.v
// Project_name : project_name.xpr
// Author       : https://github.com/pthuang/
// Function     : Fibonacci lsfr(many-to-one)
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
//             3. Add lsfr_vld signal for cascade and easy-to-use;
//             4. Extend BIT_WIDTH from 32 to 168;
//             5. modify r_xnor wire logic from [always(*)] to [generate case]
//                syntax to reduce resource overhead.    
// 
// 
//=============================================================================
module fibonacci_lsfr #
(
    parameter BIT_WIDTH  = 8                  // maximum: 168
)
(         
    input                       clk         , 
    input                       rst         , // Optional reset valid high
    input                       enable      , 
    input                       load_evt    , // Optional Seed Value
    input     [BIT_WIDTH-1:0]   seed_data   , 
    output reg                  lsfr_vld    , 
    output                      lsfr_done   ,
    output    [BIT_WIDTH-1:0]   lsfr_data    
 
);   
    
    localparam DEFAULT_SEED = 1; // default seed value: x'b0...01 

    reg [BIT_WIDTH-1:0] seed_latch = DEFAULT_SEED; 
    reg [BIT_WIDTH  :1] r_lsfr     = DEFAULT_SEED;
    wire                r_xnor;
    reg                 seed_load_flag = 0;

    assign lsfr_data = r_lsfr[BIT_WIDTH:1];
    assign lsfr_done = (lsfr_vld & r_lsfr[BIT_WIDTH:1] == seed_latch) ? 1'b1 : 1'b0;


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
            lsfr_vld <= 0; 
        end else begin
            lsfr_vld <= enable;
        end
    end 

    // Purpose: Load up lsfr with Seed if load_evt pulse is detected.
    // Othewise just run lsfr when enabled.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_lsfr <= DEFAULT_SEED; 
            seed_load_flag <= 0;
        end else begin
            if (enable) begin
                if (load_evt == 1'b1) begin
                    r_lsfr <= seed_data;
                    seed_load_flag <= 1;
                end else if (~lsfr_vld & ~seed_load_flag) begin
                    r_lsfr <= DEFAULT_SEED;
                    seed_load_flag <= 1;
                end else begin
                    r_lsfr <= {r_lsfr[BIT_WIDTH-1:1], r_xnor};
                    seed_load_flag <= seed_load_flag;
                end
            end
        end 
    end

    // Create Feedback Polynomials.  Based on Application Note:
    // http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
    generate
        case(BIT_WIDTH)
        003     : assign r_xnor = r_lsfr[003] ^~ r_lsfr[002];
        004     : assign r_xnor = r_lsfr[004] ^~ r_lsfr[003];
        005     : assign r_xnor = r_lsfr[005] ^~ r_lsfr[003];
        006     : assign r_xnor = r_lsfr[006] ^~ r_lsfr[005];
        007     : assign r_xnor = r_lsfr[007] ^~ r_lsfr[006];
        008     : assign r_xnor = r_lsfr[008] ^~ r_lsfr[006] ^~ r_lsfr[005] ^~ r_lsfr[004];
        009     : assign r_xnor = r_lsfr[009] ^~ r_lsfr[005];
        010     : assign r_xnor = r_lsfr[010] ^~ r_lsfr[007];
        011     : assign r_xnor = r_lsfr[011] ^~ r_lsfr[009];
        012     : assign r_xnor = r_lsfr[012] ^~ r_lsfr[006] ^~ r_lsfr[004] ^~ r_lsfr[001];
        013     : assign r_xnor = r_lsfr[013] ^~ r_lsfr[004] ^~ r_lsfr[003] ^~ r_lsfr[001];
        014     : assign r_xnor = r_lsfr[014] ^~ r_lsfr[005] ^~ r_lsfr[003] ^~ r_lsfr[001];
        015     : assign r_xnor = r_lsfr[015] ^~ r_lsfr[014];
        016     : assign r_xnor = r_lsfr[016] ^~ r_lsfr[015] ^~ r_lsfr[013] ^~ r_lsfr[004];
        017     : assign r_xnor = r_lsfr[017] ^~ r_lsfr[014];
        018     : assign r_xnor = r_lsfr[018] ^~ r_lsfr[011];
        019     : assign r_xnor = r_lsfr[019] ^~ r_lsfr[006] ^~ r_lsfr[002] ^~ r_lsfr[001];
        020     : assign r_xnor = r_lsfr[020] ^~ r_lsfr[017];
        021     : assign r_xnor = r_lsfr[021] ^~ r_lsfr[019];
        022     : assign r_xnor = r_lsfr[022] ^~ r_lsfr[021];
        023     : assign r_xnor = r_lsfr[023] ^~ r_lsfr[018];
        024     : assign r_xnor = r_lsfr[024] ^~ r_lsfr[023] ^~ r_lsfr[022] ^~ r_lsfr[017];
        025     : assign r_xnor = r_lsfr[025] ^~ r_lsfr[022];
        026     : assign r_xnor = r_lsfr[026] ^~ r_lsfr[006] ^~ r_lsfr[002] ^~ r_lsfr[001];
        027     : assign r_xnor = r_lsfr[027] ^~ r_lsfr[005] ^~ r_lsfr[002] ^~ r_lsfr[001];
        028     : assign r_xnor = r_lsfr[028] ^~ r_lsfr[025];
        029     : assign r_xnor = r_lsfr[029] ^~ r_lsfr[027];
        030     : assign r_xnor = r_lsfr[030] ^~ r_lsfr[006] ^~ r_lsfr[004] ^~ r_lsfr[001];
        031     : assign r_xnor = r_lsfr[031] ^~ r_lsfr[028];
        032     : assign r_xnor = r_lsfr[032] ^~ r_lsfr[022] ^~ r_lsfr[002] ^~ r_lsfr[001];
        033     : assign r_xnor = r_lsfr[033] ^~ r_lsfr[020];
        034     : assign r_xnor = r_lsfr[034] ^~ r_lsfr[027] ^~ r_lsfr[002] ^~ r_lsfr[001];
        035     : assign r_xnor = r_lsfr[035] ^~ r_lsfr[033];
        036     : assign r_xnor = r_lsfr[036] ^~ r_lsfr[025];
        037     : assign r_xnor = r_lsfr[037] ^~ r_lsfr[005] ^~ r_lsfr[004] ^~ r_lsfr[003] ^~ r_lsfr[002] ^~ r_lsfr[001];
        038     : assign r_xnor = r_lsfr[038] ^~ r_lsfr[006] ^~ r_lsfr[005] ^~ r_lsfr[001];
        039     : assign r_xnor = r_lsfr[039] ^~ r_lsfr[035];
        040     : assign r_xnor = r_lsfr[040] ^~ r_lsfr[038] ^~ r_lsfr[021] ^~ r_lsfr[019];
        041     : assign r_xnor = r_lsfr[041] ^~ r_lsfr[038];
        042     : assign r_xnor = r_lsfr[042] ^~ r_lsfr[041] ^~ r_lsfr[020] ^~ r_lsfr[019];
        043     : assign r_xnor = r_lsfr[043] ^~ r_lsfr[042] ^~ r_lsfr[038] ^~ r_lsfr[037];
        044     : assign r_xnor = r_lsfr[044] ^~ r_lsfr[043] ^~ r_lsfr[018] ^~ r_lsfr[017];
        045     : assign r_xnor = r_lsfr[045] ^~ r_lsfr[044] ^~ r_lsfr[042] ^~ r_lsfr[041];
        046     : assign r_xnor = r_lsfr[046] ^~ r_lsfr[045] ^~ r_lsfr[026] ^~ r_lsfr[025];
        047     : assign r_xnor = r_lsfr[047] ^~ r_lsfr[042];
        048     : assign r_xnor = r_lsfr[048] ^~ r_lsfr[047] ^~ r_lsfr[021] ^~ r_lsfr[020];
        049     : assign r_xnor = r_lsfr[049] ^~ r_lsfr[040];
        050     : assign r_xnor = r_lsfr[050] ^~ r_lsfr[049] ^~ r_lsfr[024] ^~ r_lsfr[023];
        051     : assign r_xnor = r_lsfr[051] ^~ r_lsfr[050] ^~ r_lsfr[036] ^~ r_lsfr[035];
        052     : assign r_xnor = r_lsfr[052] ^~ r_lsfr[049];
        053     : assign r_xnor = r_lsfr[053] ^~ r_lsfr[052] ^~ r_lsfr[038] ^~ r_lsfr[037];
        054     : assign r_xnor = r_lsfr[054] ^~ r_lsfr[053] ^~ r_lsfr[018] ^~ r_lsfr[017];
        055     : assign r_xnor = r_lsfr[055] ^~ r_lsfr[031];
        056     : assign r_xnor = r_lsfr[056] ^~ r_lsfr[055] ^~ r_lsfr[035] ^~ r_lsfr[034];
        057     : assign r_xnor = r_lsfr[057] ^~ r_lsfr[050];
        058     : assign r_xnor = r_lsfr[058] ^~ r_lsfr[039];
        059     : assign r_xnor = r_lsfr[059] ^~ r_lsfr[058] ^~ r_lsfr[038] ^~ r_lsfr[037];
        060     : assign r_xnor = r_lsfr[060] ^~ r_lsfr[059];
        061     : assign r_xnor = r_lsfr[061] ^~ r_lsfr[060] ^~ r_lsfr[046] ^~ r_lsfr[045];
        062     : assign r_xnor = r_lsfr[062] ^~ r_lsfr[061] ^~ r_lsfr[006] ^~ r_lsfr[005];
        063     : assign r_xnor = r_lsfr[063] ^~ r_lsfr[062];
        064     : assign r_xnor = r_lsfr[064] ^~ r_lsfr[063] ^~ r_lsfr[061] ^~ r_lsfr[060];
        065     : assign r_xnor = r_lsfr[065] ^~ r_lsfr[047];
        066     : assign r_xnor = r_lsfr[066] ^~ r_lsfr[065] ^~ r_lsfr[057] ^~ r_lsfr[056];
        067     : assign r_xnor = r_lsfr[067] ^~ r_lsfr[066] ^~ r_lsfr[058] ^~ r_lsfr[057];
        068     : assign r_xnor = r_lsfr[068] ^~ r_lsfr[059];
        069     : assign r_xnor = r_lsfr[069] ^~ r_lsfr[067] ^~ r_lsfr[042] ^~ r_lsfr[040];
        070     : assign r_xnor = r_lsfr[070] ^~ r_lsfr[069] ^~ r_lsfr[055] ^~ r_lsfr[054];
        071     : assign r_xnor = r_lsfr[071];
        072     : assign r_xnor = r_lsfr[072] ^~ r_lsfr[066] ^~ r_lsfr[025] ^~ r_lsfr[019];
        073     : assign r_xnor = r_lsfr[073] ^~ r_lsfr[048];
        074     : assign r_xnor = r_lsfr[074] ^~ r_lsfr[073] ^~ r_lsfr[059] ^~ r_lsfr[058];
        075     : assign r_xnor = r_lsfr[075] ^~ r_lsfr[074] ^~ r_lsfr[065] ^~ r_lsfr[064];
        076     : assign r_xnor = r_lsfr[076] ^~ r_lsfr[075] ^~ r_lsfr[041] ^~ r_lsfr[040];
        077     : assign r_xnor = r_lsfr[077] ^~ r_lsfr[076] ^~ r_lsfr[047] ^~ r_lsfr[046];
        078     : assign r_xnor = r_lsfr[078] ^~ r_lsfr[077] ^~ r_lsfr[059] ^~ r_lsfr[058];
        079     : assign r_xnor = r_lsfr[079] ^~ r_lsfr[070];
        080     : assign r_xnor = r_lsfr[080] ^~ r_lsfr[079] ^~ r_lsfr[043] ^~ r_lsfr[042];
        081     : assign r_xnor = r_lsfr[081] ^~ r_lsfr[077];
        082     : assign r_xnor = r_lsfr[082] ^~ r_lsfr[079] ^~ r_lsfr[047] ^~ r_lsfr[044];
        083     : assign r_xnor = r_lsfr[083] ^~ r_lsfr[082] ^~ r_lsfr[038] ^~ r_lsfr[037];
        084     : assign r_xnor = r_lsfr[084] ^~ r_lsfr[071];
        085     : assign r_xnor = r_lsfr[085] ^~ r_lsfr[084] ^~ r_lsfr[058] ^~ r_lsfr[057];
        086     : assign r_xnor = r_lsfr[086] ^~ r_lsfr[085] ^~ r_lsfr[074] ^~ r_lsfr[073];
        087     : assign r_xnor = r_lsfr[087] ^~ r_lsfr[074];
        088     : assign r_xnor = r_lsfr[088] ^~ r_lsfr[087] ^~ r_lsfr[017] ^~ r_lsfr[016];
        089     : assign r_xnor = r_lsfr[089] ^~ r_lsfr[051];
        090     : assign r_xnor = r_lsfr[090] ^~ r_lsfr[089] ^~ r_lsfr[072] ^~ r_lsfr[071];
        091     : assign r_xnor = r_lsfr[091] ^~ r_lsfr[090] ^~ r_lsfr[008] ^~ r_lsfr[007];
        092     : assign r_xnor = r_lsfr[092] ^~ r_lsfr[091] ^~ r_lsfr[080] ^~ r_lsfr[079];
        093     : assign r_xnor = r_lsfr[093] ^~ r_lsfr[091];
        094     : assign r_xnor = r_lsfr[094] ^~ r_lsfr[073];
        095     : assign r_xnor = r_lsfr[095] ^~ r_lsfr[084];
        096     : assign r_xnor = r_lsfr[096] ^~ r_lsfr[094] ^~ r_lsfr[049] ^~ r_lsfr[047];
        097     : assign r_xnor = r_lsfr[097] ^~ r_lsfr[091];
        098     : assign r_xnor = r_lsfr[098] ^~ r_lsfr[087];
        099     : assign r_xnor = r_lsfr[099] ^~ r_lsfr[097] ^~ r_lsfr[054] ^~ r_lsfr[052];
        100     : assign r_xnor = r_lsfr[100] ^~ r_lsfr[063];
        101     : assign r_xnor = r_lsfr[101] ^~ r_lsfr[100] ^~ r_lsfr[095] ^~ r_lsfr[094];
        102     : assign r_xnor = r_lsfr[102] ^~ r_lsfr[101] ^~ r_lsfr[036] ^~ r_lsfr[035];
        103     : assign r_xnor = r_lsfr[103] ^~ r_lsfr[094];
        104     : assign r_xnor = r_lsfr[104] ^~ r_lsfr[103] ^~ r_lsfr[094] ^~ r_lsfr[093];
        105     : assign r_xnor = r_lsfr[105] ^~ r_lsfr[089];
        106     : assign r_xnor = r_lsfr[106] ^~ r_lsfr[091];
        107     : assign r_xnor = r_lsfr[107] ^~ r_lsfr[105] ^~ r_lsfr[044] ^~ r_lsfr[042];
        108     : assign r_xnor = r_lsfr[108] ^~ r_lsfr[077];
        109     : assign r_xnor = r_lsfr[109] ^~ r_lsfr[108] ^~ r_lsfr[103] ^~ r_lsfr[102];
        110     : assign r_xnor = r_lsfr[110] ^~ r_lsfr[109] ^~ r_lsfr[098] ^~ r_lsfr[097];
        111     : assign r_xnor = r_lsfr[111] ^~ r_lsfr[101];
        112     : assign r_xnor = r_lsfr[112] ^~ r_lsfr[110] ^~ r_lsfr[069] ^~ r_lsfr[067];
        113     : assign r_xnor = r_lsfr[113] ^~ r_lsfr[104];
        114     : assign r_xnor = r_lsfr[114] ^~ r_lsfr[113] ^~ r_lsfr[033] ^~ r_lsfr[032];
        115     : assign r_xnor = r_lsfr[115] ^~ r_lsfr[114] ^~ r_lsfr[101] ^~ r_lsfr[100];
        116     : assign r_xnor = r_lsfr[116] ^~ r_lsfr[115] ^~ r_lsfr[046] ^~ r_lsfr[045];
        117     : assign r_xnor = r_lsfr[117] ^~ r_lsfr[115] ^~ r_lsfr[099] ^~ r_lsfr[097];
        118     : assign r_xnor = r_lsfr[118] ^~ r_lsfr[085];
        119     : assign r_xnor = r_lsfr[119] ^~ r_lsfr[111];
        120     : assign r_xnor = r_lsfr[120] ^~ r_lsfr[113] ^~ r_lsfr[009] ^~ r_lsfr[002];
        121     : assign r_xnor = r_lsfr[121] ^~ r_lsfr[103];
        122     : assign r_xnor = r_lsfr[122] ^~ r_lsfr[121] ^~ r_lsfr[063] ^~ r_lsfr[062];
        123     : assign r_xnor = r_lsfr[123] ^~ r_lsfr[121];
        124     : assign r_xnor = r_lsfr[124] ^~ r_lsfr[087];
        125     : assign r_xnor = r_lsfr[125] ^~ r_lsfr[124] ^~ r_lsfr[018] ^~ r_lsfr[017];
        126     : assign r_xnor = r_lsfr[126] ^~ r_lsfr[125] ^~ r_lsfr[090] ^~ r_lsfr[089];
        127     : assign r_xnor = r_lsfr[127] ^~ r_lsfr[126];
        128     : assign r_xnor = r_lsfr[128] ^~ r_lsfr[126] ^~ r_lsfr[101] ^~ r_lsfr[099];
        129     : assign r_xnor = r_lsfr[129] ^~ r_lsfr[124];
        130     : assign r_xnor = r_lsfr[130] ^~ r_lsfr[127];
        131     : assign r_xnor = r_lsfr[131] ^~ r_lsfr[130] ^~ r_lsfr[084] ^~ r_lsfr[083];
        132     : assign r_xnor = r_lsfr[132] ^~ r_lsfr[103];
        133     : assign r_xnor = r_lsfr[133] ^~ r_lsfr[132] ^~ r_lsfr[082] ^~ r_lsfr[081];
        134     : assign r_xnor = r_lsfr[134] ^~ r_lsfr[077];
        135     : assign r_xnor = r_lsfr[135] ^~ r_lsfr[124];
        136     : assign r_xnor = r_lsfr[136] ^~ r_lsfr[135] ^~ r_lsfr[011] ^~ r_lsfr[010];
        137     : assign r_xnor = r_lsfr[137] ^~ r_lsfr[116];
        138     : assign r_xnor = r_lsfr[138] ^~ r_lsfr[137] ^~ r_lsfr[131] ^~ r_lsfr[130];
        139     : assign r_xnor = r_lsfr[139] ^~ r_lsfr[136] ^~ r_lsfr[134] ^~ r_lsfr[131];
        140     : assign r_xnor = r_lsfr[140] ^~ r_lsfr[111];
        141     : assign r_xnor = r_lsfr[141] ^~ r_lsfr[140];
        142     : assign r_xnor = r_lsfr[142] ^~ r_lsfr[121];
        143     : assign r_xnor = r_lsfr[143] ^~ r_lsfr[142] ^~ r_lsfr[123] ^~ r_lsfr[122];
        144     : assign r_xnor = r_lsfr[144] ^~ r_lsfr[143] ^~ r_lsfr[075] ^~ r_lsfr[074];
        145     : assign r_xnor = r_lsfr[145] ^~ r_lsfr[093];
        146     : assign r_xnor = r_lsfr[146] ^~ r_lsfr[145] ^~ r_lsfr[087] ^~ r_lsfr[086];
        147     : assign r_xnor = r_lsfr[147] ^~ r_lsfr[146] ^~ r_lsfr[110] ^~ r_lsfr[109];
        148     : assign r_xnor = r_lsfr[148] ^~ r_lsfr[121];
        149     : assign r_xnor = r_lsfr[149] ^~ r_lsfr[148] ^~ r_lsfr[040] ^~ r_lsfr[039];
        150     : assign r_xnor = r_lsfr[150] ^~ r_lsfr[097];
        151     : assign r_xnor = r_lsfr[151] ^~ r_lsfr[148];
        152     : assign r_xnor = r_lsfr[152] ^~ r_lsfr[151] ^~ r_lsfr[087] ^~ r_lsfr[086];
        153     : assign r_xnor = r_lsfr[153] ^~ r_lsfr[152];
        154     : assign r_xnor = r_lsfr[154] ^~ r_lsfr[027] ^~ r_lsfr[025];
        155     : assign r_xnor = r_lsfr[155] ^~ r_lsfr[154] ^~ r_lsfr[124] ^~ r_lsfr[123];
        156     : assign r_xnor = r_lsfr[156] ^~ r_lsfr[155] ^~ r_lsfr[041] ^~ r_lsfr[040];
        157     : assign r_xnor = r_lsfr[157] ^~ r_lsfr[156] ^~ r_lsfr[131] ^~ r_lsfr[130];
        158     : assign r_xnor = r_lsfr[158] ^~ r_lsfr[157] ^~ r_lsfr[132] ^~ r_lsfr[131];
        159     : assign r_xnor = r_lsfr[159] ^~ r_lsfr[128];
        160     : assign r_xnor = r_lsfr[160] ^~ r_lsfr[159] ^~ r_lsfr[142] ^~ r_lsfr[141];
        161     : assign r_xnor = r_lsfr[161] ^~ r_lsfr[143];
        162     : assign r_xnor = r_lsfr[162] ^~ r_lsfr[161] ^~ r_lsfr[075] ^~ r_lsfr[074];
        163     : assign r_xnor = r_lsfr[163] ^~ r_lsfr[162] ^~ r_lsfr[104] ^~ r_lsfr[103];
        164     : assign r_xnor = r_lsfr[164] ^~ r_lsfr[163] ^~ r_lsfr[151] ^~ r_lsfr[150];
        165     : assign r_xnor = r_lsfr[165] ^~ r_lsfr[164] ^~ r_lsfr[135] ^~ r_lsfr[134];
        166     : assign r_xnor = r_lsfr[166] ^~ r_lsfr[165] ^~ r_lsfr[128] ^~ r_lsfr[127];
        167     : assign r_xnor = r_lsfr[167] ^~ r_lsfr[161];
        168     : assign r_xnor = r_lsfr[168] ^~ r_lsfr[166] ^~ r_lsfr[153] ^~ r_lsfr[151];
        endcase
    endgenerate
    
 
endmodule // lsfr