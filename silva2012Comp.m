%input = 'D:\PDEEC\SHARPE_Projects\testIn.txt';
%output = 'D:\PDEEC\SHARPE_Projects\out.txt';
%!C:\Sharpe-Gui\sharpe\sharpe D:\PDEEC\SHARPE_Projects\testIn.txt > D:\PDEEC\SHARPE_Projects\out2.txt

%input = 'D:\PDEEC\MATLAB\sharpeModel.txt';
%output = 'D:\PDEEC\MATLAB\sharpeOut.txt';

tic

input_FULL = '.\sharpeModel_FULL.txt';
output_FULL = '.\sharpeOut_FULL.txt';
eval(['!C:\Sharpe-Gui\sharpe\sharpe ' input_FULL ' > ' output_FULL]);

sharpeTime = toc();
display(['FULL Model Evaluation by SHARPE: ' num2str(sharpeTime) 's']);

tic

input_HW_BT = '.\sharpeModel_HW_BT.txt';
output_HW_BT = '.\sharpeOut_HW_BT.txt';
eval(['!C:\Sharpe-Gui\sharpe\sharpe ' input_HW_BT ' > ' output_HW_BT]);

sharpeTime = toc();
display(['HW_BT Model Evaluation by SHARPE: ' num2str(sharpeTime) 's']);

tic

input_HW_LK = '.\sharpeModel_HW_LK.txt';
output_HW_LK = '.\sharpeOut_HW_LK.txt';
eval(['!C:\Sharpe-Gui\sharpe\sharpe ' input_HW_LK ' > ' output_HW_LK]);

sharpeTime = toc();
display(['HW_LK Model Evaluation by SHARPE: ' num2str(sharpeTime) 's']);

tic

input_HW = '.\sharpeModel_HW.txt';
output_HW = '.\sharpeOut_HW.txt';
eval(['!C:\Sharpe-Gui\sharpe\sharpe ' input_HW ' > ' output_HW]);

sharpeTime = toc();
display(['HW Model Evaluation by SHARPE: ' num2str(sharpeTime) 's']);

tic

% txt = textread(output,'%s');
% 
% length = size(txt,1)/3;
% 
% t = zeros(1,length);
% values = zeros(1,length);
% prop = '';
% 
% cnt = 1;
% for i=1:3:3*length,
%     str = char(txt(i));
%     t(cnt) = str2double(str(3:size(str,2)));
%     
%     str = char(txt(i+2));
%     values(cnt) = str2double(str);
%     
%     cnt = cnt + 1;
%     
%     if(i==1),
%         str = char(txt(i+1));
%         prop = str(1:size(str,2)-1); 
%     end
% end

fileID_FULL = fopen(output_FULL);
fileID_HW_BT = fopen(output_HW_BT);
fileID_HW_LK = fopen(output_HW_LK);
fileID_HW = fopen(output_HW);

txt_FULL = textscan(fileID_FULL, '%s');
txt_HW_BT = textscan(fileID_HW_BT, '%s');
txt_HW_LK = textscan(fileID_HW_LK, '%s');
txt_HW = textscan(fileID_HW, '%s');

fclose(fileID_FULL);
fclose(fileID_HW_BT);
fclose(fileID_HW_LK);
fclose(fileID_HW);

lengthTXT = size(txt_FULL{1},1)/3;

t = zeros(1,lengthTXT);
values_FULL = zeros(1,lengthTXT);
values_HW_BT = zeros(1,lengthTXT);
values_HW_LK = zeros(1,lengthTXT);
values_HW = zeros(1,lengthTXT);
prop = '';

cnt = 1;
for i=1:3:3*lengthTXT,
    str_FULL = char(txt_FULL{1}{i});
    str_HW_BT = char(txt_HW_BT{1}{i});
    str_HW_LK = char(txt_HW_LK{1}{i});
    str_HW = char(txt_HW{1}{i});
    
    t(cnt) = str2double(str_FULL(3:size(str_FULL,2)));
    
    str_FULL = char(txt_FULL{1}{i+2});
    str_HW_BT = char(txt_HW_BT{1}{i+2});
    str_HW_LK = char(txt_HW_LK{1}{i+2});
    str_HW = char(txt_HW{1}{i+2});
    values_FULL(cnt) = str2double(str_FULL);
    values_HW_BT(cnt) = str2double(str_HW_BT);
    values_HW_LK(cnt) = str2double(str_HW_LK);
    values_HW(cnt) = str2double(str_HW);
    
    cnt = cnt + 1;
    
    if(i==1),
        str_FULL = char(txt_FULL{1}{i+1});
        prop = str_FULL(1:size(str_FULL,2)-1); 
    end
end

%plot(t,values);
plot(t,values_HW,'-*g',...
     t,values_HW_LK,'-.sk',...
     t,values_HW_BT,'--dr',...
     t,values_FULL,':ob','MarkerIndices',1:500:size(t,2));
legend('HW','HW+LK','HW+BT','HW+BT+LK');
title('SHARPE EVALUATION');
xlabel('t');
ylabel(prop);
grid;

plotTime = toc();
display(['Plot: ' num2str(plotTime) 's']);