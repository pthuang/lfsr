%% clear workspace
clc; clear; close all; 

%% get tap  
lsfr_tap = TapInitial();


%% galois tap gernerate 
temp = zeros(size(lsfr_tap,1),1);
galois_tap = [temp, lsfr_tap(:,1:end-1)];

cnt_zero_len = 0;
fid = fopen('galois_verilog_snippet.v','wt');
fprintf(fid,'generate\n'); % generate
fprintf(fid,'    case(BIT_WIDTH)\n'); 
for i = 3:168 
    fprintf(fid,'    ');
    fprintf(fid, '%03d', i); 
    fprintf(fid,'     : begin always@(*) begin ');
    fprintf(fid, 'fb_vec = {');
    for j = i:-1:1
        if j == 1
            if galois_tap(i,j) == 1
                fprintf(fid, 'x_lsfr[BIT_WIDTH]}'); %
            else 
                fprintf(fid, '%d''h0}', cnt_zero_len+1); % 
                cnt_zero_len = 0;
            end
        else
            if galois_tap(i,j) == 1
                if cnt_zero_len > 0
                    fprintf(fid, '%d''h0,', cnt_zero_len); % 
                    cnt_zero_len = 0;
                end
                fprintf(fid, 'x_lsfr[BIT_WIDTH],'); %
                
            else 
                cnt_zero_len = cnt_zero_len + 1;
            end
        end
    end 
    fprintf(fid,'; end end \n');
end
fprintf(fid,'    default : begin always@(*) begin fb_vec = 0; end end\n');
fprintf(fid,'    endcase\n'); 
fprintf(fid,'endgenerate\n'); % generate


%% fibonacci tap gernerate 
fid = fopen('fibonacci_verilog_snippet.v','wt');
fprintf(fid,'generate\n'); % generate
fprintf(fid,'    case(BIT_WIDTH)\n'); 
for i = 3:168 
    fprintf(fid,'    ');
    fprintf(fid, '%03d', i); %
    fprintf(fid,'     : assign r_xnor = ');
    for j = i:-1:1

        if j == i
            if lsfr_tap(i,j) == 1
                fprintf(fid, 'r_lsfr[%03d]', j); %
            end
        elseif j == 1
            if lsfr_tap(i,j) == 1
                fprintf(fid, ' ^~ r_lsfr[%03d]', j); %
            end
        else
            if lsfr_tap(i,j) == 1
                fprintf(fid, ' ^~ r_lsfr[%03d]', j); %
            end
        end
    end 
    fprintf(fid,';\n');
end
fprintf(fid,'    endcase\n'); 
fprintf(fid,'endgenerate\n'); % generate

