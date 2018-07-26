tic

%data;

%binds
binds = [];
binds_HW = [];
binds_BT = [];
binds_LK = [];

binds_HW{size(binds_HW,2)+1} = ['bind lambda_hw ' num2str(lambda_hw) '\nbind mu_hw ' num2str(mu_hw) '\n\n'];
binds_LK{size(binds_LK,2)+1} = ['bind lambda_link ' num2str(lambda_link) '\nbind mu_link ' num2str(mu_link) '\n\n'];
for i=0:btStages-1, %%%% AQUI for i=0:btStages,
    if(max(size(lambda_bt)) == btStages),
        binds_BT{size(binds_BT,2)+1} = ['bind lambda_bt' num2str(i) ' ' num2str(lambda_bt(i+1)) '\n'];
    else,
        binds_BT{size(binds_BT,2)+1} = ['bind lambda_bt' num2str(i) ' ' num2str(lambda_bt) '\n'];
    end
end
binds_BT{size(binds_BT,2)+1} = ['bind mu_bt ' num2str(mu_bt) '\n\n'];

%FaultTree
ftGatesIni = [];
ftGatesEnd = [];

ftGatesIni_WLK = [];
ftGatesEnd_WLK = [];

ftGatesIni_LK = [];
ftGatesEnd_LK = [];

ftEvents = [];
ftEvents_LK = [];
ftEvents_HW = [];
ftEvents_HW_noBT = [];
ftEvents_BT = [];

%Markov Chains
mChains = [];
mChains_LK = [];
mChains_HW = [];
mChains_BT = [];

paths = cell(0);
paths_LK = cell(0);
paths_WLK = cell(0);
dev = max(size(mAdj));
%dev0 = gtw. Take place at index 1;
%Current Path
cPath = cell({['Dev' num2str(dev-1)]});

strDevs = strsplit(NFC,[" ",'\f','\n','\r','\t','\v',")","(","or","and"]);
strDevs = unique(strDevs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
auxSTR = [];
for strCNT=1:size(strDevs,2),
    if(~isempty(strDevs{strCNT})),
        auxSTR{size(auxSTR,2)+1} = strDevs{strCNT};
    end
end
strDevs = auxSTR;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

devs=[];

for i=1:max(size(strDevs)),
    %+1 -> adjust because of first index of MATLAB is 1. %dev0 = gtw. Take place at index 1;
    dev = str2num(strDevs{i})+1;
    if(~isempty(dev)),
        %cPath = cell({['Dev' num2str(dev-1)]});
        cPath = cell({['Dev' num2str(dev-1)]});
        %paths{i,1} = dev;
        paths_LK{i,1} = dev;
        paths_WLK{i,1} = dev;
        %First path is a null (empty) path
        paths_LK{i,2} = ownDFS(cell(0),mAdj,dev,cPath);
        paths_WLK{i,2} = ownDFSNodes(cell(0),mAdj,dev,cPath);
    end
end

occurrences = cell(0);

for i=1:size(paths_LK,1),
    pathSet = paths_LK{i,1};
    if(PRINT),
        display(' ');
        display(['**** Set of Path from Node' num2str(pathSet-1) ' ****']);
    end
    
    %->verificar se existe dois ou mais caminhos, para nao criar uma
            %AND com uma unica entrada
    %if(max(size(paths_LK{i,2}))==1),
        %AND COM UMA UNICA ENTRADA
    %else,
    if(max(size(paths_LK{i,2}))>1),
        eval(['and_path' num2str(pathSet) ' = ''\tand and_path' num2str(pathSet) ''';'])
    end
    
    for j=1:size(paths_LK{i,2},2),
        %each path from the set of paths from a node
        instPath = paths_LK{i,2}{j};
        siglePath = '';
        
        %->verificar se existe dois ou mais devices/links, para nao criar
            %uma OR com uma unica entrada
        if(max(size(paths_LK{i,2}))>1),
            orGate_FULL = ['or_path' num2str(pathSet) '_' num2str(j)];
        else,
            orGate_FULL = ['and_path' num2str(pathSet)];
        end
        toSHARPE_OR_FULL = ['\tor ' orGate_FULL];
        toSHARPE_OR_WLK = ['\tor ' orGate_FULL];
        
        %orGate_HW = ['or_path' num2str(pathSet) '_' num2str(j)];
        %toSHARPE_OR_HW = ['\tor ' orGate_HW];
        
        if(exist(['and_path' num2str(pathSet)])),
            eval(['and_path' num2str(pathSet) ' = [and_path' num2str(pathSet) ' '' '' ' 'orGate_FULL];']);
        end
        
        
            
        for k=1:size(instPath,2),
            siglePath = [siglePath ' ' instPath{k}];
            
            if(instPath{k}(1) == 'L'),
                toSHARPE_OR_FULL = [toSHARPE_OR_FULL ' ev' instPath{k}];
            else,
                toSHARPE_OR_FULL = [toSHARPE_OR_FULL ' or_' instPath{k}];
                toSHARPE_OR_WLK = [toSHARPE_OR_WLK ' or_' instPath{k}];
            end
            
            %->montar a string de deMorgan
            %->cada dev será uma OR da Markov Chain do Hw e da bateria
            %->cada link será uma Markov Chain
            %->um path será uma or dos devs e links
            %->a falha será a NFC
            %->Mudar dev0 para gtw
            [contains, index] = occurrencesContains(occurrences, instPath{k});
            if(contains),
                occurrences{index,2} = occurrences{index,2}+1;
            else,
                auxSize = size(occurrences,1)+1;
                occurrences{auxSize,1} = instPath{k};
                occurrences{auxSize,2} = 1;
            end
        end
        
        if(PRINT),
            display([num2str(j) ': ' siglePath]);
            display(['toSHARPE_OR_FULL: ' toSHARPE_OR_FULL]);
            display(['toSHARPE_OR_WLK: ' toSHARPE_OR_WLK]);
        end
        %ftGatesEnd{size(ftGatesEnd,2)+1} = [toSHARPE_OR_FULL '\n'];
        ftGatesEnd_LK{size(ftGatesEnd_LK,2)+1} = [toSHARPE_OR_FULL '\n'];
        ftGatesEnd_WLK{size(ftGatesEnd_WLK,2)+1} = [toSHARPE_OR_WLK '\n'];
    end
    if(PRINT),
        if(exist(['and_path' num2str(pathSet)])),
            display(['AND_PATH: ' eval(['and_path' num2str(pathSet)])]);
        end
    end
    if(exist(['and_path' num2str(pathSet)])),
        %ftGatesEnd{size(ftGatesEnd,2)+1} = [eval(['and_path' num2str(pathSet)]) '\n\n'];
        ftGatesEnd_LK{size(ftGatesEnd_LK,2)+1} = [eval(['and_path' num2str(pathSet)]) '\n\n'];
        ftGatesEnd_WLK{size(ftGatesEnd_WLK,2)+1} = [eval(['and_path' num2str(pathSet)]) '\n\n'];
    end
end


%TODO: ler a NFC e fazer uma expressao para a falha, trocando cada devide
%da NFC por respectiva AND das strings toSHARPE_AND


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% start TESTE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
setNFC = strsplit(NFC,'or');


nNFCs = size(setNFC,2);

failure = [];
failureItems = [];

if(nNFCs>1),
end

cntNFC = 1;
for k=1:nNFCs,
    strNFC = strsplit(setNFC{k},[" ",'\f','\n','\r','\t','\v',")","(","and"]);
    auxSTR = [];
    for strCNT=1:size(strNFC,2),
        if(~isempty(strNFC{strCNT})),
            auxSTR{size(auxSTR,2)+1} = strNFC{strCNT};
        end
    end
    strNFC = auxSTR;

    items = size(strNFC,2);

    if(items == 0),
        error('ERROR: Undefined Network Fault Conditions')
    elseif(items == 1),
        %Verificar se precisa disso. Talvez essa linha apareca duplicada no
        %arquivo de saida.
        %failure = toSHARPE_AND;
        %RETIRADO POR DUPLICATA EM ARQUIVO DE SAIDA failure{1} = cell({ ['and_path' strNFC{1}+1] });
        %A linha acima está correta?
        if(nNFCs>1),
            failureItems{max(size(failureItems))+1} = ['and_path' num2str(str2num(strNFC{1})+1)];
        else,
            %Nao precisa. A ultima porta criada já sera a nfc. Testar com
            %NFC = '1';
        end
        
    elseif(items > 1), 
        strQQ = [];
        for i=1:items,
            value = str2num(strNFC{i});
            if(i==1),
                %strQQ = ['and nfc' num2str(cntNFC) ' and_path' strNFC{i}+1];
                strQQ = ['and nfc' num2str(cntNFC) ' and_path' num2str(str2num(strNFC{i})+1)]; 
                failureItems{max(size(failureItems))+1} = ['nfc' num2str(cntNFC)];
            else,
                %strQQ = [strQQ ' and_path' strNFC{i}+1]; 
                strQQ = [strQQ ' and_path' num2str(str2num(strNFC{i})+1)]; 
            end
        end
        failure{cntNFC} = cell({strQQ});
        cntNFC = cntNFC+1;
    end

end

if(nNFCs>1),
    orNFC = 'or nfc';
    for i=1:max(size(failureItems)),
        orNFC = [orNFC ' ' failureItems{i}];
    end
    failure{cntNFC} = cell({orNFC});
else,
    %A NFC tem apenas um item. A ultima porta criada já sera a nfc. Testar
    %com NFC = '1';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%  end TESTE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% strNFC = strsplit(NFC);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% auxSTR = [];
% for strCNT=1:size(strNFC,2),
%     if(~isempty(strNFC{strCNT})),
%         auxSTR{size(auxSTR,2)+1} = strNFC{strCNT};
%     end
% end
% strNFC = auxSTR;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% items = size(strNFC,2);
% failure = [];
% if(items == 0),
%     error('ERROR: Undefined Network Fault Conditions')
% elseif(items == 1),
%     %Verificar se precisa disso. Talvez essa linha apareca duplicada no
%     %arquivo de saida.
%     %failure = toSHARPE_AND;
%     %RETIRADO POR DUPLICATA EM ARQUIVO DE SAIDA failure{1} = cell({ ['and_path' strNFC{1}+1] });
%     %A linha acima está correta?
% elseif(items > 1),
%     cntNFC = 1;
%     for i=1:items,
%         value = str2num(strNFC{i});
%         if(isempty(value)),
%             %TODO: VERIFICAR PRECEDENCIA
%             if(isempty(failure)),
%                 failure{cntNFC} = cell({[strNFC{i} ' nfc' num2str(cntNFC) ' and_path' strNFC{i-1}+1 ' and_path' strNFC{i+1}+1]});
%             else,
%                 failure{cntNFC} = cell({ [strNFC{i} ' nfc' num2str(cntNFC) ' nfc' num2str(cntNFC-1) ' and_path' strNFC{i+1}+1] });
%             end
%             cntNFC = cntNFC+1;
%         end
%     end
% end

if(PRINT),
    display(' ');
    display(['******** NFC ********']);
    display(['=> ' NFC ' <=']);
end
for i=1:size(failure,2),
    if(PRINT),
        display(['-> ' failure{i}{1}]);
    end
    ftGatesEnd{size(ftGatesEnd,2)+1} = [failure{i}{1} '\n'];
end

if(PRINT),
    display(' ');
    display(['**** OCCURRENCES ****']);
end

toBT = '';
for i=0:btStages-1,
    toBT = [toBT 'lambda_bt' num2str(i) ', '];
end
for i=1:size(occurrences,1),
    if(PRINT),
        display([occurrences{i,1} ': ' num2str(occurrences{i,2})]);
    end
    
    if(occurrences{i,1}(1) == 'L'),
        %Link event
        if(occurrences{i,2}==1), %basic event
            ftEvents_LK{size(ftEvents_LK,2)+1} = ['\tbasic ev' occurrences{i,1} ' prob(exrt(time; LK_model_' occurrences{i,1} '; lambda_link, mu_link))\n'];
        elseif(occurrences{i,2}>1), %repeated event
            ftEvents_LK{size(ftEvents_LK,2)+1} = ['\trepeat ev' occurrences{i,1} ' prob(exrt(time; LK_model_' occurrences{i,1} '; lambda_link, mu_link))\n'];
        end
        if(PRINT),
            display(['ev: ' ftEvents_LK{size(ftEvents_LK,2)}]);
            display(' ');
        end
        
        mChains_LK{size(mChains_LK,2)+1} = ['markov LK_model_' occurrences{i,1} '(lambda_linkk, mu_link) readprobs \n'];
        mChains_LK{size(mChains_LK,2)+1} = ['\tUP_' occurrences{i,1} ' DOWN_' occurrences{i,1} ' lambda_link\n'];
        mChains_LK{size(mChains_LK,2)+1} = ['\tDOWN_' occurrences{i,1} ' UP_' occurrences{i,1} ' mu_link\n\n'];
        mChains_LK{size(mChains_LK,2)+1} = ['\t* Reward configuration defined: \n'];
        mChains_LK{size(mChains_LK,2)+1} = ['\treward\n'];
        mChains_LK{size(mChains_LK,2)+1} = ['\t\tUP_' occurrences{i,1} ' rew_LK_model_UP_' occurrences{i,1} '\n'];
        mChains_LK{size(mChains_LK,2)+1} = ['\t\tDOWN_' occurrences{i,1} ' rew_LK_model_DOWN_' occurrences{i,1} '\n'];
        mChains_LK{size(mChains_LK,2)+1} = ['\tend\n\n'];
        mChains_LK{size(mChains_LK,2)+1} = ['\t* Initial Probabilities defined: \n'];
        mChains_LK{size(mChains_LK,2)+1} = ['\tUP_' occurrences{i,1} ' init_LK_model_UP_' occurrences{i,1} '\n'];
        mChains_LK{size(mChains_LK,2)+1} = ['\tDOWN_' occurrences{i,1} ' init_LK_model_DOWN_' occurrences{i,1} '\n'];
        mChains_LK{size(mChains_LK,2)+1} = ['end\n\n'];
        
        binds_LK{size(binds_LK,2)+1} = ['* DOWN configuration: LK_' occurrences{i,1} '_Config\n'];
        binds_LK{size(binds_LK,2)+1} = ['bind\n'];
        binds_LK{size(binds_LK,2)+1} = ['\trew_LK_model_UP_' occurrences{i,1} '\t0\n'];
        binds_LK{size(binds_LK,2)+1} = ['\trew_LK_model_DOWN_' occurrences{i,1} '\t1\n'];
        binds_LK{size(binds_LK,2)+1} = ['end\n\n'];
        
        binds_LK{size(binds_LK,2)+1} = ['* Initial Probability: LK_' occurrences{i,1} '_InitProb\n'];
        binds_LK{size(binds_LK,2)+1} = ['bind\n'];
        binds_LK{size(binds_LK,2)+1} = ['\tinit_LK_model_UP_' occurrences{i,1} '\t1\n'];
        binds_LK{size(binds_LK,2)+1} = ['\tinit_LK_model_DOWN_' occurrences{i,1} '\t0\n'];
        binds_LK{size(binds_LK,2)+1} = ['end\n\n'];

    else,
        if(occurrences{i,2}==1), %basic event
            ftEvents_HW{size(ftEvents_HW,2)+1} = ['\tbasic ev_' occurrences{i,1} '_hw prob(exrt(time; HW_model_' occurrences{i,1} '; lambda_hw, mu_hw))\n'];
            ftEvents_HW_noBT{size(ftEvents_HW_noBT,2)+1} = ['\tbasic or_' occurrences{i,1} ' prob(exrt(time; HW_model_' occurrences{i,1} '; lambda_hw, mu_hw))\n'];
            ftEvents_BT{size(ftEvents_BT,2)+1} = ['\tbasic ev_' occurrences{i,1} '_bt prob(exrt(time; BT_model_' occurrences{i,1} '; ' toBT 'mu_bt))\n'];
        elseif(occurrences{i,2}>1), %repeated event
            ftEvents_HW{size(ftEvents_HW,2)+1} = ['\trepeat ev_' occurrences{i,1} '_hw prob(exrt(time; HW_model_' occurrences{i,1} '; lambda_hw , mu_hw))\n'];
            ftEvents_HW_noBT{size(ftEvents_HW_noBT,2)+1} = ['\trepeat or_' occurrences{i,1} ' prob(exrt(time; HW_model_' occurrences{i,1} '; lambda_hw, mu_hw))\n'];
            ftEvents_BT{size(ftEvents_BT,2)+1} = ['\trepeat ev_' occurrences{i,1} '_bt prob(exrt(time; BT_model_' occurrences{i,1} '; ' toBT ' mu_bt))\n'];
        end
        ftGatesIni{size(ftGatesIni,2)+1} = ['\tor or_' occurrences{i,1} ' ev_' occurrences{i,1} '_hw ev_' occurrences{i,1} '_bt\n'];
        if(PRINT),
            display(['ev: ' ftEvents{size(ftEvents,2)-1}]);
            display(['ev: ' ftEvents{size(ftEvents,2)}]);
            display(['gt: ' ftGatesIni{size(ftGatesIni,2)}]);
            display(' ');
        end
        
        mChains_HW{size(mChains_HW,2)+1} = ['markov HW_model_' occurrences{i,1} '(lambda_hw, mu_hw) readprobs \n'];
        mChains_HW{size(mChains_HW,2)+1} = ['\tUP_' occurrences{i,1} ' DOWN_' occurrences{i,1} ' lambda_hw\n'];
        mChains_HW{size(mChains_HW,2)+1} = ['\tDOWN_' occurrences{i,1} ' UP_' occurrences{i,1} ' mu_hw\n\n'];
        mChains_HW{size(mChains_HW,2)+1} = ['\t* Reward configuration defined: \n'];
        mChains_HW{size(mChains_HW,2)+1} = ['\treward\n'];
        mChains_HW{size(mChains_HW,2)+1} = ['\t\tUP_' occurrences{i,1} ' rew_HW_model_UP_' occurrences{i,1} '\n'];
        mChains_HW{size(mChains_HW,2)+1} = ['\t\tDOWN_' occurrences{i,1} ' rew_HW_model_DOWN_' occurrences{i,1} '\n'];
        mChains_HW{size(mChains_HW,2)+1} = ['\tend\n\n'];
        mChains_HW{size(mChains_HW,2)+1} = ['\t* Initial Probabilities defined: \n'];
        mChains_HW{size(mChains_HW,2)+1} = ['\tUP_' occurrences{i,1} ' init_HW_model_UP_' occurrences{i,1} '\n'];
        mChains_HW{size(mChains_HW,2)+1} = ['\tDOWN_' occurrences{i,1} ' init_HW_model_DOWN_' occurrences{i,1} '\n'];
        mChains_HW{size(mChains_HW,2)+1} = ['end\n\n'];
        
        binds_HW{size(binds_HW,2)+1} = ['* DOWN configuration: HW_' occurrences{i,1} '_Config\n'];
        binds_HW{size(binds_HW,2)+1} = ['bind\n'];
        binds_HW{size(binds_HW,2)+1} = ['\trew_HW_model_UP_' occurrences{i,1} '\t0\n'];
        binds_HW{size(binds_HW,2)+1} = ['\trew_HW_model_DOWN_' occurrences{i,1} '\t1\n'];
        binds_HW{size(binds_HW,2)+1} = ['end\n\n'];
        
        binds_HW{size(binds_HW,2)+1} = ['* Initial Probability: HW_' occurrences{i,1} '_InitProb\n'];
        binds_HW{size(binds_HW,2)+1} = ['bind\n'];
        binds_HW{size(binds_HW,2)+1} = ['\tinit_HW_model_UP_' occurrences{i,1} '\t1\n'];
        binds_HW{size(binds_HW,2)+1} = ['\tinit_HW_model_DOWN_' occurrences{i,1} '\t0\n'];
        binds_HW{size(binds_HW,2)+1} = ['end\n\n'];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        mChains_BT{size(mChains_BT,2)+1} = ['markov BT_model_' occurrences{i,1} '(' toBT 'mu_bt) readprobs \n'];
        for j=0:btStages-1,
             mChains_BT{size(mChains_BT,2)+1} = ['\tB' num2str(j) '_' occurrences{i,1} ' B' num2str(j+1) '_' occurrences{i,1} ' lambda_bt' num2str(j) '\n'];
        end
        mChains_BT{size(mChains_BT,2)+1} = ['\tB' num2str(j+1) '_' occurrences{i,1} ' B0_' occurrences{i,1} ' mu_bt\n\n'];
        mChains_BT{size(mChains_BT,2)+1} = ['\t* Reward configuration defined: \n'];
        mChains_BT{size(mChains_BT,2)+1} = ['\treward\n'];
        for j=0:btStages,
            mChains_BT{size(mChains_BT,2)+1} = ['\t\tB' num2str(j) '_' occurrences{i,1} ' rew_BT_model_' occurrences{i,1} '_B' num2str(j) '\n'];            
        end
        mChains_BT{size(mChains_BT,2)+1} = ['\tend\n\n'];
        mChains_BT{size(mChains_BT,2)+1} = ['\t* Initial Probabilities defined: \n'];
        for j=0:btStages,
            mChains_BT{size(mChains_BT,2)+1} = ['\tB' num2str(j) '_' occurrences{i,1} ' init_BT_model_' occurrences{i,1} '_B' num2str(j) '\n'];            
        end
        mChains_BT{size(mChains_BT,2)+1} = ['end\n\n'];
         
        binds_BT{size(binds_BT,2)+1} = ['* DOWN configuration: BT_' occurrences{i,1} '_Config\n'];
        binds_BT{size(binds_BT,2)+1} = ['bind\n'];
        for j=0:btStages-1,
            binds_BT{size(binds_BT,2)+1} = ['\trew_BT_model_' occurrences{i,1} '_B' num2str(j) '\t0\n'];
        end
        binds_BT{size(binds_BT,2)+1} = ['\trew_BT_model_' occurrences{i,1} '_B' num2str(j+1) '\t1\n'];
        binds_BT{size(binds_BT,2)+1} = ['end\n\n'];

        binds_BT{size(binds_BT,2)+1} = ['* Initial Probability: BT_' occurrences{i,1} '_InitProb\n'];
        binds_BT{size(binds_BT,2)+1} = ['bind\n'];
        binds_BT{size(binds_BT,2)+1} = ['\tinit_BT_model_' occurrences{i,1} '_B0\t1\n'];
        for j=1:btStages,
            binds_BT{size(binds_BT,2)+1} = ['\tinit_BT_model_' occurrences{i,1} '_B' num2str(j) '\t0\n'];
        end
        binds_BT{size(binds_BT,2)+1} = ['end\n\n'];
    end
end



outFile_FULL = '.\sharpeModel_FULL.txt';
outFile_HW_BT = '.\sharpeModel_HW_BT.txt';
outFile_HW_LK = '.\sharpeModel_HW_LK.txt';
outFile_HW = '.\sharpeModel_HW.txt';

fileID_FULL = fopen(outFile_FULL, 'wt');
fileID_HW_BT = fopen(outFile_HW_BT, 'wt');
fileID_HW_LK = fopen(outFile_HW_LK, 'wt');
fileID_HW = fopen(outFile_HW, 'wt');

%header
header = '***********************************\n*       Generated by ThiagoCJ     *\n***********************************\n\n';

%format configuration
formatConfig = 'format 8\nfactor on\n\n';

%Attribute
attribute = [];

attribute{size(attribute,2)+1} = ['func Availability(t) 1-tvalue(t;FTA_model;t)\n'];
attribute{size(attribute,2)+1} = ['\tloop t,0,10000,0.25\n'];
attribute{size(attribute,2)+1} = ['\t\texpr Availability(t)\n'];
attribute{size(attribute,2)+1} = ['\tend\n'];
attribute{size(attribute,2)+1} = ['end'];


fprintf(fileID_FULL,header);
fprintf(fileID_FULL,formatConfig);

fprintf(fileID_HW_BT,header);
fprintf(fileID_HW_BT,formatConfig);

fprintf(fileID_HW_LK,header);
fprintf(fileID_HW_LK,formatConfig);

fprintf(fileID_HW,header);
fprintf(fileID_HW,formatConfig);

% for i=1:size(binds,2),
%     fprintf(fileID_FULL,binds{i});
% end
for i=1:size(binds_LK,2),
    fprintf(fileID_FULL,binds_LK{i});
    fprintf(fileID_HW_LK,binds_LK{i});
end

for i=1:size(binds_HW,2),
    fprintf(fileID_FULL,binds_HW{i});
    fprintf(fileID_HW_BT,binds_HW{i});
    fprintf(fileID_HW_LK,binds_HW{i});
    fprintf(fileID_HW,binds_HW{i});
end

for i=1:size(binds_BT,2),
    fprintf(fileID_FULL,binds_BT{i});
    fprintf(fileID_HW_BT,binds_BT{i});
end


%Markov Chains
% for i=1:size(mChains,2),
%     fprintf(fileID_FULL,mChains{i});
% end
for i=1:size(mChains_LK,2),
    fprintf(fileID_FULL,mChains_LK{i});
    fprintf(fileID_HW_LK,mChains_LK{i});
end

for i=1:size(mChains_HW,2),
    fprintf(fileID_FULL,mChains_HW{i});
    fprintf(fileID_HW_BT,mChains_HW{i});
    fprintf(fileID_HW_LK,mChains_HW{i});
    fprintf(fileID_HW,mChains_HW{i});
end

for i=1:size(mChains_BT,2),
    fprintf(fileID_FULL,mChains_BT{i});
    fprintf(fileID_HW_BT,mChains_BT{i});
end

%Fault Tree
% fprintf(fileID_FULL,'ftree FTA_model(time)\n');
% for i=1:size(ftEvents,2),
%     fprintf(fileID_FULL,ftEvents{i});
% end
fprintf(fileID_FULL,'ftree FTA_model(time)\n');
fprintf(fileID_HW_BT,'ftree FTA_model(time)\n');
fprintf(fileID_HW_LK,'ftree FTA_model(time)\n');
fprintf(fileID_HW,'ftree FTA_model(time)\n');
for i=1:size(ftEvents_HW_noBT,2),
    fprintf(fileID_HW_LK,ftEvents_HW_noBT{i});
    fprintf(fileID_HW,ftEvents_HW_noBT{i});
end
for i=1:size(ftEvents_HW,2),
    fprintf(fileID_FULL,ftEvents_HW{i});
    fprintf(fileID_HW_BT,ftEvents_HW{i});
end
for i=1:size(ftEvents_LK,2),
    fprintf(fileID_FULL,ftEvents_LK{i});
    fprintf(fileID_HW_LK,ftEvents_LK{i});
end
for i=1:size(ftEvents_BT,2),
    fprintf(fileID_FULL,ftEvents_BT{i});
    fprintf(fileID_HW_BT,ftEvents_BT{i});
end
fprintf(fileID_FULL,'\n');
fprintf(fileID_HW_BT,'\n');
fprintf(fileID_HW_BT,'\n');
fprintf(fileID_HW,'\n');
for i=1:size(ftGatesIni,2),
    fprintf(fileID_FULL,ftGatesIni{i});
    fprintf(fileID_HW_BT,ftGatesIni{i});
end

%TODO: COnferir as variaveis ftGatesEnd_LK e ftGatesEnd_WLK
for i=1:size(ftGatesEnd_LK,2),
    fprintf(fileID_FULL,ftGatesEnd_LK{i});
    fprintf(fileID_HW_LK,ftGatesEnd_LK{i});
end
for i=1:size(ftGatesEnd_WLK,2),
    fprintf(fileID_HW_BT,ftGatesEnd_WLK{i});
    fprintf(fileID_HW,ftGatesEnd_WLK{i});
end
for i=1:size(ftGatesEnd,2),
    fprintf(fileID_FULL,ftGatesEnd{i});
    fprintf(fileID_HW_BT,ftGatesEnd{i});
    fprintf(fileID_HW_LK,ftGatesEnd{i});
    fprintf(fileID_HW,ftGatesEnd{i});
end
fprintf(fileID_FULL,'end\n\n');
fprintf(fileID_HW_BT,'end\n\n');
fprintf(fileID_HW_LK,'end\n\n');
fprintf(fileID_HW,'end\n\n');

%Attribute
for i=1:size(attribute,2),
    fprintf(fileID_FULL,attribute{i});
    fprintf(fileID_HW_BT,attribute{i});
    fprintf(fileID_HW_LK,attribute{i});
    fprintf(fileID_HW,attribute{i});
end

fclose(fileID_FULL);
fclose(fileID_HW_BT);
fclose(fileID_HW_LK);
fclose(fileID_HW);

modelTime = toc();
display(['Model Generation: ' num2str(modelTime) 's']);